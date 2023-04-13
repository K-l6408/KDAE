@tool
extends Area2D

var Rot = 0

func setang(ang):
	Rot = ang

func _process(delta):
	global_rotation = lerp_angle(global_rotation, Rot, delta*4)
