@tool
extends Area2D

var Rot = 0

func setang(ang):
	Rot = ang

func _process(delta):
	rotation = lerp_angle(rotation, Rot, delta*4)
