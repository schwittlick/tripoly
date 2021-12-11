## tripoly

We want to create a decentralized board-game on Tezos, to educate people about renewable and sustainable projects in a playful and interactive way. We want to disrupt the game idea of Monopoly and turn its values around, from capitalism and re-shape it for the future of web3 to an open source knowledge game using the conventions and the features of the metaverse.

### questions

    1. questions, how can ligo dry-run set Tezos.sender? (--sender)
    2. how to make a fake pseudo random nr somehow?
    3. how to add timelock so player can only roll dice once per 5 minutes
    4. how to read the storage from a webapp? prolly an api call to tzkt or bcd, to visualize the current state.
    5. how can i check for a map as storage in a test?
    6. how execute and return multiple operations.

#### question 5

    let _test () =
    let initial_storage = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};] in
    let (taddr, _, _) = Test.originate main initial_storage 0tez in
    let contr = Test.to_contract(taddr) in
    let _r = Test.transfer_to_contract_exn contr (Join ("Marcel")) 1tez  in
    (Test.get_storage(taddr) = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};])

    let test = _test ()
### iteration log

    first contract -> KT1ChmfSbutmeGLpGqX6J7X1vZpyuh943uuM
    second contract, with dice -> KT1TDAToeMYtkv8bJ2jxGRBVZFZ1pTZcUMvX
    third iteration, with name only, new position modulo -> KT1Ct1TJ6NPjPN1pfo428392rw9ScBQXXjKS
    fourth iteration, simple saved co2 field -> KT18rNgBjupzv9YHw2nhu6PeuJrkNMzcATAL
    5. iteration, conditional co2 saved -> KT1PjELyh37MW8p6ui6aQWQPmgFWRCuP3shd
    6. iteration, no empty name allowed when using join endpoint -> KT1CoosHHw5zSDUueBSiiEM876bfq1hVagai
    7. iteration, when over start, receive some tezzi -> KT1RgSCkbBuBvygQ5ne2fZKgshXJCLneMHjB
    8. iteration, originated with some initial tez, can't send anything to the contract above :/ KT1NJLH1HkLPMogd2nG6amAxd193tfbo9YwU
    9. iteration, checking for Tezos.balance before attempting -> KT1LyYzJ6hm9Piqh3QubV1RxYJxeCFHPG6Ax


### ipfs metadata

https://anarkrypto.github.io/upload-files-to-ipfs-from-browser-panel/public/#

[example metadata json](../tripoly/project1.json)


### endpoints

    ligo dry-run main.mligo main 'Join("Marcel")' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n};]'
    ligo dry-run main.mligo main 'Leave()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'
    ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'


### nfts


    Use OpenMinter https://github.com/tqtezos/minter
    With wallet tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi
    Created new collection TestCollectionHackathon (KT1N6GwCQMNWkHaAPKL6ZgLSgxi7Y26dLybX)
    Created new token: First Anti Monopoly NFT in KT1N6GwCQMNWkHaAPKL6ZgLSgxi7Y26dLybX (token 0)
    Created new token: First Anti Monopoly NFT in KT1N6GwCQMNWkHaAPKL6ZgLSgxi7Y26dLybX (token 1)
    Transferring token to KT1EdSL2bvgXBUedPq5d5R7SHbpk5EmHz9uW (transfer contract from tacode and back)
    Created new collection TestCollectionHackathonTwo (KT1Wpyqt4EP5vBYPxVWaPRRcSVCKL6S916xu)
    Created new token: First one of the second Anti Monopoly NFTS ꘐ in KT1Wpyqt4EP5vBYPxVWaPRRcSVCKL6S916xu
    Created new collection AnotherCollection (KT1VocMG4tjJgq3vzyZDBw8AAnJWTJv1Qusz)
    Created new token: What is this logo? in KT1VocMG4tjJgq3vzyZDBw8AAnJWTJv1Qusz
    Created new token: Third one in here. Maybe this has metadata? in KT1N6GwCQMNWkHaAPKL6ZgLSgxi7Y26dLybX (token 2)
    Created new collection CollectionWithTwo (KT1PtSQYch2QJoCE9pNPfFkB53fibyT7KL8m)
    Created new collection CollectionOfOne (KT1BhPfrdxVMeE1ftePCcH14nF1fyFSdJLxC)
    reated new collection Collection11 (KT1CE144SvpAv4iUQb8Zey4M3SKQQEV9DWMd)

    it worked. necessary was to set the amount in mutez. so weird.