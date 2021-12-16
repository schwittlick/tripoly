#include "types.mligo"
#include "misc.mligo"
#include "admin.mligo"
#include "fa2lib.mligo"

// some pre-defined constants of the game
let max_position : nat = 18n
let max_position_idx : nat = 17n
let co2_saved_temporary_constant : nat = 100n
let bounty_over_start : tez = 1tz
let delay_in_seconds : int = 100
let timeout_in_seconds : int = 120 //86400
let debug : bool = true


let join_game (player_name, storage : string * players_storage) : players_storage =
    // you have to join the game before playing (dice roll endpoint)
    // when not entering a name, we will fail & return
    if size_op(player_name) < 1n then (failwith "Please enter a name." : players_storage) else

    // only join the game when you are not in the game already
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> (failwith "You are already playing the game." : players_storage)
                    // create a new player record with some default values
        | None ->   let new_player : player = {name = player_name; position = 0n; saved_co2_kilos = 0n; last_dice_roll = Tezos.now; current_step = 0n; supported_fields = ([] : supported_fields)} 
                    in
                    Map.add sender_addr new_player storage


let leave_game (storage : players_storage) : players_storage =
    // let the user leave the game, but only if they are in the game
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> Map.remove sender_addr storage
        | None -> (failwith "You are not in the game, yet, no possible to leave." : players_storage)


let sum_co2_mults (l : supported_fields) : nat =
    let sum (acc, supported_field : nat * supported_field) : nat = acc + supported_field.co2_multiplier
    in 
    let sum_of_elements : nat = List.fold sum l 0n
    in
    sum_of_elements


let calculate_saved_co2 (player, was_over_start: player * bool) : nat = 
    // this is only a mockup implementation
    // currently we save a constant co2 certificate bounty for the user
    // this should be calculated depending on supported projects / owned nfts
    //let sum (acc, i : int * int) : int = acc + i
    //let sum_multiplicators : nat = List.fold sum player.supported_fields 0
    let sum : nat = sum_co2_mults(player.supported_fields)
    in
    if was_over_start then co2_saved_temporary_constant * sum else 0n
    

let transfer_bounty (over_start: bool) : operation list =
    // this will send a fixed amount of tez from the contract to the caller
    // its happening when the player rolled the dice and went over the start of the board game
    
    // only continue when the contract has enough funds 
    if Tezos.balance >= bounty_over_start then
        // only execute the transaction if it was really true
        if over_start then
            let sender_addr = Tezos.sender in
            let receiver : unit contract =
                match (Tezos.get_contract_opt sender_addr : unit contract option) with
                | Some (contract) -> contract
                | None -> (failwith ("Not a contract") : (unit contract))
            in
            let payoutOperation : operation = 
                Tezos.transaction unit bounty_over_start receiver 
            in
            let operations : operation list = 
                [payoutOperation]
            in operations
        else
            ([] : operation list)
    else ([] : operation list)
 

let roll_dice(random_number, sender_addr, storage, global_step : nat * address * players_storage * nat) : operation list * players_storage = 
    // this is the main entrypoint to play the game
    // at the moment a "random" dice roll is passed into the contract, that is not ideal, the caller can choose where to step

    // make sure it's a number between (incl.) 1 and 6
    // when in debug mode, we can jump more
    if random_number > (if debug then 20n else 6n) || random_number < 1n then
        (failwith "You can only step at least 1 and maximum 6 fields." : operation list * players_storage)
    else
    // check if the caller has joined the game already
    match Map.find_opt sender_addr storage with
        Some(pl) -> // fail and return when the player has already rolled the dice within the last `delay_in_seconds` amount of seconds
                    //if (if debug then false else (Tezos.now < (pl.last_dice_roll + delay_in_seconds)))
                    // changes the timeout per dice into the round based mechanism. a player can only roll the dice when the next round started (the global_step game step advanced)
                    if pl.current_step >= global_step
                    then 
                        (failwith "You have to wait until everybody played and a new round is over. Come back in a few minutes." : operation list * players_storage)
                    else
                        let random_number : nat = random_number //Tezos.now mod 6 in 
                        in 
                        let new_position : nat = (pl.position + random_number) 
                        in
                        let new_pos_modulo : nat = new_position mod max_position
                        in
                        let was_over_start : bool = if new_position > max_position_idx then true else false
                        in
                        let saved_co2 : nat = calculate_saved_co2(pl, was_over_start)
                        in 
                        // make a new player to with new values to update our storage
                        let new_player_data : player = {name = pl.name; position = new_pos_modulo; saved_co2_kilos = pl.saved_co2_kilos + saved_co2; last_dice_roll = Tezos.now; current_step = pl.current_step + 1n; supported_fields = pl.supported_fields} 
                        in
                        // update storage
                        let updated_storage : players_storage = Map.update sender_addr (Some(new_player_data)) storage
                        in
                        // calculate and transfer bounty if the player went over the start field with their dice roll
                        ((transfer_bounty(was_over_start) : operation list), updated_storage)
        | None -> (failwith "Please join the game first to play." : operation list * players_storage)
    

let update_player_supported_projects (player, player_addr, players_storage, field : player * address * players_storage * field) : players_storage =
    let new_player_storage = Map.update
        player_addr
        (Some { player with supported_fields = ({token_address=field.token_address; co2_multiplier=field.co2_multiplier} :: player.supported_fields)})
        players_storage
    in
    new_player_storage


let clock(storage, global_step : players_storage * step) : operation list * players_storage * step = 
    // this function can be called by anybody
    // it looks through all players, when they are timed out, automatically roll the dice for them (1 step only)
    // when all players are stepped forward, the game advances, the next round started. all players can roll again.
    let check_step = fun (acc, addr_pl : (operation list * players_storage) * (address * player)) -> 
                        let last_interaction : timestamp = addr_pl.1.last_dice_roll
                        in
                        let timeout : bool = Tezos.now > (last_interaction + timeout_in_seconds)
                        in
                        let can_step_forward : bool = addr_pl.1.current_step < global_step
                        in
                        let default_return : operation list * players_storage = (([] : operation list), acc.1)
                        in
                        let result : operation list * players_storage  = if timeout && can_step_forward then roll_dice(1n, addr_pl.0, acc.1, global_step) else default_return
                        in
                        let ol : operation list = result.0
                        in
                        let ps : players_storage = result.1
                        in
                        let head_opt : operation option = List.head_opt ol
                        in
                        match head_opt with
                            Some(what) -> ((what :: acc.0), ps)
                            | None -> ((acc.0), ps)
    in
    let result : operation list * players_storage = Map.fold check_step storage (([] : operation list), storage)
    in
    let check_all_players_current_step = fun (i, player : nat * (address * player)) -> if player.1.current_step <> global_step then i + 1n else i + 0n
    in
    let number_of_players_who_have_not_played_yet : nat = Map.fold check_all_players_current_step result.1 0n
    in
    if number_of_players_who_have_not_played_yet = 0n then
        (result.0, result.1, global_step + 1n)
    else
        (result.0, result.1, global_step)
    

let support (storage : global_storage) : operation list * global_storage =
    // this endpoint lets you buy an nft. or in other words, support the project you are currently stepped on
    // the price of the token is sent to the owner.. Should be sent to the contract instead
    let sender_addr = Tezos.sender 
    in
    // only continue if the caller is already registered as a player
    match Map.find_opt sender_addr storage.1 with
        None -> failwith "You are not in the game." 
        | Some(pl) -> 

    let token_shop_storage : fields_storage = storage.0
    in
    
    // you can only buy the nft of your current position
    let token_kind_index : nat = pl.position
    in
    let token_kind : field =
    // only continue when we have a token saved
    match Map.find_opt (token_kind_index) token_shop_storage with
        | Some k -> k
        | None -> (failwith "Unknown kind of token" : field)
    in
    if debug then 
        // when debugging, we don't want to send nfts and payments around. just updating player data
        let new_player_storage : players_storage = update_player_supported_projects(pl, sender_addr, storage.1, token_kind)
        in
        (([] : operation list), (token_shop_storage, new_player_storage, storage.2))
    else
    let result : operation list * fields_storage = transfer(token_kind, token_kind_index, token_shop_storage)
    in
    let new_player_storage : players_storage = update_player_supported_projects(pl, sender_addr, storage.1, token_kind)
    in
    (result.0, (result.1, new_player_storage, storage.2))


let main (p, s : parameter * global_storage) : return_storage =
    // our main function, defining all entrypoints

    let nft_count : nat = Map.size s.0 in
    // we only continue when the game is initialized. That means all NFTs are created and saved in the storage
    // currently the construction of the return_storage is a bit complicated and could be optimized
    if nft_count < max_position then (failwith ("There are not enough NFTs in the storage, yet.") : (return_storage)) else
    (match p with
        Join (player_name) ->           let res : players_storage = join_game (player_name, s.1)
                                        in
                                        (([] : operation list), (s.0, res, s.2))

        | Leave ->                      let res : players_storage = leave_game (s.1)
                                        in
                                        (([] : operation list), (s.0, res, s.2))

        | Dice (random_number) ->       let res : operation list * players_storage = roll_dice (random_number, Tezos.sender, s.1, s.2) 
                                        in
                                        (res.0, (s.0, res.1, s.2))

        | Support ->                    let res : operation list * global_storage = support(s)
                                        in
                                        (res.0, res.1)

        | Payout(tez_amount) ->         let res : operation list = payout(tez_amount)
                                        in
                                        (res, s)

        | Refill ->                     (([] : operation list), s)

        | Clock ->                      let res : operation list * players_storage * step = clock (s.1, s.2) 
                                        in
                                        (res.0, (s.0, res.1, res.2))

        | SetField (idx, stock, addr, price, co2_multiplier) ->   
                                        let res : fields_storage = set_field(idx, stock, addr, price, co2_multiplier, s.0)
                                        in
                                        (([] : operation list), (res, s.1, s.2)))
