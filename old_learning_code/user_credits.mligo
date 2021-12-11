// ligo dry-run user_credits.mligo main 'Tail()' '[("Alice",12);("Bob",3);("Celine",7)]'
// ligo dry-run user_credits.mligo main 'Increment()' '[("Alice",12);("Bob",3);("Celine",7)]'
// ligo dry-run user_credits.mligo main 'Extend("y", 1)' '[("Alice",12);("Bob",3);("Celine",7)]'
type name = string
type credits = int
type user = name * credits
type storage = user list
type parameter =
  Extend of user
| Increment
| Tail
type return = operation list * storage
 
let extend_list (u, s : user * storage) : storage = u :: s
 
let increment (u : user) : user = (u.0, u.1 + 1)
let increment_list (s : user list) : user list = List.map increment s
 
let get_tail (s : storage) : storage = 
 match List.tail_opt s with 
   Some(x) -> x
 | None -> []
 
let main (p, s : parameter * storage) : return =
 ([] : operation list), 
 (match p with
   Extend (u) -> extend_list (u, s)
 | Increment -> increment_list (s)
 | Tail -> get_tail (s))