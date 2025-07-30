# m3 board
class_name Board
extends Node2D

# the level data
var level_data: Dictionary = {
	"width": 3,
	"height": 3,
	"tiles": [
		{ "x": 0, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
		{ "x": 1, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
		{ "x": 2, "y": 0, "chip": { "kind": "random", "options": {} }, "is_generator": true },
		{ "x": 0, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 1, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 2, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 3, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 4, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 0, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 1, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },
		{ "x": 2, "y": 5, "chip": { "kind": "random", "options": {} }, "is_generator": false },		
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

# ticks
func tick():
	for tile in self.tiles:
		tile.tick()

# process
func _process(delta: float) -> void:
	tick()

# ready function
func _ready() -> void:
	# init level
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
							
# Tile position to world point
func to_point(x: int, y: int) -> Vector2:
	return self.position + Vector2(
		x + cell_offset.x * x,
		y + cell_offset.y * y
	) + Vector2(
		board_offset.x,
		board_offset.y
	)

# Gets tile at
func tile_at(x: int, y: int) -> Tile:
	for tile in tiles:
		if tile.x == x and tile.y == y:
			return tile
	return null		
