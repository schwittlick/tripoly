// ligo dry-run main.mligo main 'Join({name="Marcel"; position=0n})' 'Map.literal ["tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx", {name="Alice"; position=0n};]'
// ligo compile-contract main.mligo main --output-file=main.tz
// ligo compile-storage main.mligo main 'Map.literal ["tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx", {name="Alice"; position=0n};]' --output-file=main_storage.tz


//'Map.literal ["tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx", {name="Alice"; position=0n};]'


type player = { name : string ; position : nat}
type players_storage = (address, player) map
type parameter =
  Join of player
| Leave
//| Dice
type return = operation list * players_storage
 
let join_game (player, storage : player * players_storage) : players_storage =
    let sender_addr = Tezos.sender in
    Map.add sender_addr player storage
 
let leave_game (storage : players_storage) : players_storage =
    let sender_addr = Tezos.sender in
    Map.remove sender_addr storage
 
//let roll_dice(storage : players_storage) : players_storage = 
//    let n = Random.int 6 in

let main (p, s : parameter * players_storage) : return =
    ([] : operation list),
    
    (match p with
        Join (player) -> join_game (player, s)
        | Leave -> leave_game (s))
       // | Dice -> roll_dice (s))