#!/bin/zsh

# ligo dry-run main.mligo main 'Dice()' 'Map.literal [("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi" : address), {name="Marcel"; position=0n; saved_co2_kilos=0n};]' --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=100

ligo compile-contract main.mligo main --output-file=main.tz
ligo compile-storage main.mligo main 'Map.literal [("tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi" : address), {name="Klodie"; position=0n; saved_co2_kilos=0n};]' --output-file=main_storage.tz
tezos-client -E https://rpc.hangzhounet.teztnets.xyz originate contract main transferring 100 from schwittlick-testing running main.tz --init "`cat main_storage.tz`" --burn-cap 2 --force