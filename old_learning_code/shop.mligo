// ligo dry-run shop.mligo main '0n' 'Map.literal [ (0n, { current_stock = 20n ; token_price = 2mutez }) ; (1n, { current_stock = 4n ; token_price = 3mutez }) ; ]'

type token_supply = { current_stock : nat ; token_price : tez }
type token_shop_storage = (nat, token_supply) map
type token_kind_index = nat
type return = operation list * token_shop_storage

let owner_address : address =
  ("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address)

let main (token_kind_index, token_shop_storage : nat * token_shop_storage) : return =
    // who called the contract
    let sender = Tezos.sender

    let token_kind : token_supply =
        match Map.find_opt (token_kind_index) token_shop_storage with
        | Some k -> k
        | None -> (failwith "Unknown kind of token" : token_supply)
    in
    //let () = if Tezos.amount <> token_kind.token_price then
    //    failwith "Sorry, the token you are trying to purchase has a different price"
    //in
    let () = if token_kind.current_stock = 0n then
        failwith "Sorry, the token you are trying to purchase is out of stock"
    in
    let token_shop_storage = Map.update
        token_kind_index
        (Some { token_kind with current_stock = abs (token_kind.current_stock - 1n) })
        token_shop_storage
    in
    let receiver : unit contract =
        match (Tezos.get_contract_opt owner_address : unit contract option) with
        | Some (contract) -> contract
        | None -> (failwith ("Not a contract") : (unit contract))
    in
    let payout_operation : operation = 
        Tezos.transaction unit amount receiver 
    in
    let operations : operation list = 
        [payout_operation] 
    in
    ((operations: operation list), token_shop_storage)