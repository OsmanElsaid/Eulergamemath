extends Control

@onready var code_input = $VBoxContainer/CodeInput
@onready var enter_button = $VBoxContainer/EnterButton
@onready var error_label = $VBoxContainer/ErrorLabel
@onready var title_label = $VBoxContainer/TitleLabel

const CORRECT_CODE = "39278"

func _ready():
	# Set up the UI
	title_label.text = "EULER MATH GAME"
	error_label.text = ""
	error_label.modulate = Color.RED
	
	# Connect signals
	enter_button.pressed.connect(_on_enter_button_pressed)
	code_input.text_submitted.connect(_on_code_submitted)
	
	# Focus on the input field
	code_input.grab_focus()

func _on_enter_button_pressed():
	_check_code()

func _on_code_submitted(text: String):
	_check_code()

func _check_code():
	var entered_code = code_input.text.strip_edges()
	
	if entered_code == CORRECT_CODE:
		# Code is correct, transition to main menu
		error_label.text = "Access Granted!"
		error_label.modulate = Color.GREEN
		
		# Wait a moment then change scene
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	else:
		# Code is incorrect
		error_label.text = "Access Denied! Incorrect code."
		error_label.modulate = Color.RED
		code_input.clear()
		code_input.grab_focus()

func _input(event):
	# Allow pressing Enter to submit
	if event.is_action_pressed("ui_accept"):
		_check_code()