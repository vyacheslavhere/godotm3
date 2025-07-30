# chip class
class_name Chip
extends Node2D

# tile
var board: Board
var tile: Tile
var kind: String
var is_busy: bool

# settings
@export var is_fall_enabled: bool
@export var is_swap_enabled: bool
@export var is_break_arrows: bool

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
	if !is_fall_enabled: return
	if is_busy: return
	else:
		if can_fall_down():
			# setting busy to true
			self.is_busy = true
			
			# setting old tile chip to null
			self.tile.chip = null
			# getting under tile
			var under_tile = self.board.tile_at(tile.x, tile.y + 1)
			# setting under tile chip to self
			under_tile.chip = self
			# setting self tile to under tile
			self.tile = under_tile
			
			# visual tween
			var tween = create_tween()
			tween.tween_property(
				self, 
				"position", 
				under_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(
				func(): 
					self.is_busy = false
					board.enqueue_match(find_match(false))
			)
			
		elif can_fall_left_diag():
			# setting busy to true
			self.is_busy = true
			
			# setting old tile chip to null
			self.tile.chip = null
			# getting under left tile
			var under_left_tile = self.board.tile_at(tile.x - 1, tile.y + 1)
			# setting under left tile chip to self
			under_left_tile.chip = self
			# setting self tile to under left tile
			self.tile = under_left_tile
			
			# visual tween
			var tween = create_tween()
			tween.tween_property(
				self, 
				"position", 
				under_left_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(
				func(): 
					self.is_busy = false
					board.enqueue_match(find_match(false))
			)
			
		elif can_fall_right_diag():
			# setting busy to true
			self.is_busy = true
			
			# setting old tile chip to null
			self.tile.chip = null
			# getting under right tile			
			var under_right_tile = self.board.tile_at(tile.x + 1, tile.y + 1)
			# setting under right tile chip to self			
			under_right_tile.chip = self
			# setting self tile to under right tile			
			self.tile = under_right_tile
			
			# visual tween
			var tween = create_tween()
			tween.tween_property(
				self, 
				"position",
				under_right_tile.position, 
				board.fall_tween_duration
			)
			tween.tween_callback(
				func(): 
					self.is_busy = false
					board.enqueue_match(find_match(false))
			)

# find horizontal matchables
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

# find horizontal matchables
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

# find match
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

# tick
func tick() -> void:
	try_fall()
