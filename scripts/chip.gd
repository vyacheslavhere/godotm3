# Chip class
class_name Chip
extends Node2D

# Board and tile
var board: Board
var tile: Tile

# Chip info
var kind: String
var is_busy: bool

# Chip settings
@export var is_fall_enabled: bool
@export var is_swap_enabled: bool
@export var is_break_arrows: bool

# Chip signals
signal swap(with: Chip)
signal damage()

# Initializes chips
func init(board: Board, tile: Tile, kind: String):
	self.board = board
	self.tile = tile
	self.kind = kind

# Is chip can fall down?
func can_fall_down() -> bool:
	var tile = board.tile_at(tile.x, tile.y + 1)
	if tile != null:
		return tile.chip == null
	else:
		return false

# Is chip can fall left diag?
func can_fall_left_diag() -> bool:
	if is_busy: return false
	else:
		var under_left = self.board.tile_at(self.tile.x - 1, self.tile.y + 1)
		if under_left == null: return false
		if under_left.chip != null: return false
		if under_left.chip == null and under_left.has_stable_ceil(): return true
		return false

# Is chip can fall right diag?
func can_fall_right_diag() -> bool:
	if is_busy: return false
	else:
		var under_right = self.board.tile_at(self.tile.x + 1, self.tile.y + 1)
		if under_right == null: return false
		if under_right.chip != null: return false
		if under_right.chip == null and under_right.has_stable_ceil(): return true
		return false		
			
# Is chip can fall diag?
func can_fall_diag() -> bool:
	if is_busy: return false
	else:
		if can_fall_left_diag(): return true
		elif can_fall_right_diag(): return true
		else: return false
		
# Is chip can fall?
func can_fall() -> bool:
	if is_busy: return false
	else:
		if can_fall_down(): return true
		elif can_fall_diag(): return true
		else: return false

# Falls to point visual
func visual_fall_to(point: Vector2):
	# Visual tween
	var tween = create_tween()
	tween.tween_property(
		self, 
		"position", 
		point, 
		board.fall_tween_duration
	)
	tween.tween_callback(
		func(): 
			self.is_busy = false
			board.enqueue_match(find_match(true))
	)

# Falls to tile
func fall_to(tile: Tile):
	# Setting chip business to true
	self.is_busy = true
	
	# If tile is same
	if self.tile == tile:
		# Nothing to do
		return
	
	# If tile is set
	if self.tile != null:
		# Resetting tile chip
		self.tile.chip = null

	# Setting tile chip to self
	tile.chip = self

	# Setting self tile
	self.tile = tile
	
	# Visual tween
	self.visual_fall_to(tile.position)

# Performs fall if chip can do that
func try_fall() -> void:
	# If chip is busy or fall is disabled -> nothing to do
	if !is_fall_enabled: return
	if is_busy: return
	
	# If fall is enabled and chip isn't busy -> trying to fall
	else:
		# If chip can fall down
		if can_fall_down():
			# Getting under tile
			var under_tile = self.board.tile_at(tile.x, tile.y + 1)
			
			# Falling to under tile
			self.fall_to(under_tile)
			
		# If chip can fall diag to left
		elif can_fall_left_diag():
			# Getting under left tile
			var under_left_tile = self.board.tile_at(tile.x - 1, tile.y + 1)
			
			# Falling to under left tile
			self.fall_to(under_left_tile)
			
		elif can_fall_right_diag():
			# Getting under right tile
			var under_right_tile = self.board.tile_at(tile.x + 1, tile.y + 1)
			
			# Falling to under left tile
			self.fall_to(under_right_tile)

# Finds horizontal matchables
func find_horizontal_matchables():
	var tiles = []
	
	for x in range(self.tile.x + 1, board.width + 1):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break		
		if tile.chip.kind == self.kind: tiles.append(tile)
		else: break
			
	for x in range(self.tile.x - 1, -1, -1):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break		
		if tile.chip.kind == self.kind: tiles.append(tile)
		else: break
			
	return tiles	

# Finds vertical matchables
func find_vertical_matchables():
	var tiles = []
	
	for y in range(self.tile.y + 1, board.height + 1):
		var tile = self.board.tile_at(self.tile.x, y)
		if tile == null: break
		if tile.chip == null: break		
		if tile.chip.kind == self.kind: tiles.append(tile)
		else: break
			
	for y in range(self.tile.y - 1, -1, -1):
		var tile = self.board.tile_at(self.tile.x, y)
		if tile == null: break
		if tile.chip == null: break
		if tile.chip.kind == self.kind: tiles.append(tile)
		else: break
			
	return tiles		

# Finds match
func find_match(pending: bool):
	if self.kind not in board.chip_groups['chips']: return
	
	var horizontal = find_horizontal_matchables()	
	var vertical = find_vertical_matchables()
	
	if horizontal.size() == 4:
		return {"tail": horizontal, "source": self.tile, "is_pending": pending, "out": "color_bomb"}
	elif vertical.size() == 4:
		return {"tail": vertical, "source": self.tile, "is_pending": pending, "out": "color_bomb"}
	elif horizontal.size() == 3:
		return {"tail": horizontal, "source": self.tile, "is_pending": pending, "out": "horizontal_arrow"}
	elif vertical.size() == 3:
		return {"tail": vertical, "source": self.tile, "is_pending": pending, "out": "vertical_arrow"}
	elif horizontal.size() == 2 and vertical.size() == 2:
		horizontal.append_array(vertical)
		return {"tail": horizontal, "source": self.tile, "is_pending": pending, "out": "bomb"}
	elif horizontal.size() == 2:
		return {"tail": horizontal, "source": self.tile, "is_pending": pending, "out": "empty"}		
	elif vertical.size() == 2:
		return {"tail": vertical, "source": self.tile, "is_pending": pending, "out": "empty"}
	else:
		return null

# Ticks chip
func tick() -> void:
	try_fall()

# Is chip can be safely shuffled?
func can_be_shuffled() -> bool:
	return true
