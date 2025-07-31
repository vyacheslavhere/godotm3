# bomb
class_name BombChip
extends Node2D

# chip
@export var chip: Chip

# on swap
func _on_bomb_swap(with: Chip) -> void:
	chip.is_busy = true
	with.tile.delete_chip_immediate()
	chip.board.explode_radius(
		chip.tile,
		1
	)
	chip.tile.delete_chip_immediate()	


# on damage
func _on_bomb_damage() -> void:
	chip.is_busy = true
	chip.board.explode_radius(
		chip.tile,
		1
	)
	chip.tile.delete_chip_immediate()	
