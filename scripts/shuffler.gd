extends Node

# Initializes shuffler
func init(board: Board):
	self.board = board
	
# Should shuffle?
func should_shuffle() -> bool:
	for tile in self.board.tiles:
		if tile.co
	return true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
