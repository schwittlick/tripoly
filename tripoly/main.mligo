// ligo dry-run main.mligo main 'Join({name="Marcel"; position=0n})' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'
// ligo dry-run main.mligo main 'Leave()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'
// ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'

// ligo compile-contract main.mligo main --output-file=main.tz
// ligo compile-storage main.mligo main 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]' --output-file=main_storage.tz
// tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running main.tz --init "`cat main_storage.tz`" --burn-cap 2 --force
//
// first contract
// KT1ChmfSbutmeGLpGqX6J7X1vZpyuh943uuM
// second contract, with dice
// KT1TDAToeMYtkv8bJ2jxGRBVZFZ1pTZcUMvX

#include "misc.mligo"

// questions, how can tezos-client set Tezos.sender?
// how to make a pseudo random nr somehow?

type player = { name : string ; position : nat}
type players_storage = (address, player) map
type parameter =
  Join of player
| Leave
| Dice
type return = operation list * players_storage
 
let join_game (player, storage : player * players_storage) : players_storage =
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> (failwith "You are already playing the game." : players_storage)
        | None -> Map.add sender_addr player storage
 
let leave_game (storage : players_storage) : players_storage =
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(_pl) -> Map.remove sender_addr storage
        | None -> (failwith "You are not in the game, yet, no possible to leave." : players_storage)
    
 
let roll_dice(storage : players_storage) : players_storage = 
    let sender_addr = Tezos.sender in
    match Map.find_opt sender_addr storage with
        Some(pl) -> let random_number : nat = 6n in //Tezos.now mod 6 in 
                    let new_player_data : player = {name = pl.name; position = pl.position + random_number} in
                    Map.update sender_addr (Some(new_player_data)) storage
        | None -> (failwith "Please join the game first to play." : players_storage)
    

let main (p, s : parameter * players_storage) : return =
    ([] : operation list),
    (match p with
        Join (player) -> join_game (player, s)
        | Leave -> leave_game (s)
        | Dice -> roll_dice (s))