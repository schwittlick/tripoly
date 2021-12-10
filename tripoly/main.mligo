// ligo dry-run main.mligo main 'Join("Marcel")' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n};]'
// ligo dry-run main.mligo main 'Leave()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'
// ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'

// ligo compile-contract main.mligo main --output-file=main.tz
// ligo compile-storage main.mligo main 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n};]' --output-file=main_storage.tz
// tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running main.tz --init "`cat main_storage.tz`" --burn-cap 2 --force
//
// first contract
// KT1ChmfSbutmeGLpGqX6J7X1vZpyuh943uuM
// second contract, with dice
// KT1TDAToeMYtkv8bJ2jxGRBVZFZ1pTZcUMvX
// third iteration, with name only, new position modulo
// KT1Ct1TJ6NPjPN1pfo428392rw9ScBQXXjKS

#include "misc.mligo"

// questions, how can ligo dry-run set Tezos.sender?
// how to make a pseudo random nr somehow?

type player = { name : string ; position : nat; saved_co2_kilos : nat;}
type players_storage = (address, player) map
type parameter =
  Join of string
| Leave
| Dice
type return = operation list * players_storage

let max_position : nat = 18n
let max_position_idx : nat = 17n
 
let join_game (player_name, storage : string * players_storage) : players_storage =
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

let calculate_saved_co2 (_pl: player) : nat = 100n 
 
let roll_dice(storage : players_storage) : players_storage = 
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(pl) -> let random_number : nat = 6n in //Tezos.now mod 6 in 
                    let new_position : nat = (pl.position + random_number) in
                    let new_position_and_was_over_start : nat * bool = (new_position mod max_position, (if new_position > max_position_idx then true else false)) in
                    let new_player_data : player = {name = pl.name; position = new_position_and_was_over_start.0; saved_co2_kilos = pl.saved_co2_kilos + calculate_saved_co2(pl)} in
                    Map.update sender_addr (Some(new_player_data)) storage
        | None -> (failwith "Please join the game first to play." : players_storage)
    

let main (p, s : parameter * players_storage) : return =
    ([] : operation list),
    (match p with
        Join (player_name) -> join_game (player_name, s)
        | Leave -> leave_game (s)
        | Dice -> roll_dice (s))