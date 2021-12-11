let ownerAddress : address =
  ("tz1fUqB1d5bWtMrF98pFCWdaY5XpcEgYFSyu" : address)
 
let main (p, s: unit * unit) : operation list * unit =
 
  let receiver : unit contract =
    match (Tezos.get_contract_opt ownerAddress : unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : (unit contract))
  in
 
  let payoutOperation : operation = 
    Tezos.transaction unit amount receiver 
  in
  let operations : operation list = 
    [payoutOperation] 
  in
  ((operations: operation list), s)