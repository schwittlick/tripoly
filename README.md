## tripoly

We want to create a decentralized board-game on Tezos, to educate people about renewable and sustainable projects in a playful and interactive way. We want to disrupt the game idea of Monopoly and turn its values around, from capitalism and re-shape it for the future of web3 to an open source knowledge game using the conventions and the features of the metaverse.

### deployment

The most recent contract is deployed here https://better-call.dev/hangzhou2net/KT1JwJcQnzDLbpsLkQ1nyVJvM3Jru8cXJ8fh

The frontend is running here: https://schwittlick.net/tzconnect_hackathon/

![alt text](./images/d3b41637dc9240a484d18661e2b5ce58.png "Screenshot of our very basic frontend")

A basic video of how to use it here: [images/walkthrough_video.mp4](images/walkthrough_video.mp4)

### code

Our game contract source code is [tripoly/main.mligo](./tripoly/main.mligo).

The frontend code is [frontend/index.html](./frontend/index.html)

### next steps for making the game a real product

    1. balance game parameters (timeout, bounty, amount of playing fields, nft prices etc)
    2. per field 3 nfts with multiple editions ( research, proto etc)
    3. activity fields (go back to start without bounty etc), to avoid/reduce the possibility for people to play only to get tezos by making rounds
    4. market place to trade supported projects (secondary market)
    5. how to refill the game? reset mode? 
    6. people could be able to vote for which project include in the field
    7. fix random number problem
    8. frontend needs to be responsibe and dynamic
    9. a round based mechanism, so all players are in sync, nobody can roll more than others
    10. calculate saved co2 depending on how many nfts collected
    11. create leaderboard of people who saved the most co2 by supporting projects
    12. when you join the game it should cost a small fee
    13. add a refill entrypoint to stock up on funds
    14. send nft price to the contract instead of owner
    15. branding & communication to talk about the project


### notes

We are making use of OpenMinter to mint tokens. Also we are using the nftshop contract from the tacode tutorial.

For this we mint tokens, send them by hand to our contract. Before we do that, we need to mint all tokens and send them to the storage of out contract after we deployed it with the storage containing all our minted token addresses.
Check [the storage file](./tripoly/main_storage.mligo)
Once this is complete it's possible to interact with our contract via it's 'Support' entry point. This call needs to have the same amount associated than the price of the token.


### questions

    1. questions, how can ligo dry-run set Tezos.sender? (--sender)
    2. how to make a fake pseudo random nr somehow?
    3. how to add timelock so player can only roll dice once per 5 minutes
    4. how to read the storage from a webapp? prolly an api call to tzkt or bcd, to visualize the current state.
    5. how can i check for a map as storage in a test? (too much for hackathon)
    6. how execute and return multiple operations. (solved)

#### question 5

    let _test () =
    let initial_storage = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};] in
    let (taddr, _, _) = Test.originate main initial_storage 0tez in
    let contr = Test.to_contract(taddr) in
    let _r = Test.transfer_to_contract_exn contr (Join ("Marcel")) 1tez  in
    (Test.get_storage(taddr) = Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};])

    let test = _test ()
### main.mligo iteration log

    first contract -> KT1ChmfSbutmeGLpGqX6J7X1vZpyuh943uuM
    second contract, with dice -> KT1TDAToeMYtkv8bJ2jxGRBVZFZ1pTZcUMvX
    third iteration, with name only, new position modulo -> KT1Ct1TJ6NPjPN1pfo428392rw9ScBQXXjKS
    fourth iteration, simple saved co2 field -> KT18rNgBjupzv9YHw2nhu6PeuJrkNMzcATAL
    5. iteration, conditional co2 saved -> KT1PjELyh37MW8p6ui6aQWQPmgFWRCuP3shd
    6. iteration, no empty name allowed when using join endpoint -> KT1CoosHHw5zSDUueBSiiEM876bfq1hVagai
    7. iteration, when over start, receive some tezzi -> KT1RgSCkbBuBvygQ5ne2fZKgshXJCLneMHjB
    8. iteration, originated with some initial tez, can't send anything to the contract above :/ KT1NJLH1HkLPMogd2nG6amAxd193tfbo9YwU
    9. iteration, checking for Tezos.balance before attempting -> KT1LyYzJ6hm9Piqh3QubV1RxYJxeCFHPG6Ax
    10. iteration, adding fields map to storage -> KT1HGJraHkJTv3Q9azGRMBoQy5oidJVKg951
    11. iteration, implements SetField admin endpoint -> KT1Q6HpqNdyNSfwkh4SaEyJNcZnK2ZrVhcsQ
    12. adds barebones for 5min timeout for interaction. exposes dice call *dangerours* -> KT1Xk425atpHjnBin1fgjXvumWyLssSpg6p4
    13. it seems it worked, make a real test edition: KT1UGSYe6TB5RkANKyHe7SJvsutPDwJVWbv6
    14. dice should be 1 <= nr <= 6 -> KT1T4eNM8APgQnuiy8Z2kjeEFT9XJTiUebk2
    15. changes field record, now using stock, token addr, tez price -> KT1Js7LVjGw8L6yLYGaB36fdZw2qnapA3Fm6
    16. included the nft shop code as an endpoint: -> KT1QiT73UPVmoDGZX6Qxpkhrqmsn4UzwarPt. i sent the nft to this address. then i can buy it and it works :)))))
    17. made a check, cant play when nfts not finished initializing. -> KT1H2P27NYGZPrLJfoR2tuxL3HdcXVgDdbWx
    18. deployed the same contract with 18 test nfts as storage -> KT1FmuDmRD1to4GcVHSYAZgBEccCNNdjY7Gp. again, i've sent the nft of the collection KT1CE144SvpAv4iUQb8Zey4M3SKQQEV9DWMd to the contract and bought it via the support endpoint
    19. final KT1JwJcQnzDLbpsLkQ1nyVJvM3Jru8cXJ8fh


### nft shop iterations (outdated)

    KT1V8pKF3WjqgWUqCy4Wiho1YrU8oc1SCxoS
    second one: KT19kzRvG6mpFPn549vohEBWmUa5grhj8BfD
    third, only with one 1/1 nft: KT1Sw833fCed4X8pQH3wFtDhi9kAixANv35P
    fourth with only one 1/1: KT1Rc9U3bDU3Ajbsk84X6M8zT442x3X2sECb

### ipfs metadata

https://anarkrypto.github.io/upload-files-to-ipfs-from-browser-panel/public/#

[example metadata json](./tripoly/project1.json)


### endpoints

    ligo dry-run main.mligo main 'Join("Marcel")' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Leave()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Dice(6)' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Support()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z' --amount=1
    ligo dry-run main.mligo main 'Payout(10tz)' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'


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