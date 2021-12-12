#include "misc.mligo"

type transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : nat;
  amount : nat;
}
 
type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

// a record representing a player
type player = {name : string; position : nat; saved_co2_kilos : nat; last_dice_roll : timestamp}
type players_storage = (address, player) map

// a record representing one playing field on the board
type field = { current_stock : nat ; token_address : address ; token_price : tez }
type fields_storage = (nat, field) map

// the global storage saved on the contract
type global_storage = fields_storage * players_storage
type return_storage = operation list * global_storage

// definitions of our entrypoints
type parameter =
  Join of string
| Leave
| Dice of nat
| SetField of nat * nat * address * tez
| Support
| Payout of tez

// some pre-defined constants of the game
let max_position : nat = 18n
let max_position_idx : nat = 17n
let co2_saved_temporary_constant : nat = 100n
let bounty_over_start : tez = 1tz
let delay_in_seconds : int = 100

let owner : address = ("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi": address)


let join_game (player_name, storage : string * players_storage) : players_storage =
    // you have to join the game before playing (dice roll endpoint)
    // when not entering a name, we will fail & return
    if size_op(player_name) < 1n then (failwith "Please enter a name." : players_storage) else

    // only join the game when you are not in the game already
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> (failwith "You are already playing the game." : players_storage)
                    // create a new player record with some default values
        | None ->   let new_player : player = {name = player_name; position = 0n; saved_co2_kilos = 0n; last_dice_roll = Tezos.now} 
                    in
                    Map.add sender_addr new_player storage


let leave_game (storage : players_storage) : players_storage =
    // let the user leave the game, but only if they are in the game
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> Map.remove sender_addr storage
        | None -> (failwith "You are not in the game, yet, no possible to leave." : players_storage)


let calculate_saved_co2 (was_over_start: bool) : nat = 
    // this is only a mockup implementation
    // currently we save a constant co2 certificate bounty for the user
    // this should be calculated depending on supported projects / owned nfts
    if was_over_start then co2_saved_temporary_constant else 0n
    

let set_field(index, stock, addr, price, fields_storage : nat * nat * address * tez * fields_storage) : fields_storage =
    // with this entrypoint the administrator can stock up new nfts in the contract
    // index: the playing field index
    // stock: how many nfts are gonna be in stock
    // price: the address of the collection holind the nft
    // fields_storage: the current state of the playing board storage
    if Tezos.sender <> owner then (failwith "Access denied." : fields_storage)
    else 
    // here we should check whether the token address is a contract. It should fail when it's a wallet address.
    let updated_storage : fields_storage = Map.update index (Some{current_stock=stock; token_address=addr; token_price=price}) fields_storage
    in
    updated_storage


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
 

let roll_dice(random_number, storage : nat * players_storage) : operation list * players_storage = 
    // this is the main entrypoint to play the game
    // at the moment a "random" dice roll is passed into the contract, that is not ideal, the caller can choose where to step

    // make sure it's a number between (incl.) 1 and 6
    if random_number > 6n || random_number < 1n then
        (failwith "You can only step at least 1 and maximum 6 fields." : operation list * players_storage)
    else
    let sender_addr = Tezos.sender 
    in
    // check if the caller has joined the game already
    match Map.find_opt sender_addr storage with
        Some(pl) -> // fail and return when the player has already rolled the dice within the last `delay_in_seconds` amount of seconds
                     if Tezos.now < (pl.last_dice_roll + delay_in_seconds)
                    then 
                        (failwith "You can only roll the dice once every 100 seconds." : operation list * players_storage)
                    else
                        let random_number : nat = random_number //Tezos.now mod 6 in 
                        in 
                        let new_position : nat = (pl.position + random_number) 
                        in
                        let new_pos_modulo : nat = new_position mod max_position
                        in
                        let was_over_start : bool = if new_position > max_position_idx then true else false
                        in
                        let saved_co2 : nat = calculate_saved_co2(was_over_start)
                        in 
                        // make a new player to with new values to update our storage
                        let new_player_data : player = {name = pl.name; position = new_pos_modulo; saved_co2_kilos = pl.saved_co2_kilos + saved_co2; last_dice_roll = Tezos.now} 
                        in
                        // update storage
                        let updated_storage : players_storage = Map.update sender_addr (Some(new_player_data)) storage
                        in
                        // calculate and transfer bounty if the player went over the start field with their dice roll
                        ((transfer_bounty(was_over_start) : operation list), updated_storage)
        | None -> (failwith "Please join the game first to play." : operation list * players_storage)
    


let support (storage : global_storage) : operation list * fields_storage =
    // this endpoint lets you buy an nft. or in other words, support the project you are currently stepped on
    // the price of the token is sent to the owner.. Should be sent to the contract instead
    let sender_addr = Tezos.sender 
    in
    // only continue if the caller is already registered as a player
    match Map.find_opt sender_addr storage.1 with
        None -> (failwith "You are not in the game." : operation list * fields_storage)
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

    let () = if Tezos.amount <> token_kind.token_price then
        failwith "Sorry, the token you are trying to purchase has a different price"
    in

    let () = if token_kind.current_stock = 0n then
        failwith "Sorry, the token you are trying to purchase is out of stock"
    in

    let token_shop_storage = Map.update
        token_kind_index
        (Some { token_kind with current_stock = abs (token_kind.current_stock - 1n) })
        token_shop_storage
    in
    let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
        to_ = Tezos.sender;
        token_id = abs (token_kind.current_stock - 1n);
        amount = 1n;
    } ];
    } 
    in
    let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" token_kind.token_address : transfer list contract option ) with
        | None -> ( failwith "Invalid external token contract" : transfer list contract )
        | Some e -> e
    in

    // call our token contract %transfer endpoint
    let fa2_operation : operation =
        Tezos.transaction [tr] 0mutez entrypoint
    in

    // make sure the receiver is valid
    let receiver : unit contract =
    match (Tezos.get_contract_opt owner : unit contract option) with
        | Some (contract) -> contract
        | None -> (failwith ("Not a contract") : (unit contract))
    in

    // send the payout tz to the receiver
    let payout_operation : operation = 
        Tezos.transaction unit amount receiver 
    in
    ([fa2_operation; payout_operation], token_shop_storage)


let payout(tez_amount : tez) : operation list =
    // this is an admin endpoint. To extract funds from the contract to the above defined owner
    // parameter is in mutez

    if Tezos.sender <> owner then (failwith "Access denied." : operation list)
    else 
    // only continue if the balance of the contract is enough to payout
    if Tezos.balance >= tez_amount then
        // the receiver is not the caller, only the owner of the contract
        let receiver : unit contract =
        match (Tezos.get_contract_opt owner : unit contract option) with
            | Some (contract) -> contract
            | None -> (failwith ("Not a contract") : (unit contract))
        in

        let payout_operation : operation = 
            Tezos.transaction unit tez_amount receiver 
        in
        [payout_operation]
    else ([] : operation list)


let main (p, s : parameter * global_storage) : return_storage =
    // our main function, defining all entrypoints

    let nft_count : nat = Map.size s.0 in
    // we only continue when the game is initialized. That means all NFTs are created and saved in the storage
    // currently the construction of the return_storage is a bit complicated and could be optimized
    if nft_count < max_position then (failwith ("There are not enough NFTs in the storage, yet.") : (return_storage)) else
    (match p with
        Join (player_name) ->           let res : players_storage = join_game (player_name, s.1)
                                        in
                                        (([] : operation list), (s.0, res))

        | Leave ->                      let res : players_storage = leave_game (s.1)
                                        in
                                        (([] : operation list), (s.0, res))

        | Dice (random_number) ->       let res : operation list * players_storage = roll_dice (random_number, s.1) 
                                        in
                                        (res.0, (s.0, res.1))

        | Support ->                    let res : operation list * fields_storage = support(s)
                                        in
                                        (res.0, (res.1, s.1))

        | Payout(tez_amount) ->         let res : operation list = payout(tez_amount)
                                        in
                                        (res, s)

        | SetField (idx, stock, addr, price) ->   
                                        let res : fields_storage = set_field(idx, stock, addr, price, s.0)
                                        in
                                        (([] : operation list), (res, s.1)))
