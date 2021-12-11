#!/bin/zsh

# New contract KT1EdSL2bvgXBUedPq5d5R7SHbpk5EmHz9uW originated.

ligo compile-contract transfer.mligo main --output-file=transfer.tz
ligo compile-storage transfer.mligo main 'unit' --output-file=transfer_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running transfer.tz --init "`cat transfer_storage.tz`" --burn-cap 2 --force