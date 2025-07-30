# chip class
class_name Chip
extends Node2D

# tile
var board: Board
var tile: Tile
var kind: String
var is_busy: bool

# init
func init(board: Board, tile: Tile, kind: String):
	self.board = board
	self.tile = tile
	self.kind = kind

# can fall down
func can_fall_down() -> bool:
	var tile = board.tile_at(tile.x, tile.y + 1)
	if tile != null:
		return tile.chip == null
	else:
		return false

# can fall left diag
func can_fall_left_diag() -> bool:
	if is_busy: return false
	else:
		var under_left = self.board.tile_at(self.tile.x - 1, self.tile.y + 1)
		if under_left == null: return false
		if under_left.chip != null: return false
		if under_left.chip == null and under_left.has_stable_ceil(): return true
		return false

# can fall right diag
func can_fall_right_diag() -> bool:
	if is_busy: return false
	else:
		var under_right = self.board.tile_at(self.tile.x + 1, self.tile.y + 1)
		if under_right == null: return false
		if under_right.chip != null: return false
		if under_right.chip == null and under_right.has_stable_ceil(): return true
		return false		
			
# can fall diag
func can_fall_diag() -> bool:
	if is_busy: return false
	else:
		if can_fall_left_diag(): return true
		elif can_fall_right_diag(): return true
		else: return false
		
# can fall
func can_fall() -> bool:
	if is_busy: return false
	else:
		if can_fall_down(): return true
		elif can_fall_diag(): return true
		else: return false

# falls, if can
func try_fall() -> void:
	if is_busy: return
	else:
		if can_fall_down():
			self.is_busy = true
						
			self.tile.chip = null
			var under_tile = self.board.tile_at(tile.x, tile.y + 1)
			under_tile.chip = self
			self.tile = under_tile
			
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(
				self, 
				"position", 
				under_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(func(): self.is_busy = false)			
			
		elif can_fall_left_diag():
			self.is_busy = true

			self.tile.chip = null
			var under_left_tile = self.board.tile_at(tile.x - 1, tile.y + 1)
			under_left_tile.chip = self
			self.tile = under_left_tile
			
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(
				self, 
				"position", 
				under_left_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(func(): self.is_busy = false)
			
		elif can_fall_right_diag():
			self.is_busy = true

			self.tile.chip = null
			var under_right_tile = self.board.tile_at(tile.x + 1, tile.y + 1)
			under_right_tile.chip = self
			self.tile = under_right_tile
			
			var tween = create_tween().set_trans(Tween.TRANS_QUAD)
			tween.set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(
				self, 
				"position",
				under_right_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(func(): self.is_busy = false)

# find horizontal matchables
func find_horizontal_matchables():
	var tiles = []
	for x in range(self.tile.x, self.tile.x + 5):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break
		if tile.chip.is_busy: break
		if tile.chip.is_busy: break
		if tile.chip.kind == self.kind: 
			tiles.append(tile)	
			
	for x in range(self.tile.x, self.tile.x - 5, -1):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break
		if tile.chip.is_busy: break
		if tile.chip.kind == self.kind: 
			tiles.append(tile)	
			
	return tiles	

# find horizontal matchables
func find_vertical_matchables():
	var tiles = []
	
	for x in range(self.tile.y, self.tile.y + 5):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break
		if tile.chip.is_busy: break
		if tile.chip.kind == self.kind: 
			tiles.append(tile)	
			
	for x in range(self.tile.y, self.tile.y - 5, -1):
		var tile = self.board.tile_at(x, self.tile.y)
		if tile == null: break
		if tile.chip == null: break
		if tile.chip.is_busy: break	
		if tile.chip.kind == self.kind: 
			tiles.append(tile)	
			
	return tiles		

# find match
func find_match(pending: bool) -> Dictionary:
	var horizontal = find_horizontal_matchables()
	var vertical = find_vertical_matchables()
	
	if horizontal.size() == 4:
		return {"tail": horizontal, "source": self, "is_pending": pending, "out": "color_bomb"}
	elif vertical.size() == 4:
		return {"tail": vertical, "source": self, "is_pending": pending, "out": "color_bomb"}
	elif horizontal.size() == 3:
		return {"tail": horizontal, "source": self, "is_pending": pending, "out": "horizontal_arrow"}
	elif vertical.size() == 3:
		return {"tail": horizontal, "source": self, "is_pending": pending, "out": "vertical_arrow"}
	elif horizontal.size() == 2:
		return {"tail": horizontal, "source": self, "is_pending": pending, "out": "empty"}
	elif vertical.size() == 2:
		return {"tail": horizontal, "source": self, "is_pending": pending, "out": "empty"}

# tick
func tick() -> void:
	try_fall()
