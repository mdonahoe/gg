extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var btn1 = get_node("ColorRect/Button1")
onready var btn2 = get_node("ColorRect/Button2")
onready var btn3 = get_node("ColorRect/Button3")
onready var btn4 = get_node("ColorRect/Button4")
onready var btn5 = get_node("ColorRect/Button5")
onready var btn6 = get_node("ColorRect/Button6")
onready var btn7 = get_node("ColorRect/Button7")
onready var btn8 = get_node("ColorRect/Button8")
onready var btn9 = get_node("ColorRect/Button9")
onready var btn10 = get_node("ColorRect/Button10")
onready var btn11 = get_node("ColorRect/Button11")
onready var btn12 = get_node("ColorRect/Button12")

onready var forward_action = get_node("Forward")
onready var turn_left_action = get_node("TurnLeft")
onready var turn_right_action = get_node("TurnRight")
onready var kick_action = get_node("Kick")
onready var light_action = get_node("Light")

onready var draggable_actions = [forward_action, turn_left_action, turn_right_action, kick_action, light_action]

onready var btns = [btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btn10, btn11, btn12]

onready var bot = get_node("../Bot")

onready var dragger = get_node("Dragger")


# Called when the node enters the scene tree for the first time.
func _ready():
	print("btn1", btns)
	dragger.visible = false
	var i = 0
	for btn in btns:
		btn.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	dragger.rect_position = get_global_mouse_position()
	if Input.is_action_just_pressed("click"):
		dragger.visible = true
		for btn in btns:
			if btn.visible:
				var pos = btn.get_local_mouse_position()
				var rect = Rect2(Vector2.ZERO, btn.rect_size)
				var mouseIsOverButton = rect.has_point(pos)
				if mouseIsOverButton:
					dragger.text = btn.text
					btn.text = ""
					
		for act in draggable_actions:
			var pos = act.get_local_mouse_position()
			var rect = Rect2(Vector2.ZERO, act.rect_size)
			var mouseIsOverButton = rect.has_point(pos)
			if mouseIsOverButton:
				dragger.text = act.text
				
	elif Input.is_action_just_released("click"):
		bot.actions = []
		for btn in btns:
			if btn.visible:
				var pos = btn.get_local_mouse_position()
				var rect = Rect2(Vector2.ZERO, btn.rect_size)
				var mouseIsOverButton = rect.has_point(pos)
				if mouseIsOverButton:
					btn.text = dragger.text
					dragger.text = ""
			bot.actions.append(btn.text)
					
	elif not Input.is_action_pressed("click"):
		dragger.visible = false
		
	if bot.action_index > -1 and bot.action_index < len(btns):
		for btn in btns:
			btn.disabled = true
		var btn = btns[bot.action_index]
		btn.disabled = false
