// ligo dry-run user_management_record.mligo main 'Name ("Alice the great")' '{ id = 50n ; is_admin = false ; name = "Alice" }'

type user = {
 id       : nat;
 is_admin : bool;
 name     : string
}
type storage = user
type parameter =
  Name of string
| Admin of bool
type return = operation list * storage
 
let update_name (n, s : string * storage) : storage =
 {s with name = n}
 
let update_admin (n, s : bool * storage) : storage =
 {s with is_admin = n}
 
let main (p, s : parameter * storage) : return =
 ([] : operation list), 
 (match p with
   Name (n)  -> update_name (n, s)
 | Admin (n) -> update_admin (n, s))