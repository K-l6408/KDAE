extends "BulletPongon.gd"
@tool
@export var Quality  := 30
@export var Size     := 150.0
@export var InEditor := false

func _ready():
	if not InEditor:
		SmoothPongon.resize(Quality)
		for a in Quality:
			SmoothPongon[a] = Vector2(Size, 0).rotated((a/float(Quality))*TAU)

func _process(_delta):
	if InEditor:
		Polygon.resize(Quality)
		for a in Quality:
			Polygon[a] = Vector2(Size, 0).rotated((a/float(Quality))*TAU)
