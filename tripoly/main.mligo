#include "misc.mligo"

type player = {name : string; position : nat; saved_co2_kilos : nat;}
type players_storage = (address, player) map
type field = {ipfslink : string; balance : nat}
type fields = (nat, field) map
type storage = fields * players_storage
type return_storage = operation list * storage

type parameter =
  Join of string
| Leave
| Dice
| SetField of nat * string
type return = operation list * players_storage

let max_position : nat = 18n
let max_position_idx : nat = 17n
let co2_saved_temporary_constant : nat = 100n
let bounty_over_start : tez = 1tz

let owner : address = ("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi": address)

let join_game (player_name, storage : string * players_storage) : return =
    if size_op(player_name) < 1n then (failwith "Please enter a name." : return) else

    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> (failwith "You are already playing the game." : return)
        | None ->   let new_player : player = {name = player_name; position = 0n; saved_co2_kilos = 0n} in
                    ([] : operation list), Map.add sender_addr new_player storage

let leave_game (storage : players_storage) : return =
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> ([] : operation list), Map.remove sender_addr storage
        | None -> (failwith "You are not in the game, yet, no possible to leave." : return)

let calculate_saved_co2 (was_over_start: bool) : nat = 
    if was_over_start then co2_saved_temporary_constant else 0n
// this should be calculated depending on supported projects

let set_field(index, link, fields_storage : nat * string * fields) : fields =
    // check if it exists already
    if Tezos.sender <> owner then (failwith "Access denied." : fields)
    else 
    let updated_storage : fields = Map.update index (Some{ipfslink=link; balance=0n}) fields_storage
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
 
let roll_dice(storage : players_storage) : return = 
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(pl) -> let random_number : nat = 6n //Tezos.now mod 6 in 
                    in 
                    let new_position : nat = (pl.position + random_number) 
                    in
                    let new_position_and_was_over_start : nat * bool = (new_position mod max_position, (if new_position > max_position_idx then true else false)) 
                    in
                    let new_player_data : player = {name = pl.name; position = new_position_and_was_over_start.0; saved_co2_kilos = pl.saved_co2_kilos + calculate_saved_co2(new_position_and_was_over_start.1)} 
                    in
                    let updated_storage : players_storage = Map.update sender_addr (Some(new_player_data)) storage
                    in
                    ((transfer_bounty(new_position_and_was_over_start.1) : operation list), updated_storage)
        | None -> (failwith "Please join the game first to play." : return)
    

let main (p, s : parameter * storage) : return_storage =
    (match p with
        Join (player_name) -> let res : return = join_game (player_name, s.1)
                                in
                                (res.0, (s.0, res.1))
        | Leave -> let res : return = leave_game (s.1)
                    in
                    (res.0, (s.0, res.1))
        | Dice -> let res : return = roll_dice (s.1) 
                    in
                    (res.0, (s.0, res.1))

        | SetField (idx, ipfslink) -> let res : fields = set_field(idx, ipfslink, s.0)
                                        in
                                        (([] : operation list), (res, s.1)))
