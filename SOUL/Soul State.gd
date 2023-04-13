@icon("res://icons/SoulState.svg")

extends Resource
class_name SoulState

@export var Red := false
@export var Orange := false
@export var Yellow := false
@export var Green := false
@export var Cyan := false
@export var Blue := false
@export var Purple := false

const RED := 1
const ORANGE := 2
const YELLOW := 4
const GREEN := 8
const CYAN := 16
const BLUE := 32
const PURPLE := 64

func _init(val := 0):
	Red = val & RED
	Orange = val & ORANGE
	Yellow = val & YELLOW
	Green = val & GREEN
	Cyan = val & CYAN
	Blue = val & BLUE
	Purple = val & PURPLE

func value():
	return int(Purple) * PURPLE + int(Blue) * BLUE + int(Cyan) * CYAN + \
	int(Green) * GREEN + int(Yellow) * YELLOW + int(Orange) * ORANGE + int(Red) * RED
