# Shuffler class
class_name Shuffler
extends Node
	
# Board reference
@onready var board: Board = $".."

# Should shuffle?
func should_shuffle() -> bool:
	return board.is_idle() and !board.has_possible_moves()
		
# Shuffles the board
func do_shuffle() -> void:
	# Freezing board
	board.is_freezed = true
	
	# Deleting all the chips and spawning new
	for tile in board.tiles:
		if tile.chip != null:
			# If chip is in chips group and can be shuffled
			if tile.chip.kind in board.chip_groups['chips'] and tile.chip.can_be_shuffled():
				tile.delete_chip_immediate()
				var kind = board.random_chip()
				board.spawn_chip(kind, tile)
	
	# Unfreezing board
	board.is_freezed = false
	
	# Finding all the matches
	board.find_all_matches()
	
# When timer hits 1 second
func _on_timeout() -> void:
	# If should shuffle -> shuffle
	if self.should_shuffle():
		print("[shuffler] shuffling board")
		self.do_shuffle()
