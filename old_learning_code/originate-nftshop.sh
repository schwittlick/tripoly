#!/bin/zsh

ligo compile-contract nftshop.mligo main --output-file=nftshop.tz
ligo compile-storage nftshop.mligo main "`cat nftshop_storage.mligo`" --output-file=nftshop_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running nftshop.tz --init "`cat nftshop_storage.tz`" --burn-cap 2 --force