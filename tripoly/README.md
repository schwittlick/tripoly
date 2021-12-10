## tripoly

We want to create a decentralized board-game on Tezos, to educate people about renewable and sustainable projects in a playful and interactive way. We want to disrupt the game idea of Monopoly and turn its values around, from capitalism and re-shape it for the future of web3 to an open source knowledge game using the conventions and the features of the metaverse.

### questions

    questions, how can ligo dry-run set Tezos.sender?
    how to make a pseudo random nr somehow?
    add timelock so player can only roll dice once per 5 minutes
    how to read the storage? prolly an api call to tzkt or bcd, to visualize the current state.
    how can i check for a map as storage in a test?

### iteration log

    first contract -> KT1ChmfSbutmeGLpGqX6J7X1vZpyuh943uuM
    second contract, with dice -> KT1TDAToeMYtkv8bJ2jxGRBVZFZ1pTZcUMvX
    third iteration, with name only, new position modulo -> KT1Ct1TJ6NPjPN1pfo428392rw9ScBQXXjKS
    fourth iteration, simple saved co2 field -> KT18rNgBjupzv9YHw2nhu6PeuJrkNMzcATAL
    5. iteration, conditional co2 saved -> KT1PjELyh37MW8p6ui6aQWQPmgFWRCuP3shd
    6. iteration, no empty name allowed when using join endpoint -> KT1CoosHHw5zSDUueBSiiEM876bfq1hVagai


### endpoints

    ligo dry-run main.mligo main 'Join("Marcel")' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n};]'
    ligo dry-run main.mligo main 'Leave()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'
    ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Alice"; position=0n};]'