# tile class
class_name Tile
extends Node2D

# Tile position
var x: int = 0
var y: int = 0

# Chip and board
var chip: Chip = null
var board: Board = null

# Is this tile a generator?
var is_generator: bool = false

# Initializes tile
func init(board: Board, x: int, y: int, is_generator: bool):
	self.board = board
	self.x = x
	self.y = y
	self.is_generator = is_generator
	
# Generates chip on tile
func generate_chip():
	# Generating random chip
	var kind = board.random_chip()
	var chip = board.instantiate_prefab(
		kind
	) as Chip
	
	# Initializing chip
	chip.init(
		board, 
		self,
		kind
	)
	self.chip = chip
	chip.is_busy = true	
	
	# Moving chip to point
	chip.position = board.to_point(x, y - 1)
	
	# Visual falling to point
	chip.visual_fall_to(board.to_point(x, y))
	
# Ticks tile
func tick():
	# If chip is not null: ticking chip
	if chip != null:
		chip.tick()
		
	# If no chip on tile and tile is generator: generating chip
	if chip == null and self.is_generator:
		generate_chip()

# Is tile has stable ceil?
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
		chip.is_busy = true
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.set_trans(Tween.TRANS_QUAD)
		tween.tween_property(
			chip, 
			"scale", 
			chip.scale * board.die_tween_scale_factor,
			board.die_tween_duration
		)
		tween.tween_callback(
			func():
				chip.queue_free()
				chip = null	
		)
	
# deletes chip immediate
func delete_chip_immediate():
	chip.queue_free()
	chip = null	
