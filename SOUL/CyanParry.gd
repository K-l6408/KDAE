extends Area2D
@tool
var arc := 0.

func _process(_delta):
	queue_redraw() 

func _draw():
	draw_circle_arc_poly(Vector2.ZERO, 40, int(arc/2)%720, int(arc)%720, Color("00ffff80"))

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	points_arc.push_back(center)
	var colors = PackedColorArray([color])
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	draw_polygon(points_arc, colors)

func disable():
	$Shape.disabled = true
