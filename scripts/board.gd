# m3 board
class_name Board
extends Node2D

# the level data
var level_data: Dictionary = {
	"width": 3,
	"height": 6,
	"tiles": [
		{ "x": 2, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },		
		{ "x": 1, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },		
		{ "x": 1, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },		
		{ "x": 2, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },		
		{ "x": 1, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
		{ "x": 1, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
		{ "x": 0, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
	]
}
# prefabs
@export var prefabs: Dictionary
# defines, is board input
# is enabled
@export var is_freezed: bool
# tiles array, contains tiles
# displayed in a scene
@export var tiles: Array
# width and height
var width: int
var height: int
# offsets
@export var board_offset: Vector2
@export var cell_offset: Vector2
# tween durations
@export var fall_tween_duration: float
# matches array, contains matches
@export var matches: Array
# randomization
@onready var random: Random = $Random
# chip groups
var chip_groups: Dictionary = {
	"chips": [
		"blue_chip",
		"red_chip",
		"purple_chip",
		"yellow_chip",
		"green_chip"
	]
}

# signals
signal on_swap(first: Tile, second: Tile)
signal on_swap_fail(first: Tile, second: Tile)

# process
func _process(delta: float) -> void:
	tick()

# ready function
func _ready() -> void:
	# init level
	self.width = self.level_data['width']
	self.height = self.level_data['height']
	for tile_data in self.level_data['tiles']:
		# initializing tile
		var tile = instantiate_prefab("tile") as Tile
		tile.init(
			self, 
			tile_data['x'], 
			tile_data['y'], 
			tile_data['is_generator']
		) 
		tile.position = to_point(
			tile_data['x'],
			tile_data['y']
		)
		tiles.append(tile)
		# initializing chip
		var chip_data = tile_data["chip"]
		if chip_data["kind"] != "empty":
			if chip_data["kind"] == "random":
				var kind = self.random_chip()
				var chip = self.instantiate_prefab(
					kind
				) as Chip
				chip.position = to_point(
					tile_data['x'],
					tile_data['y']
				)
				chip.init(
					self, 
					tile,
					kind
				)
				tile.chip = chip
			else:
				var chip = prefabs[chip_data["kind"]] as Chip
				chip.position = to_point(
					tile_data['x'],
					tile_data['y']
				)
				chip.init(
					self, 
					tile, 
					chip_data["kind"]
				)
				tile.chip = chip
	# find all matches
	find_all_matches()

# creates prefab instance
func instantiate_prefab(name: String) -> Node2D:
	assert(prefabs.has(name), "no prefab named: " + name)
	var node = prefabs[name].instantiate()
	add_child(node)
	return node
	

# gets random chip
func random_chip() -> String:
	return random.choice(
		chip_groups['chips']
	)

# returns is all chips are not busy
func is_stable():
	for tile in self.tiles:
		if tile.chip != null:
			if tile.chip.is_busy:
				return false
	return true

# returns is all chips are not busy and can't fall
func is_idle():
	for tile in self.tiles:
		if tile.chip != null:
			if tile.chip.is_busy:
				return false
			if tile.chip.can_fall():
				return false
	return true
	
# checks match is possible
func check_match(m) -> bool:	
	if m["source"].chip != null:
		var tile = m["source"]
		var chip = tile.chip
		if chip.is_busy or chip.can_fall() or !tile.is_flow_stable():
			return false
	else:
		return false
		
	for tile in m["tail"]:
		if tile.chip != null:
			var chip = tile.chip
			if chip.kind != m["source"].chip.kind:
				return false
			if chip.is_busy or chip.can_fall() or !tile.is_flow_stable():
				return false
		else:
			return false
	
	return true
	
# checks match is valid
func check_match_valid(m) -> bool:
	if m["source"].chip == null:
		return false
		
	for tile in m["tail"]:
		if tile.chip != null:
			var chip = tile.chip
			if chip.kind != m["source"].chip.kind:
				return false
		else:
			return false
	
	return true

# completes match
func complete_match(m):
	print("complete match: " + str(m))
	for tile in m["tail"]:
		tile.delete_chip()
	m["source"].delete_chip()
	# todo: add out handle

# finds all matches on the board
func find_all_matches():
	for tile in tiles:
		if tile.chip != null and !tile.chip.is_busy:
			enqueue_match(tile.chip.find_match(true))

# ticks
func tick():
	# waiting for board stability
	if not is_stable(): return 
	# ticking gravity
	for tile in self.tiles:
		tile.tick()
	# ticking matches
	if matches.size() > 0:
		var pending = []
		for m in self.matches:
			if check_match(m):
				complete_match(m)
			elif check_match_valid(m):
				pending.append(m)
		matches.clear()
		matches.append_array(pending)

# enqueues match
func enqueue_match(target):
	if target != null:
		matches.append(target)
					
# tile position to world point
func to_point(x: int, y: int) -> Vector2:
	return self.position + Vector2(
		x + cell_offset.x * x,
		y + cell_offset.y * y
	) + Vector2(
		board_offset.x,
		board_offset.y
	)

# gets tile at coords
func tile_at(x: int, y: int) -> Tile:
	for tile in tiles:
		if tile.x == x and tile.y == y:
			return tile
	return null		
