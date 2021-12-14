let owner : address = ("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi": address)

let payout(tez_amount : tez) : operation list =
    // this is an admin endpoint. To extract funds from the contract to the above defined owner
    // parameter is in mutez

    if Tezos.sender <> owner then (failwith "Access denied." : operation list)
    else 
    // only continue if the balance of the contract is enough to payout
    if Tezos.balance >= tez_amount then
        // the receiver is not the caller, only the owner of the contract
        let receiver : unit contract =
        match (Tezos.get_contract_opt owner : unit contract option) with
            | Some (contract) -> contract
            | None -> (failwith ("Not a contract") : (unit contract))
        in

        let payout_operation : operation = 
            Tezos.transaction unit tez_amount receiver 
        in
        [payout_operation]
    else ([] : operation list)


let set_field(index, stock, addr, price, co2_multiplier, fields_storage : nat * nat * address * tez * nat * fields_storage) : fields_storage =
    // with this entrypoint the administrator can stock up new nfts in the contract
    // index: the playing field index
    // stock: how many nfts are gonna be in stock
    // price: the address of the collection holind the nft
    // fields_storage: the current state of the playing board storage
    if Tezos.sender <> owner then (failwith "Access denied." : fields_storage)
    else 
    // here we should check whether the token address is a contract. It should fail when it's a wallet address.
    let updated_storage : fields_storage = Map.update index (Some{current_stock=stock; token_address=addr; token_price=price; co2_multiplier=co2_multiplier}) fields_storage
    in
    updated_storage
