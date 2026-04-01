# m3 board
class_name Board
extends Node2D

# Test level data
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

# All chips prefabs
@export var prefabs: Dictionary

# Is board freezed?
@export var is_freezed: bool

# Tiles array, contains all the board tiles
@export var tiles: Array[Tile]

# Width and height
var width: int
var height: int

# Board offsets
@export var board_offset: Vector2
@export var cell_offset: Vector2

# Tween durations
@export var fall_tween_duration: float
@export var die_tween_duration: float
@export var die_tween_scale_factor: float
@export var swap_tween_duration: float
@export var swap_fail_tween_duration: float

# Found matches array
@export var matches: Array[Variant]

# Seeded random
@onready var random: Random = $Random

# Chip groups
var chip_groups: Dictionary = {
	"chips": [
		"blue_chip",
		"red_chip",
		"purple_chip",
		"yellow_chip",
		"green_chip"
	],
	"swaps_with_any": [
		"bomb",
		"color_bomb",
		"vertical_arrow",
		"horizontal_arrow"
	]
}

# Ticks every frame
func _process(delta: float) -> void:
	tick()

# Initializes board on start
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
				spawn_chip(kind, tile)
			else:
				var kind = self.random_chip()
				spawn_chip(chip_data['kind'], tile)
	# find all matches
	find_all_matches()

# Ccreates prefab instance
func instantiate_prefab(name: String) -> Node2D:
	assert(prefabs.has(name), "no prefab named: " + name)
	var node = prefabs[name].instantiate()
	add_child(node)
	return node

# Gets random chip
func random_chip() -> String:
	return random.choice(
		chip_groups['chips']
	)

# Returns true if all chips are not busy
func is_stable():
	for tile in self.tiles:
		if tile.chip != null:
			if tile.chip.is_busy:
				return false
	return true

# Returns true if all chips are not busy and can't fall
func is_idle():
	for tile in self.tiles:
		if tile.chip != null:
			if tile.chip.is_busy:
				return false
			if tile.chip.can_fall():
				return false
	return true

# Checks match is possible
func check_match_possibility(m: Dictionary) -> bool:
	# Checking source chip exists and this chip can't fall and it's tile has stable flow
	if m["source"].chip != null:
		var tile = m["source"]
		var chip = tile.chip
		if chip.is_busy or chip.can_fall() or !tile.is_flow_stable():
			return false
	else:
		return false
	
	# Checking tail chips existence and that chips can't fall and it's tiles has stable flow
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
	
# Checks match is valid
func check_match_valid(m: Dictionary) -> bool:
	# If source has no chip -> match is not valid
	if m["source"].chip == null:
		return false
		
	# Checking tail tiles
	for tile in m["tail"]:
		# If tile has chip
		if tile.chip != null:
			# If tail chip kind is not a source chip kind -> match is not valid
			var chip = tile.chip
			if chip.kind != m["source"].chip.kind:
				return false
				
		# If tile has no chip
		else:
			return false
	
	return true

# Damages chip on tile
func damage(tile: Tile):
	if tile.chip != null and !tile.chip.is_busy:
		tile.chip.damage.emit()

# Performs radial explosion
func explode_radius(target: Tile, radius: int):
	for x in range(target.x - radius, target.x + radius + 1):
		for y in range(target.y - radius, target.y + radius + 1):
			var tile = tile_at(x, y)
			if tile != null:
				damage(tile)

# Spawns chip with kind on tile
func spawn_chip(kind: String, tile: Tile):
	var chip = instantiate_prefab(
		kind
	) as Chip
	chip.init(self, tile, kind)
	chip.position = tile.position
	tile.chip = chip

# Completes match
func complete_match(m: Dictionary):
	# Deleting tail chips
	for tile in m["tail"]:
		tile.delete_chip()
		
	# If nothing out, deleting source chip
	if m["out"] == "empty":
		m["source"].delete_chip()
		
	# Else deleting source chip and spawning needed out chip
	else:
		m["source"].delete_chip_immediate()
		spawn_chip(m["out"], m["source"])
		
# Finds all matches on the board
func find_all_matches():
	for tile in tiles:
		if tile.chip != null and !tile.chip.is_busy:
			enqueue_match(tile.chip.find_match(true))

# Ticks all the matches
func tick_matches():
	# If at least one match created
	if matches.size() > 0:
		# Sorting matches by descending of tail size
		matches.sort_custom(
			func(a,b):
				if a['tail'].size() > b['tail'].size():
					return true
				return false
		)
		
		# Processing matches
		var pending = []
		for m in self.matches:
			# Pending matches (non-player initiated)
			if m['is_pending']:
				# If match can be done now, completing it
				if check_match_possibility(m):
					complete_match(m)
					
				# Otherwise, if match is valid, pending it 
				# to the next tick check
				elif check_match_valid(m):
					pending.append(m)
					
			# Playing initiated matches
			else:
				if check_match_valid(m):
					complete_match(m)
					
		# Clearing matches
		matches.clear()
		
		# Appending pending matches
		matches.append_array(pending)

# Ticks all the board
func tick():
	# Waiting for board stability and board unfreezing
	if not is_stable(): return 
	if is_freezed: return
	
	# Ticking only generator-tiles: generation
	for tile in self.tiles:
		if tile.is_generator:
			tile.tick()
			
	# Ticking all the tiles: gravity
	for tile in self.tiles:
		tile.tick()
		
	# Ticking matches
	self.tick_matches()

# Enqueues match
func enqueue_match(target):
	if target != null:
		matches.append(target)

# Creates visual swap
func visual_swap(a: Chip, b: Chip, match_a, match_b):
	# Tween `a`
	var tween_a = create_tween()
	tween_a.set_ease(Tween.EASE_IN_OUT)
	tween_a.set_trans(Tween.TRANS_QUAD)
	tween_a.tween_property(a, "position", b.position, swap_tween_duration)	
	tween_a.tween_callback(
		func():
			a.is_busy = false
			a.swap.emit(b)
			self.enqueue_match(match_a)
	)
	
	# Tween `b`
	var tween_b = create_tween()
	tween_b.set_ease(Tween.EASE_IN_OUT)
	tween_b.set_trans(Tween.TRANS_QUAD)
	tween_b.tween_property(b, "position", a.position, swap_tween_duration)	
	tween_b.tween_callback(
		func():
			b.is_busy = false
			b.swap.emit(a)
			self.enqueue_match(match_b)
	)

# Creates visual swap fail
func visual_swap_fail(a: Chip, b: Chip):
	# Tween `a`
	var tween_a = create_tween()
	tween_a.set_ease(Tween.EASE_IN_OUT)
	tween_a.set_trans(Tween.TRANS_QUAD)
	tween_a.tween_property(a, "position", b.position, swap_fail_tween_duration)
	tween_a.tween_property(a, "position", a.position, swap_fail_tween_duration)
	tween_a.tween_callback(
		func():
			a.is_busy = false
	)
	
	# Tween `b`
	var tween_b = create_tween()
	tween_b.set_ease(Tween.EASE_IN_OUT)
	tween_b.set_trans(Tween.TRANS_QUAD)
	tween_b.tween_property(b, "position", a.position, swap_fail_tween_duration)
	tween_b.tween_property(b, "position", b.position, swap_fail_tween_duration)
	tween_b.tween_callback(
		func():
			b.is_busy = false
	)

# Performs input action
func input(a: Chip, b: Chip):
	# Setting both chips business to true
	a.is_busy = true
	b.is_busy = true
	
	# Getting chip tiles
	var tile_a = a.tile
	var tile_b = b.tile
	
	# Swapping tiles
	a.tile = tile_b
	b.tile = tile_a
	tile_a.chip = b
	tile_b.chip = a
	
	# Checking matches
	var match_a = a.find_match(false)
	var match_b = b.find_match(false)
	
	# If swaps with any
	if a.kind in chip_groups["swaps_with_any"] or b.kind in chip_groups["swaps_with_any"]:
		# Swapping
		visual_swap(a, b, match_a, match_b)
		
	# Otherwise, checking at least one match created
	elif match_a != null or match_b != null:
		# Swapping
		visual_swap(a, b, match_a, match_b)
		
	# If not, returning old positions back
	else:
		# Turning back tiles and chips states
		a.tile = tile_a
		b.tile = tile_b
		tile_a.chip = a
		tile_b.chip = b
		a.is_busy = false
		b.is_busy = false
		
		# Visual swap fail
		visual_swap_fail(a, b)

# Converts tile position to world point
func to_point(x: int, y: int) -> Vector2:
	return self.position + Vector2(
		x + cell_offset.x * x,
		y + cell_offset.y * y
	) + Vector2(
		board_offset.x,
		board_offset.y
	)

# Gets tile at coords
func tile_at(x: int, y: int) -> Tile:
	for tile in tiles:
		if tile.x == x and tile.y == y:
			return tile
	return null		
