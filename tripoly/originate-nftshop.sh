#!/bin/zsh

# KT1V8pKF3WjqgWUqCy4Wiho1YrU8oc1SCxoS
# second one: KT19kzRvG6mpFPn549vohEBWmUa5grhj8BfD
#third, only with one 1/1 nft: KT1Sw833fCed4X8pQH3wFtDhi9kAixANv35P

ligo compile-contract nftshop.mligo main --output-file=nftshop.tz
ligo compile-storage nftshop.mligo main "`cat nftshop_storage.mligo`" --output-file=nftshop_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 0 from schwittlick-testing running nftshop.tz --init "`cat nftshop_storage.tz`" --burn-cap 2 --force