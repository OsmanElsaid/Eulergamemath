extends Control

@onready var player_count_label = $VBoxContainer/PlayerCountContainer/PlayerCountLabel
@onready var player_count_spin = $VBoxContainer/PlayerCountContainer/PlayerCountSpinBox
@onready var target_mode_label = $VBoxContainer/TargetModeContainer/TargetModeLabel
@onready var target_random_button = $VBoxContainer/TargetModeContainer/RandomButton
@onready var target_manual_button = $VBoxContainer/TargetModeContainer/ManualButton
@onready var target_digits_label = $VBoxContainer/TargetDigitsContainer/TargetDigitsLabel
@onready var target_digits_spin = $VBoxContainer/TargetDigitsContainer/TargetDigitsSpinBox
@onready var manual_target_container = $VBoxContainer/ManualTargetContainer
@onready var manual_target_input = $VBoxContainer/ManualTargetContainer/ManualTargetInput
@onready var start_button = $VBoxContainer/StartButton
@onready var back_button = $VBoxContainer/BackButton

var is_manual_target: bool = false

func _ready():
	# Setup initial values
	player_count_spin.min_value = 2
	player_count_spin.max_value = 4
	player_count_spin.value = 2
	
	target_digits_spin.min_value = 2
	target_digits_spin.max_value = 5
	target_digits_spin.value = 3
	
	# Connect signals
	target_random_button.pressed.connect(_on_random_target_selected)
	target_manual_button.pressed.connect(_on_manual_target_selected)
	player_count_spin.value_changed.connect(_on_player_count_changed)
	target_digits_spin.value_changed.connect(_on_target_digits_changed)
	start_button.pressed.connect(_on_start_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Initialize UI
	_update_ui()

func _on_random_target_selected():
	is_manual_target = false
	_update_ui()

func _on_manual_target_selected():
	is_manual_target = true
	_update_ui()

func _on_player_count_changed(value: float):
	player_count_label.text = "Number of Players: " + str(int(value))

func _on_target_digits_changed(value: float):
	target_digits_label.text = "Target Digits: " + str(int(value))
	_update_manual_target_placeholder()

func _update_ui():
	# Update target mode appearance
	target_random_button.button_pressed = not is_manual_target
	target_manual_button.button_pressed = is_manual_target
	
	# Show/hide manual target input
	manual_target_container.visible = is_manual_target
	
	# Update labels
	player_count_label.text = "Number of Players: " + str(int(player_count_spin.value))
	target_digits_label.text = "Target Digits: " + str(int(target_digits_spin.value))
	
	_update_manual_target_placeholder()

func _update_manual_target_placeholder():
	if is_manual_target:
		var digits = int(target_digits_spin.value)
		var placeholder = ""
		for i in range(digits):
			placeholder += "0"
		manual_target_input.placeholder_text = "Enter " + str(digits) + "-digit target (e.g., " + placeholder + ")"

func _on_start_button_pressed():
	# Validate setup
	var player_count = int(player_count_spin.value)
	var target_digits = int(target_digits_spin.value)
	var target_number = 0
	
	if is_manual_target:
		var target_text = manual_target_input.text.strip_edges()
		if not target_text.is_valid_int():
			_show_error("Please enter a valid target number.")
			return
		
		target_number = int(target_text)
		if str(target_number).length() != target_digits:
			_show_error("Target number must have exactly " + str(target_digits) + " digits.")
			return
	else:
		target_number = GameManager.generate_random_target(target_digits)
	
	# Setup game
	GameManager.reset_game()
	GameManager.game_mode = GameManager.GameMode.LOCAL_MULTIPLAYER
	
	# Add players
	for i in range(player_count):
		GameManager.add_player("Player " + str(i + 1))
	
	# Start the game
	if GameManager.start_game():
		GameManager.set_target_number(target_number)
		get_tree().change_scene_to_file("res://scenes/GameScene.tscn")
	else:
		_show_error("Failed to start game.")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _show_error(message: String):
	var dialog = AcceptDialog.new()
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(func(): dialog.queue_free())