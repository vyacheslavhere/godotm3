# board input class
class_name BoardInput
extends Node2D

# selected tile
@export var selected: Tile;
# match3 board
@export var board: Board;
# last mouse position
@export var last_mouse_position: Vector2

# initialization
func _ready():
	self.board = get_node("/root/M3/Board") as Board

# input
func _input(event: InputEvent) -> void:
	# if board isn't idle, return
	if !board.is_idle():
		return
		
	# mouse button down
	if event is InputEventMouseButton && event.is_pressed():
		# getting mouse position
		var mouse_position = get_viewport().get_mouse_position()
		
		# hitting raycast
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = mouse_position
		params.collision_mask = 2147483647
		params.exclude = []
		params.collide_with_bodies = true
		params.collide_with_areas = true
		
		# getting results
		var results = space_state.intersect_point(params, 32)
				
		# processing results
		if results.size() != 1: return
		var selected_node = results[0]['collider'].get_node('..');
	
		# if selected_node is tile, processing
		if selected_node is Tile:
			# getting node as tile
			var tile = selected_node as Tile
			if tile.chip == null: return
			# asserting that selected is null
			assert(selected == null, "selected isn't null on mouse down")
			# selecting
			self.selected = tile
			# last mouse position
			self.last_mouse_position = mouse_position
	# mouse button up
	elif event is InputEventMouseButton && !event.is_pressed():
		# if selected is null, skip
		if self.selected == null:
			return
		# getting mouse position
		var mouse_position = get_viewport().get_mouse_position()
		# getting direction of swipe
		var direction = last_mouse_position - mouse_position
		# horizontal
		if abs(direction.x) > abs(direction.y):
			if direction.x > 0:
				var tile = self.board.tile_at(
					selected.x - 1,
					selected.y
				)
				if tile != null:
					if tile.chip != null: 
						board.swap_chips(
							self.selected.chip,
							tile.chip
						)
				self.selected = null
			else:
				var tile = self.board.tile_at(
					selected.x + 1,
					selected.y
				)
				if tile != null:
					if tile.chip != null: 
						board.swap_chips(
							self.selected.chip,
							tile.chip
						)
				self.selected = null
		# vertical
		else:
			if direction.y > 0:
				var tile = self.board.tile_at(
					selected.x,
					selected.y - 1
				)
				if tile != null:
					if tile.chip != null: 
						board.swap_chips(
							self.selected.chip,
							tile.chip
						)
				self.selected = null		
			else:
				var tile = self.board.tile_at(
					selected.x,
					selected.y + 1
				)
				if tile != null:
					if tile.chip != null: 
						board.swap_chips(
							self.selected.chip,
							tile.chip
						)
				self.selected = null
