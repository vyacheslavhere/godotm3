# color chip
class_name ColorChip
extends Node

# chip
@export var chip: Chip

# on damage
func _on_damage() -> void:
	chip.tile.delete_chip()
