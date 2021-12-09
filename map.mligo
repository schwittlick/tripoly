// ligo dry-run map.mligo main '0' '"wat"'

type storage = string
type parameter = int
type tuple_parameter = nat * nat
type return = operation list * string
type nat_return = operation list * nat
type usernames = (int, string) map

let my_usernames : usernames =
    Map.literal [
        (0, "Alice");
        (1, "Bob");
        (2, "Celia")
    ]

//let empty : my_usernames = Map.empty

let my_username : string option =
    Map.find_opt 1 my_usernames

let update (u : usernames) : usernames =
    Map.update (2) (Some("Cillian")) u

let add (u : usernames) : usernames =
    Map.add (3) ("Dan") u

let remove (u : usernames) : usernames =
    Map.remove (2) u


let save_get(u : int) : string =
  let my_username : string option =
   Map.find_opt u my_usernames in
    match my_username with 
        Some(x) -> x
        | None -> "lol"

// iter works on a const list, cant change data
let iter_op (u : usernames) : unit =
    let predicate = fun (_i,j : int * string) -> assert (j <> "Bob")
    in Map.iter predicate u

// map can change data in a list
let map_op (u : usernames) : usernames =
    let add_user = fun (_i,j : int * string) -> "user_" ^ j 
    in Map.map add_user u


 let main (p, _s : parameter * storage) : return = 
  let my_username : string = save_get(p) in
 (([] : operation list), my_username)