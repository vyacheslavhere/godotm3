# tile class
class_name Tile
extends Node2D

# fields
var x: int = 0
var y: int = 0
var chip: Chip = null
var board: Board = null
var is_generator: bool = false

# init
func init(board: Board, x: int, y: int, is_generator: bool):
	self.board = board
	self.x = x
	self.y = y
	self.is_generator = is_generator
	
# generate
func generate_chip():
	var kind = board.random_chip()
	var chip = board.instantiate_prefab(
		kind
	) as Chip
	
	chip.init(
		board, 
		self,
		kind
	)
	self.chip = chip
	
	chip.is_busy = true	
	
	chip.position = board.to_point(x, y - 1)
	
	var tween = create_tween().set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(
		chip, 
		"position", 
		board.to_point(x, y), 
		board.fall_tween_duration
	)
	tween.tween_callback(
		func(): 
			chip.is_busy = false
			board.enqueue_match(chip.find_match(true))
	)	
	
# tick
func tick():
	if chip != null:
		chip.tick()
	if chip == null and self.is_generator:
		generate_chip()

# has stable ceil
func has_stable_ceil() -> bool:
	for y in range(y, -1, -1):
		var tile = board.tile_at(x, y)
		if tile == null: return true
		if tile.chip == null: continue
		if tile.chip.is_busy: return false
		if tile.chip.can_fall(): return false
	return true

# is flow stable
func is_flow_stable() -> bool:
	for y in range(0, board.height):
		var tile = board.tile_at(x, y)
		if tile == null: return true
		if tile.chip == null: continue
		if tile.chip.is_busy: return false
		if tile.chip.can_fall(): return false
	return true
	
# deletes chip
func delete_chip():
	if !chip.is_busy:
		chip.queue_free()
		chip = null
