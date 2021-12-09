// ligo dry-run user_management_map.mligo main 'Add(3n, {name="lol"; is_admin=true})' 'Map.literal [0n, {name="Alice"; is_admin=false};]'

type user = { name : string ; is_admin : bool }
type id = nat
type user_storage = (id, user) map
type parameter =
  Add of id * user
| Update of id * user
| Remove of id
type return = operation list * user_storage
 
let add_entry (i, u, s : id * user * user_storage) : user_storage =
  Map.add i u s
 
let update_entry (i, u, s : id * user * user_storage) : user_storage =
  Map.update i (Some (u)) s
 
let remove_entry (i, s : id * user_storage) : user_storage =
  Map.remove i s
 
let main (p, s : parameter * user_storage) : return =
 ([] : operation list),
 (match p with
   Add (i, u)  -> add_entry (i, u, s)
 | Update (i, u) -> update_entry (i, u, s)
 | Remove (i) -> remove_entry (i, s))