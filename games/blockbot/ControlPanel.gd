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

onready var btns = [btn1, btn2, btn3, btn4, btn5, btn6, btn7, btn8, btn9, btn10, btn11, btn12]

onready var bot = get_node("../Bot")


# Called when the node enters the scene tree for the first time.
func _ready():
	print("btn1", btns)
	var i = 0
	for btn in btns:
		if i < len(bot.actions):
			btn.text = bot.actions[i]
			btn.disabled = true
		else:
			btn.visible = false
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bot.action_index > -1 and bot.action_index < len(btns):
		for btn in btns:
			btn.disabled = true
		var btn = btns[bot.action_index]
		btn.disabled = false
