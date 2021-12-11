type token_supply = { current_stock : nat ; token_address : address ; token_price : tez }
type token_shop_storage = (nat, token_supply) map
type return = operation list * token_shop_storage

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

let owner_address : address =
  ("tz1Rv9NDodukAWpYfHcx1HQStFoeHSZmdpFF" : address)

let main (token_kind_index, token_shop_storage : nat * token_shop_storage) : return =
  let token_kind : token_supply =
    match Map.find_opt (token_kind_index) token_shop_storage with
    | Some k -> k
    | None -> (failwith "Unknown kind of token" : token_supply)
  in
 
  let () = if Tezos.amount <> token_kind.token_price then
    failwith "Sorry, the token you are trying to purchase has a different price"
  in
 
  let () = if token_kind.current_stock = 0n then
    failwith "Sorry, the token you are trying to purchase is out of stock"
  in
 
  let token_shop_storage = Map.update
    token_kind_index
    (Some { token_kind with current_stock = abs (token_kind.current_stock - 1n) })
    token_shop_storage
  in
    let tr : transfer = {
    from_ = Tezos.self_address;
    txs = [ {
      to_ = Tezos.sender;
      token_id = abs (token_kind.current_stock - 1n);
      amount = 1n;
    } ];
  } 
  in
  let entrypoint : transfer list contract = 
    match ( Tezos.get_entrypoint_opt "%transfer" token_kind.token_address : transfer list contract option ) with
    | None -> ( failwith "Invalid external token contract" : transfer list contract )
    | Some e -> e
  in
 
  let fa2_operation : operation =
    Tezos.transaction [tr] 0mutez entrypoint
  in
   let receiver : unit contract =
    match (Tezos.get_contract_opt owner_address : unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : (unit contract))
  in
 
  let payout_operation : operation = 
    Tezos.transaction unit amount receiver 
  in
  ([fa2_operation ; payout_operation], token_shop_storage)