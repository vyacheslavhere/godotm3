# input class
class_name BoardInput
extends Node2D

# Текущий выделенный элемент
@export var board: Board;

# инициализация
func _ready():
	self.board = get_node("/root/M3/Board") as Board

# При инпуте
func _input(event: InputEvent) -> void:
	# Если поле заморожено
	if board.is_freezed:
		return
	# При нажатии
	if event is InputEventMouseButton && event.is_pressed():
		# Получаем позицию мышки
		var mouse_position = get_viewport().get_mouse_position()
		
		# Стреляем рэйкастом
		var space_state = get_world_2d().direct_space_state
		var params = PhysicsPointQueryParameters2D.new()
		params.position = mouse_position
		params.collision_mask = 2147483647
		params.exclude = []
		params.collide_with_bodies = true
		params.collide_with_areas = true
			
		# Получаем результаты
		var results = space_state.intersect_point(params, 32)
				
		# Получаем коллайдер
		if results.size() == 1:
			var selected_node = results[0]['collider'].get_node('..');
			if selected_node is Tile:
				var tile = selected_node as Tile
				if tile.chip != null and !tile.chip.is_busy:
					tile.delete_chip()
