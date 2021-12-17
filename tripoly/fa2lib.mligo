let transfer(token_kind, token_kind_index, token_shop_storage : field * nat * fields_storage) : operation list * fields_storage = 
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

    // call our token contract %transfer endpoint
    let fa2_operation : operation =
        Tezos.transaction [tr] 0mutez entrypoint
    in

    // make sure the receiver is valid
    // this should be the creator of the nft at some point
    // how to get the creator tho?
    let receiver : unit contract =
    match (Tezos.get_contract_opt owner : unit contract option) with
        | Some (contract) -> contract
        | None -> (failwith ("Not a contract") : (unit contract))
    in

    // send the payout tz to the receiver
    let payout_operation : operation = 
        Tezos.transaction unit amount receiver 
    in
    ([fa2_operation; payout_operation], token_shop_storage)