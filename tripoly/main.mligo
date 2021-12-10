#include "misc.mligo"


type player = { name : string ; position : nat; saved_co2_kilos : nat;}
type players_storage = (address, player) map
type parameter =
  Join of string
| Leave
| Dice
type return = operation list * players_storage

let max_position : nat = 18n
let max_position_idx : nat = 17n
let co2_saved_temporary_constant : nat = 100n
 
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
// this should be calculated depending on supported projects

let transfer_bounty (_pl: player) : operation list =
    // check Tezos.balance of contract to make sure it can send reward
    // https://ligolang.org/docs/tutorials/inter-contract-calls/inter-contract-calls
    let sender_addr = Tezos.sender in
    let receiver : unit contract =
        match (Tezos.get_contract_opt sender_addr : unit contract option) with
        | Some (contract) -> contract
        | None -> (failwith ("Not a contract") : (unit contract))
    in
    let payoutOperation : operation = 
        Tezos.transaction unit amount receiver 
    in
    let operations : operation list = 
        [payoutOperation]
    in operations
 
let roll_dice(storage : players_storage) : players_storage = 
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
                    Map.update sender_addr (Some(new_player_data)) storage
        | None -> (failwith "Please join the game first to play." : players_storage)
    

let main (p, s : parameter * players_storage) : return =
    ([] : operation list),
    (match p with
        Join (player_name) -> join_game (player_name, s)
        | Leave -> leave_game (s)
        | Dice -> roll_dice (s))

let _test () =
  let initial_storage = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};] in
  let (taddr, _, _) = Test.originate main initial_storage 0tez in
  let contr = Test.to_contract(taddr) in
  let _r = Test.transfer_to_contract_exn contr (Join ("Marcel")) 1tez  in
  (Test.get_storage(taddr) = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};])

let test = _test ()