# randomization class
class_name Random
extends Node

# seeded random
var seeded_randomizer = RandomNumberGenerator.new()

# groups of random
@export var randomization_groups: Dictionary = {}

# setting up seed
func init_with_seed(seed: int) -> void:
	seeded_randomizer.seed = seed

# getting random range
func range(a: int, b: int) -> int:
	return seeded_randomizer.randi_range(a, b)

# choices random value in list
func choice(array: Array):
	return array[seeded_randomizer.randi_range(0, array.size()-1)]
