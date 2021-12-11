// simple nat div with default value
// ligo dry-run simple.mligo tuple_main 4,2 0

type storage = int
type parameter = int
type tuple_parameter = nat * nat
type return = operation list * storage
type nat_return = operation list * nat
 
let add (a, b : int * int) : int = a + b

let div (a, b : nat * nat) : nat option =
  if b = 0n then (None : nat option) else Some (a/b)

let save_div(a, b : nat * nat) : nat =
  let result = div (a, b) in
    match result with 
        Some(x) -> x
        | None -> 0n

let tuple_main (p, s : tuple_parameter * storage) : nat_return = 
 (([] : operation list), save_div(p.0, p.1))
 
let main (p, s : parameter * storage) : return = 
 (([] : operation list), add (p,s))