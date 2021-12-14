
type supported_field = {token_address : address; co2_multiplier : nat}
type supported_fields = supported_field list

// a record representing a player
type player = {name : string; position : nat; saved_co2_kilos : nat; last_dice_roll : timestamp; supported_fields : supported_fields}
type players_storage = (address, player) map

// a record representing one playing field on the board
type field = { current_stock : nat ; token_address : address ; token_price : tez ; co2_multiplier : nat }
type fields_storage = (nat, field) map

// the global storage saved on the contract
type global_storage = fields_storage * players_storage
type return_storage = operation list * global_storage

// definitions of our entrypoints
type parameter =
  Join of string
| Leave
| Dice of nat
| SetField of nat * nat * address * tez * nat
| Support
| Payout of tez
| Refill