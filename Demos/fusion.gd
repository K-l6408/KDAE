@tool
extends Node2D

@export var State : SoulState
@export var Rotation : float

func _process(_delta):
	$Box/Hide/Soul.State = State
	$Box/Hide/Soul.rotation_degrees = Rotation
