extends Control

@onready var title_label = $VBoxContainer/TitleLabel
@onready var online_button = $VBoxContainer/ButtonContainer/OnlineButton
@onready var local_button = $VBoxContainer/ButtonContainer/LocalButton
@onready var ai_button = $VBoxContainer/ButtonContainer/AIButton
@onready var exit_button = $VBoxContainer/ButtonContainer/ExitButton

func _ready():
	# Set up the UI
	title_label.text = "EULER MATH GAME"
	
	# Connect button signals
	online_button.pressed.connect(_on_online_button_pressed)
	local_button.pressed.connect(_on_local_button_pressed)
	ai_button.pressed.connect(_on_ai_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_online_button_pressed():
	# Go to online multiplayer setup
	get_tree().change_scene_to_file("res://scenes/OnlineSetup.tscn")

func _on_local_button_pressed():
	# Go to local multiplayer setup
	get_tree().change_scene_to_file("res://scenes/LocalSetup.tscn")

func _on_ai_button_pressed():
	# Go to AI game setup
	get_tree().change_scene_to_file("res://scenes/AISetup.tscn")

func _on_exit_button_pressed():
	# Exit the game
	get_tree().quit()