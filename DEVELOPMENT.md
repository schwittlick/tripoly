## Endpoints

### Join(str)
Join the game and pass your player name

### Leave
Leave the game

### Dice(rolled_number : nat)
Once you are in the game (joined) you can roll the dice and advance on the playing field


### Support
You can support the project of your current position. This token has an amount, you will buy the nft.

### Clock
A debug endpoint. Call this in order to entire step the game forward. This force-steps inactive players one step forward. The game is round-based, meaning you can only roll the dice when everybody else has finished the previous round already.

### SetField(idx : nat, stock : nat, addr : address, price : tez, co2_multiplier : nat)
An admin-endpoint for now. The admin can set a new token for a field.

### Payout
An admin-endpoint. Sends balance from the contract to the admin.

### Refill
A cosmetic public endpoint to send xtz balance to the contract.



## Integration tests

    ligo dry-run main.mligo main 'Join("Marcel")' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Leave()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Dice(6n)' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Support()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z' --amount=1
    ligo dry-run main.mligo main 'Payout(10tz)' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'
    ligo dry-run main.mligo main 'Refill()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z' --amount=1
    ligo dry-run main.mligo main 'Clock()' "`cat main_storage.mligo`" --sender=tz1MEiHXRpHFmptzJyx4taqCmTHAYbcLpZUi --balance=10 --now='2021-01-01T10:10:10Z'


## Notes

We are making use of OpenMinter to pre-mint tokens. In the future these will be minted by players of the game.

For this we mint tokens, send them by hand to our contract. Before we do that, we need to mint all tokens and send them to the storage of out contract after we deployed it with the storage containing all our minted token addresses.
Check [the storage file](./tripoly/main_storage.mligo)
Once this is complete it's possible to interact with our contract via it's 'Support' entry point. This call needs to have the same amount associated than the price of the token. A playing field can be re-filled with a new token via the SetField endpoint.


The minted file is a json file [example](projects/01_MathEnergy.json) that references IPFS-hosted files: a .jpg "image" and a .usdz ("Hash") file. In order to host .usdz and download with it's native file format, you have to wrap the file in a folder.
These are two separately IPFS-hosted files. You can concatenate "Hash" and "Name" to get the URL for the .usdz file: `https://infura.io/ipfs/QmNPYbZis5cmXHRG5oumyFEmz5TwbVBhm53UecBfm8mSxh/01_ar_test01.usdz`

Call to host the file in folder

    curl -X POST -F file=@/path/to/file/11_project_tezos.usdz -u "key1:key2" "https://ipfs.infura.io:5001/api/v0/add?wrap-with-directory=true"

