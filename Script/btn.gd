extends Node

func NumBool(arg : bool):
	return 1 if arg else 0

# DOWN
func d(arg : String):
	return NumBool(Input.is_action_pressed(arg))

# PRESSED
func p(arg : String):
	return NumBool(Input.is_action_just_pressed(arg))

# RELEASED
func r(arg : String):
	return NumBool(Input.is_action_just_released(arg))