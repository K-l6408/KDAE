extends Area2D

var H = 10
var Obj : Node

func _process(delta):
	var vel = Vector2.DOWN.rotated(rotation) * 500 * delta
	vel.x *= global_scale.x
	vel.y *= global_scale.y
	position += vel

func start(pos, ang, obj):
	var sc = scale.x
	position = pos
	rotation = ang
	scale.x = 0
	var tw = create_tween()
	if tw:
		scale.x = 0
		tw.tween_property(self, "scale:x", sc, 0.6)
	Obj = obj

func Collision(area):
	var h = area.get("atkType")
	if h == null:
		h = 0
	if h & Atk.Shoot:
		area.Shoot()
		Obj.emit_signal("TP", 1)
		H -= area.Pow
		if H <= 0:
			queue_free()
