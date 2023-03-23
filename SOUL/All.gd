@tool
@icon("res://icons/Soul.svg")

extends CharacterBody2D
class_name Soul

@export var State : SoulState : set = setState
@export_group("Settings")
@export var inverted_controls = false
@export_group("Settings/Red")
@export var slowdown_action := "ui_cancel"
@export_group("Settings/Orange")
@export var dash_action := "ui_accept"
@export_group("Settings/Yellow")
@export var shot_action := "ui_accept"
@export var charged_shots := true
@export var mouse_target := false
@export_group("Settings/Green")
@export var first_shield := true
@export var second_shield := false
@export_group("Settings/Mint")
@export var shrink_action := "ui_cancel"
@export var default_size := 1.
@export_group("Settings/Cyan")
@export var parry_action := "ui_cancel"
@export_group("Settings/Blue")
@export var maximum_jumps := 2
@export_group("Settings/Purple")
@export var line_number = 3
@export var line_spacing = 100
@export var current_line = 0
@export var line_rotation = 0
@export var line_extents : PackedVector2Array = [
	Vector2(-150, 150),
	Vector2(-150, 150),
	Vector2(-150, 150)
]
@onready var purpleStartPos := Vector2(
	position.x,
	position.y - current_line*(line_spacing))
const   tp := preload("res://Assets/Audio/TP.wav")
const   ow := preload("res://Assets/Audio/Ouch.wav")
const   blt = preload("res://SOUL/Bullet.tscn")
const   sht = preload("res://Assets/Audio/Shot.wav")
const chblt = preload("res://SOUL/Charged_Bullet.tscn")
const chsht = preload("res://Assets/Audio/Shot_Charged.wav")
var px = 100
var TPd       := []
var arc       := 0
var iframes   := 0.0
var vel       : Vector2
var pvel      := Vector2.DOWN
var fall      : Vector2
var fallspd   := 0.0
var jumps     := maximum_jumps
var jumping   := false
var dash      := 0.0
var charge    := 0.0
var mintshr   := 0.0
var cyancldwn := 0.0
var plc       : float
var h = false

func _ready():
	plc = current_line
	jumps = maximum_jumps
	var res = SoulState.new()
	ResourceSaver.save(res, "SoulState.tscn")
	setState(State)
	$Trail   .texture = $Sprite.get_texture()
	$Sprite2D.texture = $Sprite.get_texture()

func setState(value):
	if get_parent():
		if value.Green:
			var tw = create_tween()
			tw.tween_property(self, "arc", 360, .5)
			tw.connect("finished", queue_redraw)
		elif State.Green:
			var tw = create_tween()
			tw.tween_property(self, "arc", 0, .5)
			tw.connect("finished", queue_redraw)
	State = value
	audio()

func _draw():
	if not Engine.is_editor_hint():
		if State.value() == SoulState.GREEN:
			draw_circle_arc(Vector2.ZERO, 42.5, 0, 0, arc, Color(0,.5,0))
			draw_circle_arc(Vector2.ZERO, 39.5, 0, 0, arc, Color.BLACK)
		elif State.Green:
			draw_circle_arc(Vector2.ZERO, 42.5, 39.5, 0, arc, Color(0,.5,0,.5))
			draw_circle_arc(Vector2.ZERO, 39.5, 0, 0, arc, Color(0,0,0,.5))

func draw_circle_arc(center, radius, radius2, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PackedVector2Array()
	var colors = PackedColorArray([color])
	for i in range(nb_points + 1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	for i in range(nb_points + 1, 0, -1):
		var angle_point = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius2)
	draw_polygon(points_arc, colors)

func _process(_delta):
	if arc > 0 and arc <= 360:
		queue_redraw()
	$FirstShield.monitoring  = State.Green and first_shield
	$FirstShield.monitorable = State.Green and first_shield
	$FirstShield.visible     = State.Green and first_shield
	$FirstShield.setang(pvel.angle() + PI/2)
	$SecondShield.monitoring  = State.Green and second_shield
	$SecondShield.monitorable = State.Green and second_shield
	$SecondShield.visible     = State.Green and second_shield
	$SecondShield.setang(pvel.angle() - PI/2)
	$Trail.process_material.angle_min = -global_rotation_degrees
	$Trail.process_material.angle_max = -global_rotation_degrees
	$Trail.emitting = State.Orange

func _physics_process(delta):
	$Label.hide()
	process_texture()
	if State.Blue:
		motion_mode = CharacterBody2D.MOTION_MODE_GROUNDED
		if inverted_controls:
			up_direction = Vector2.UP.rotated(global_rotation+PI)
		else:
			up_direction = Vector2.UP.rotated(global_rotation)
	else:
		motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if not Engine.is_editor_hint():
		handle_hitbox(delta)
		var v = vel
		handle_input()
		if State.Red:
			velocity = velocity.rotated(global_rotation)
			vel = vel.rotated(global_rotation)
			if Input.is_action_pressed(slowdown_action):
				velocity /= 2
		if State.Blue:
			var j
			if State.Orange:
				jumps = int(is_on_floor())
				j = -pvel.rotated(-global_rotation).y
				var pj = -v.rotated(-global_rotation).y
				if j < -10 and pj > -10:
					slam(rotation_degrees, 300)
				j = 100
			else:
				j = -vel.rotated(-global_rotation).y
				if j < 0:
					j = 0
					jumping = false
			if is_on_floor():
				jumps = maximum_jumps
				fallspd = 0
				jumping = false
				pvel = Vector2(pvel.rotated(-global_rotation).x, -100).rotated(global_rotation)
			elif jumps == maximum_jumps:
				jumps -= 1
			if is_on_ceiling():
				jumps = 0
				fallspd = abs(fallspd)
			if j > 10:
				if jumping:
					fallspd -= (3 - fallspd) * delta * 2.5
				elif jumps > 0 or maximum_jumps < 0:
					fallspd = -150
					jumps -= 1
					jumping = true
			else:
				jumping = false
			if fallspd > 500:
				fallspd = 500
			var lt = jumps + 1 - int(is_on_floor())
			if lt > 1:
				$Label.show()
				$Label.text = str(lt)
			elif lt < 0:
				$Label.show()
				$Label.text = "∞"
			else:
				$Label.hide()
			fallspd += 100 * delta * 4
			var p = velocity.rotated(-global_rotation)
			p.y = 0
			velocity = p.rotated(global_rotation)
			velocity += fallspd * (Vector2.DOWN.rotated(global_rotation))
		if State.Orange:
			set_collision_layer_value(2, dash < 0)
			set_collision_mask_value(2, dash < 0)
			if dash > -1:
				dash -= delta
			elif Input.is_action_just_pressed(dash_action):
				dash = .5
			if dash > 0:
				if State.Blue:
					var p = velocity.rotated(-global_rotation)
					p.x /= .375
					velocity = p.rotated(global_rotation)
				else:
					velocity /= .375
			if State.Purple:
				if abs(pvel.rotated(-global_rotation - deg_to_rad(line_rotation)).x) <= 10:
					pvel += Vector2(px, 0).rotated(global_rotation + deg_to_rad(line_rotation))
				else:
					px = pvel.rotated(-global_rotation - deg_to_rad(line_rotation)).x
			elif State.Blue:
				if pvel.rotated(-global_rotation).x == 0:
					pvel += Vector2(px, 0).rotated(global_rotation)
				else:
					px = pvel.rotated(global_rotation).x
		if State.Cyan:
			if State.Blue:
				var p = velocity.rotated(-global_rotation)
				p.x /= 2
				velocity = p.rotated(global_rotation)
			else:
				velocity /= 2
			if cyancldwn < delta:
				if Input.is_action_just_pressed(parry_action):
					$Parry/Shape.disabled = false
					$Parry.arc = 0
					var Tw = create_tween()
					Tw.connect("finished", $Parry.disable)
					Tw.tween_property($Parry, "arc", 1440, .7)
					iframes += .7
					cyancldwn = 1.5
			else:
				cyancldwn -= delta
		if State.Purple:
			if State.Blue:
				line_rotation = rotation_degrees - 90
			var temp = (position-purpleStartPos).rotated(deg_to_rad(-line_rotation))+purpleStartPos
			if State.Orange and temp.x != clamp(temp.x - purpleStartPos.x,\
			line_extents[current_line].x, line_extents[current_line].y) + purpleStartPos.x:
				pvel -= Vector2(px, 0).rotated(global_rotation + deg_to_rad(line_rotation))
				px *= -1
				velocity *= -1
			temp.x = clamp(temp.x - purpleStartPos.x,
			line_extents[current_line].x, line_extents[current_line].y) + purpleStartPos.x
			temp.y = lerp(temp.y, (current_line * line_spacing) + purpleStartPos.y, delta * 5)
			position = (temp-purpleStartPos).rotated(deg_to_rad(line_rotation))+purpleStartPos
			velocity.x = velocity.rotated(deg_to_rad(-line_rotation)).x
			velocity.y = 0
			velocity = velocity.rotated(deg_to_rad(line_rotation))
			if current_line > 0:
				if vel.rotated(deg_to_rad(-line_rotation)).y < -70 and not v.rotated(deg_to_rad(-line_rotation)).y < -70 \
				and temp.x - purpleStartPos.x == \
				clamp(temp.x - purpleStartPos.x, line_extents[current_line -1].x, line_extents[current_line -1].y):
					current_line -= 1
			if current_line < line_number - 1:
				if vel.rotated(deg_to_rad(-line_rotation)).y > 70 and not v.rotated(deg_to_rad(-line_rotation)).y > 70 \
				and temp.x - purpleStartPos.x == \
				clamp(temp.x - purpleStartPos.x, line_extents[current_line +1].x, line_extents[current_line +1].y):
					current_line += 1
		if State.Mint:
			if mintshr > -2:
				mintshr -= delta
			elif Input.is_action_just_pressed(shrink_action):
				mintshr = 3
			if mintshr > 0:
				scale.x = lerp(scale.x, default_size / 2, delta)
				scale.y = lerp(scale.y, default_size / 2, delta)
				if State.Blue:
					var p = velocity.rotated(-global_rotation)
					p.x *= 3
					velocity = p.rotated(global_rotation)
				else:
					velocity *= 3
				if (mintshr + .5) - floor(mintshr + .5) < delta:
					modulate.v = 0
				elif modulate.v < 1:
					modulate.v += delta * 2
			else:
				scale.x = lerp(scale.x, default_size, delta)
				scale.y = lerp(scale.y, default_size, delta)
		if State.Yellow:
			if mouse_target:
				rotation = get_global_mouse_position().angle_to_point(global_position) + PI/2
			$Aud2.volume_db = log(charge) / 10 + 1
			$Aud2.pitch_scale = min(charge * 2, 1) + 0.001
			if Input.is_action_pressed(shot_action):
				charge += delta
			if Input.is_action_just_released(shot_action):
				shoot()
			$Charge.modulate.a = min((charge - .2) * 2, 1)
		if State.value() != SoulState.GREEN:
			move_and_slide()
			var collision = get_last_slide_collision()
			if is_on_wall() and collision and State.Orange:
				pvel = pvel.bounce(collision.get_normal())
	if State.Purple:
		plc = lerp(plc, float(current_line), delta*7)
		line_extents.resize(line_number)
		$Lines.position = Vector2(0,0)
		$Lines.rotation_degrees = line_rotation - rotation_degrees
		var lc = $Lines.get_child_count()
		if lc < line_number:
			var L = Line2D.new()
			$Lines.add_child(L)
		if lc > line_number:
			$Lines.get_child(0).queue_free()
		for c in min($Lines.get_child_count(), line_number):
			var temp = (position-purpleStartPos).rotated(deg_to_rad(-line_rotation))
			var L = $Lines.get_child(c)
			L.default_color = Color("9c279f")
			L.width = 2
			L.points = [Vector2(line_extents[c].x, 0), Vector2(line_extents[c].y, 0)]
			L.position = Vector2(-temp.x, (c - plc) * line_spacing)
			if line_extents[c] == Vector2(0,0):
				line_extents[c] = Vector2(-150,150)
	else:
		for L in $Lines.get_children():
			L.queue_free()

func process_texture():
	var total = int(State.Red) + int(State.Orange) + int(State.Yellow) + int(State.Green) + \
	int(State.Mint) + int(State.Cyan) + int(State.Blue) + int(State.Purple)
	var i = 0.0
	for j in $Sprite.get_children():
		if State.get(j.name):
			j.show()
			j.region_rect.position.x = i / total * 19.
			i += 1
			j.region_rect.size.x = 19. / total
		else:
			j.hide()
		j.region_rect.size.y = 20
		j.region_rect.position.y = 0
		j.position = j.region_rect.position

func audio():
	if get_parent():
		$Aud2.playing = State.Yellow and not Engine.is_editor_hint()

func shoot():
	var bullet
	if charge > 0.4 and charged_shots:
		bullet = chblt.instantiate()
		$Aud.stream = chsht
	else:
		bullet =   blt.instantiate()
		$Aud.stream =   sht
	$Aud.volume_db = 0
	$Aud.play()
	get_parent().add_child(bullet)
	bullet.start(position + Vector2(0,20).rotated(rotation),rotation,self)
	bullet.global_scale = global_scale / 1.5
	charge = 0

func slam(rot8ion, speed = 200):
	State.Blue = true
	rotation_degrees = rot8ion
	fallspd = speed

func handle_input():
	vel = Input.get_vector("left", "right", "up", "down") * 150
	if inverted_controls:
		vel *= -1
	if State.Orange or State.Green:
		if vel != Vector2(0,0):
			if State.Red:
				pvel = vel.rotated(global_rotation) * .75
			else:
				pvel = vel * .75
		if State.Orange:
			velocity = pvel
	if State.value() != SoulState.GREEN and not State.Orange:
		velocity = vel

func handle_hitbox(delta):
	if iframes == 0:
		for Obj in $TP.get_overlapping_areas():
			if (zero(Obj.get("atkType")) & Atk.Blue and not get_velocity() == Vector2.ZERO) or \
			(zero(Obj.get("atkType")) & Atk.Orange   and get_velocity() == Vector2.ZERO):
				if TPd.has(Obj):
					emit_signal("TP", delta)
					if not ($Aud.playing or $Aud.volume_db > -1):
						$"TP Sprite".modulate.a = .25
						$Aud.stream = tp
						$Aud.volume_db = -10
						$Aud.play()
				else:
					emit_signal("TP", 0.75)
					TPd.append(Obj)
					$"TP Sprite".modulate.a = .75
					$Aud.stream = tp
					$Aud.volume_db = -0.5
					$Aud.play()
		for Obj in $HitBox.get_overlapping_areas():
			if (zero(Obj.get("atkType")) & Atk.Blue and not get_velocity() == Vector2.ZERO) or \
			(zero(Obj.get("atkType")) & Atk.Orange   and get_velocity() == Vector2.ZERO):
				emit_signal("hurt", zero(Obj.get("damage")))
				iframes = 2
				$Aud.stop()
				$Aud.stream = ow
				$Aud.volume_db = 0
				$Aud.play()
	else:
		for Obj in $HitBox.get_overlapping_areas():
			if zero(Obj.get("delete")):
				Obj.queue_free()
	if State.Green:
		for Obj in $FirstShield.get_overlapping_areas():
			if zero(Obj.get("atkType")) & Atk.Block:
				Obj.Block()
	if State.Cyan:
		for Obj in $Parry.get_overlapping_areas():
			if zero(Obj.get("atkType")) & Atk.Parry:
				Obj.Parry()

func zero(arg):
	if arg:
		return arg
	else:
		return 0

signal hurt(damage)
signal TP(amount)
signal emotion(new)
