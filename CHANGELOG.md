## 18.12.2021

### notes
- add a refill entrypoint to stock up on funds
- calculate saved co2 depending on how many nfts collected
- a round based mechanism, so all players are in sync, nobody can roll more than others
- joining the game should be free. you pay gas but once you make a round you are receiving 1tz
- the platform does not take any fees at the moment. depending on the status this should be changed. the creator of the nft received all balance of the transfer

### smart contract feature changelog

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

    20. add Refill endpoint (kinda cosmetic)
    21. receive money from nft purchase into contract address
    22. add supported fields list to player and co2 multiplier to field -> KT1K7yF9Vpst3gBydKf1YAuAWAE3V82Gje8G
    23. calculating co2 multiplier -> KT1UDTABPDiXU6swCAc3We5DdkBv2hN2kxPX
    24. adding debug flag and updating supported fields storage of player -> KT1KxSmjBQiuY6yLc5c1KaRgWMrsKZePbt5T

    25. minted .usdz file, added to game
    26. implemented a clock endpoint. Every player can call it, when a 24h timeout has happend, all inactive players are stepping forward. This is preparing the general round based playing. -> KT1UGfAS3fFJzJbNVC9t32mmK3k9mgFKCdeE
    27. next iteration (with debug off), refactored the fa2 sender a little. kinda needing tests now -> KT1PFudVgJVPjwZWQ9TUYk23xFhppFZXCAYW
    28. real round based playing, one round is 120s. debug on -> KT1KWP9JYFaTex983aXjigMA4AmC9Erurgs8
    29. fix little operator bug -> KT1VzkKaXqVUa8MgeCNw3HeonRmQmzQkpUho
    30. fix another operator bug in round playing mechanism -> KT1Hhxedz2DHSz24RLiXubLQv9u43uJbuNUy
    31. fix bug that user would get auto-dice-roll bc it's timed out, but already stepped in this round -> KT1RNeMZvAf1ce6HpWw37GmLxCSZrUJL8QFM
    32. FINALFINAL with final AR nfts -> KT1PZNb78PUiDRXmFGXPEyGaiocpk623CkEJ
    33. meh, bug in payment transfer. finalfinalfinal -> KT1X87rN7Hu6ZY4uK8ayQ9LgBXezHtd7nkZG
    34. some other small join bug -> KT19hqf8T654T3sFxRJpsULTtimqyGYK7Lhk