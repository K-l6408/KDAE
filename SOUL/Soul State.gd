extends Resource

class_name SoulState

@export var Red := false
@export var Orange := false
@export var Yellow := false
@export var Green := false
@export var Mint := false
@export var Cyan := false
@export var Blue := false
@export var Purple := false

const RED := 1
const ORANGE := 2
const YELLOW := 4
const GREEN := 8
const MINT := 16
const CYAN := 32
const BLUE := 64
const PURPLE := 128

func _init(val := 0):
	Red = val & 1
	Orange = val & 2
	Yellow = val & 4
	Green = val & 8
	Mint = val & 16
	Cyan = val & 32
	Blue = val & 64
	Purple = val & 128

func value():
	return int(Purple) * 128 + int(Blue) * 64 + int(Cyan) * 32 + int(Mint) * 16 + \
	int(Green) * 8 + int(Yellow) * 4 + int(Orange) * 2 + int(Red)
