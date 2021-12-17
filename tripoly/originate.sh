#!/bin/zsh

# ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};]' --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=100
# ligo dry-run main.mligo main 'Dice()' '(Map.literal [0n, {ipfslink="link"; balance=1n}], Map.literal [("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};])' --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10
#  ligo dry-run main.mligo main 'Dice(7n)' '(Map.literal[0n, {ipfslink="link"; balance=1n}], Map.literal [("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n; last_interaction=("2020-10-11t13:55:10Z" : timestamp)};])' --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10
# ligo dry-run main.mligo main 'Dice(6n)' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'

ligo compile-contract main.mligo main --output-file=main.tz
ligo compile-storage main.mligo main "`cat main_storage.mligo`" --output-file=main_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 100 from schwittlick-testing running main.tz --init "`cat main_storage.tz`" --burn-cap 2 --force