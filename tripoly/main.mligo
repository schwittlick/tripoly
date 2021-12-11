#include "misc.mligo"

type player = {name : string; position : nat; saved_co2_kilos : nat;}
type players_storage = (address, player) map
type field = {ipfslink : string; balance : nat}

type fields_storage = (nat, field) map
type global_storage = fields_storage * players_storage
type return_storage = operation list * global_storage

type parameter =
  Join of string
| Leave
| Dice
| SetField of nat * string

let max_position : nat = 18n
let max_position_idx : nat = 17n
let co2_saved_temporary_constant : nat = 100n
let bounty_over_start : tez = 1tz

let owner : address = ("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi": address)

let join_game (player_name, storage : string * players_storage) : players_storage =
    if size_op(player_name) < 1n then (failwith "Please enter a name." : players_storage) else

    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> (failwith "You are already playing the game." : players_storage)
        | None ->   let new_player : player = {name = player_name; position = 0n; saved_co2_kilos = 0n} in
                    Map.add sender_addr new_player storage

let leave_game (storage : players_storage) : players_storage =
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> Map.remove sender_addr storage
        | None -> (failwith "You are not in the game, yet, no possible to leave." : players_storage)

let calculate_saved_co2 (was_over_start: bool) : nat = 
    if was_over_start then co2_saved_temporary_constant else 0n
    // this should be calculated depending on supported projects / owned nfts

let set_field(index, link, fields_storage : nat * string * fields_storage) : fields_storage =
    // check if it exists already
    if Tezos.sender <> owner then (failwith "Access denied." : fields_storage)
    else 
    let updated_storage : fields_storage = Map.update index (Some{ipfslink=link; balance=0n}) fields_storage
    in
    updated_storage

let transfer_bounty (over_start: bool) : operation list =
    if Tezos.balance >= bounty_over_start then
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
 
let roll_dice(storage : players_storage) : operation list * players_storage = 
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(pl) -> let random_number : nat = 19n //Tezos.now mod 6 in 
                    in 
                    let new_position : nat = (pl.position + random_number) 
                    in
                    let new_pos_modulo : nat = new_position mod max_position
                    in
                    let was_over_start : bool = if new_position > max_position_idx then true else false
                    in
                    let saved_co2 : nat = calculate_saved_co2(was_over_start)
                    in 
                    let new_player_data : player = {name = pl.name; position = new_pos_modulo; saved_co2_kilos = pl.saved_co2_kilos + saved_co2} 
                    in
                    let updated_storage : players_storage = Map.update sender_addr (Some(new_player_data)) storage
                    in
                    ((transfer_bounty(was_over_start) : operation list), updated_storage)
        | None -> (failwith "Please join the game first to play." : operation list * players_storage)
    

let main (p, s : parameter * global_storage) : return_storage =
    (match p with
        Join (player_name) ->           let res : players_storage = join_game (player_name, s.1)
                                        in
                                        (([] : operation list), (s.0, res))

        | Leave ->                      let res : players_storage = leave_game (s.1)
                                        in
                                        (([] : operation list), (s.0, res))

        | Dice ->                       let res : operation list * players_storage = roll_dice (s.1) 
                                        in
                                        (res.0, (s.0, res.1))

        | SetField (idx, ipfslink) ->   let res : fields_storage = set_field(idx, ipfslink, s.0)
                                        in
                                        (([] : operation list), (res, s.1)))
