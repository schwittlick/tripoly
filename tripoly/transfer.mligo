type token_id = nat
 
type transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : token_id;
  amount : nat;
}
 
type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

type storage = unit
 
let main (token_address, storage : address * storage) : (operation list * storage) =
  let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
      to_ = Tezos.sender;
      token_id = 0n;
      amount = 1n;
    } ];
  } 
  in
  let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" token_address : transfer list contract option ) with
    | None -> ( failwith "Invalid external token contract" : transfer list contract )
    | Some e -> e
  in
  
  let fa2_operation : operation =
    Tezos.transaction [tr] 0mutez entrypoint in
  ([fa2_operation], storage)