#!/bin/zsh

ligo compile-contract main.mligo main --output-file=main.tz
ligo compile-storage main.mligo main 'Map.literal [("tz1LvSqkwzYkL3MH4TyykEVfL9v95xey6Fxx" : address), {name="Klodie"; position=0n};]' --output-file=main_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running main.tz --init "`cat main_storage.tz`" --burn-cap 2 --force