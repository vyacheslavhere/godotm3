# bomb
class_name BombChip
extends Node2D

# Bomb chip
@export var chip: Chip

# On bomb swap
func _on_bomb_swap(with: Chip) -> void:
	# If chip is busy
	chip.is_busy = true
	
	# Deleting chip we swapping with
	if with != null: with.tile.delete_chip_immediate()
	
	# Exploding in radius `r = 1`
	chip.board.explode_radius(
		chip.tile,
		1
	)
	
	# Deleting this chip
	chip.tile.delete_chip_immediate()	

# On bomb damage
func _on_bomb_damage() -> void:
	chip.is_busy = true
	chip.board.explode_radius(
		chip.tile,
		1
	)
	chip.tile.delete_chip_immediate()	
