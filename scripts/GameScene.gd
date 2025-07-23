extends Control

# UI References
@onready var target_label = $CenterPanel/TargetLabel
@onready var turn_label = $CenterPanel/TurnLabel
@onready var current_player_label = $CenterPanel/CurrentPlayerLabel
@onready var timer_label = $CenterPanel/TimerLabel
@onready var lottery_button = $CenterPanel/LotteryButton
@onready var free_button = $CenterPanel/ButtonRow/FreeButton
@onready var no_button = $CenterPanel/ButtonRow/NoButton
@onready var end_button = $CenterPanel/ButtonRow/EndButton

# Operation buttons
@onready var operations_container = $BottomPanel/OperationsContainer
@onready var add_button = $BottomPanel/OperationsContainer/AddButton
@onready var subtract_button = $BottomPanel/OperationsContainer/SubtractButton
@onready var multiply_button = $BottomPanel/OperationsContainer/MultiplyButton
@onready var divide_button = $BottomPanel/OperationsContainer/DivideButton
@onready var open_paren_button = $BottomPanel/OperationsContainer/OpenParenButton
@onready var close_paren_button = $BottomPanel/OperationsContainer/CloseParenButton

# Player display containers
@onready var player1_container = $LeftPanel/Player1Container
@onready var player2_container = $RightPanel/Player2Container
@onready var player3_container = $LeftPanel/Player3Container
@onready var player4_container = $RightPanel/Player4Container

# Game state
var current_turn_time: float = 0.0
var is_turn_active: bool = false
var lottery_pressed: bool = false
var operation_selected: bool = false
var turn_timer: Timer
var auto_lottery_timer: Timer

# Special turn handling
var is_special_turn: bool = false
var first_digit: int = -1
var second_digit: int = -1
var digits_swapped: bool = false

func _ready():
	# Initialize timers
	turn_timer = Timer.new()
	turn_timer.wait_time = 1.0
	turn_timer.timeout.connect(_on_turn_timer_timeout)
	add_child(turn_timer)
	
	auto_lottery_timer = Timer.new()
	auto_lottery_timer.wait_time = 4.0
	auto_lottery_timer.one_shot = true
	auto_lottery_timer.timeout.connect(_on_auto_lottery_timeout)
	add_child(auto_lottery_timer)
	
	# Connect signals
	lottery_button.pressed.connect(_on_lottery_button_pressed)
	free_button.pressed.connect(_on_free_button_pressed)
	no_button.pressed.connect(_on_no_button_pressed)
	end_button.pressed.connect(_on_end_button_pressed)
	
	# Connect operation buttons
	add_button.pressed.connect(_on_operation_selected.bind("+"))
	subtract_button.pressed.connect(_on_operation_selected.bind("-"))
	multiply_button.pressed.connect(_on_operation_selected.bind("×"))
	divide_button.pressed.connect(_on_operation_selected.bind("÷"))
	open_paren_button.pressed.connect(_on_operation_selected.bind("("))
	close_paren_button.pressed.connect(_on_operation_selected.bind(")"))
	
	# Connect GameManager signals
	GameManager.game_started.connect(_on_game_started)
	GameManager.turn_changed.connect(_on_turn_changed)
	GameManager.target_set.connect(_on_target_set)
	GameManager.game_finished.connect(_on_game_finished)
	
	# Initialize UI
	_update_ui()

func _on_game_started():
	_update_ui()
	_setup_target_selection()

func _setup_target_selection():
	# For now, generate a random 3-digit target
	var target = GameManager.generate_random_target(3)
	GameManager.set_target_number(target)

func _on_target_set(target: int):
	target_label.text = "Target: " + str(target)
	_start_first_turn()

func _start_first_turn():
	var current_player = GameManager.get_current_player()
	if current_player:
		_start_player_turn(current_player)

func _on_turn_changed(player: GameManager.Player):
	_start_player_turn(player)

func _start_player_turn(player: GameManager.Player):
	current_player_label.text = "Current Player: " + player.name
	turn_label.text = "Turn: " + str(GameManager.current_turn)
	
	# Reset turn state
	lottery_pressed = false
	operation_selected = false
	is_turn_active = true
	current_turn_time = GameManager.current_turn_time
	
	# Check for special turns (8 and 16)
	is_special_turn = GameManager.current_turn == 8 or GameManager.current_turn == 16
	first_digit = -1
	second_digit = -1
	digits_swapped = false
	
	# Update button visibility
	_update_button_visibility()
	
	# Start turn timer
	turn_timer.start()
	
	# Start auto-lottery timer (2 seconds)
	if player.can_use_lottery:
		auto_lottery_timer.wait_time = 4.0
		auto_lottery_timer.start()

func _update_button_visibility():
	var current_player = GameManager.get_current_player()
	if not current_player:
		return
	
	var current_turn = GameManager.current_turn
	
	# Lottery button
	lottery_button.visible = current_player.can_use_lottery and not lottery_pressed
	
	# Free button (turns 8-14)
	free_button.visible = (current_turn >= 8 and current_turn <= 14 and 
						   not current_player.free_button_used)
	
	# No button (turn 14+)
	no_button.visible = (current_turn >= 14 and 
						 current_player.no_button_uses < 10)
	
	# End button (only when all basic operations used)
	end_button.visible = current_player.can_end_turn()
	
	# Operation buttons
	_update_operation_buttons()

func _update_operation_buttons():
	var current_player = GameManager.get_current_player()
	if not current_player:
		return
	
	# Enable/disable based on game rules
	var last_operation = ""
	if not current_player.operations.is_empty():
		last_operation = current_player.operations[-1]
	
	var basic_ops = ["+", "-", "×", "÷"]
	var can_add_basic_op = last_operation not in basic_ops
	
	add_button.disabled = not can_add_basic_op
	subtract_button.disabled = not can_add_basic_op
	multiply_button.disabled = not can_add_basic_op
	divide_button.disabled = not can_add_basic_op
	
	# Parentheses logic
	close_paren_button.disabled = current_player.open_parentheses_count <= 0

func _on_turn_timer_timeout():
	if not is_turn_active:
		return
	
	current_turn_time -= 1.0
	timer_label.text = "Time: " + str(int(current_turn_time))
	
	if current_turn_time <= 0:
		_handle_turn_timeout()

func _on_auto_lottery_timeout():
	if not lottery_pressed and is_turn_active:
		_on_lottery_button_pressed()

func _handle_turn_timeout():
	var current_player = GameManager.get_current_player()
	if not current_player:
		return
	
	if not operation_selected:
		# Player didn't select operation - apply penalty
		current_player.penalties += 1
		
		if current_player.penalties == 1:
			# First penalty: can't use lottery next turn
			current_player.can_use_lottery = false
		elif current_player.penalties >= 2:
			# Second penalty: eliminate player
			_eliminate_player(current_player)
			return
	
	_end_turn()

func _eliminate_player(player: GameManager.Player):
	GameManager.remove_player(player)
	_update_player_displays()
	
	# Check if game should continue
	if GameManager.players.size() < 2:
		GameManager.end_game()
	else:
		GameManager.next_turn()

func _on_lottery_button_pressed():
	lottery_pressed = true
	auto_lottery_timer.stop()
	
	var number = randi_range(0, 9)
	
	if is_special_turn:
		if first_digit == -1:
			first_digit = number
			lottery_button.text = "First: " + str(first_digit) + " (Press again)"
		else:
			second_digit = number
			lottery_button.text = "Digits: " + str(first_digit) + str(second_digit)
			_show_digit_swap_option()
	else:
		_add_number_to_current_player(number)
		lottery_button.visible = false

func _show_digit_swap_option():
	# Show swap button or handle automatic confirmation
	var final_number = first_digit * 10 + second_digit
	_add_number_to_current_player(final_number)

func _on_free_button_pressed():
	# Show input dialog for free number
	var dialog = AcceptDialog.new()
	var line_edit = LineEdit.new()
	line_edit.placeholder_text = "Enter digit (0-9)"
	line_edit.max_length = 1
	
	dialog.add_child(line_edit)
	add_child(dialog)
	
	dialog.confirmed.connect(_on_free_number_confirmed.bind(line_edit))
	dialog.popup_centered()

func _on_free_number_confirmed(line_edit: LineEdit):
	var text = line_edit.text
	if text.is_valid_int() and int(text) >= 0 and int(text) <= 9:
		var current_player = GameManager.get_current_player()
		current_player.free_button_used = true
		_add_number_to_current_player(int(text))
	
	line_edit.get_parent().queue_free()

func _on_no_button_pressed():
	var current_player = GameManager.get_current_player()
	current_player.no_button_uses += 1
	
	if is_special_turn and first_digit != -1 and second_digit != -1:
		# Handle special turn "No" button logic
		_handle_special_turn_no()
	else:
		# Regular no button - skip lottery result
		lottery_pressed = true
	
	_update_button_visibility()

func _handle_special_turn_no():
	# For turn 16, player can cancel one digit
	# Show dialog to choose which digit to keep
	pass  # Implement special turn no button logic

func _add_number_to_current_player(number: int):
	var current_player = GameManager.get_current_player()
	if current_player:
		current_player.add_number(number)
		_update_player_displays()

func _on_operation_selected(operation: String):
	var current_player = GameManager.get_current_player()
	if not current_player:
		return
	
	# Validate operation sequence
	var last_op = ""
	if not current_player.operations.is_empty():
		last_op = current_player.operations[-1]
	
	if not GameManager.is_valid_operation_sequence(last_op, operation):
		return
	
	current_player.add_operation(operation)
	operation_selected = true
	
	_update_player_displays()
	_update_operation_buttons()
	
	# Check if turn should end
	if lottery_pressed and operation_selected:
		_end_turn()

func _on_end_button_pressed():
	var current_player = GameManager.get_current_player()
	if current_player and current_player.can_end_turn():
		current_player.calculate_result()
		
		# Check if player reached target
		if current_player.final_result == GameManager.target_number:
			GameManager.player_finished(current_player)
		else:
			current_player.has_finished = true
		
		_update_player_displays()
		_end_turn()

func _end_turn():
	is_turn_active = false
	turn_timer.stop()
	auto_lottery_timer.stop()
	
	# Reset lottery usage permission if it was disabled due to penalty
	var current_player = GameManager.get_current_player()
	if current_player and not current_player.can_use_lottery:
		current_player.can_use_lottery = true
	
	GameManager.next_turn()

func _update_ui():
	_update_player_displays()
	_update_button_visibility()

func _update_player_displays():
	# Update player information displays
	var containers = [player1_container, player2_container, player3_container, player4_container]
	
	for i in range(containers.size()):
		var container = containers[i]
		if i < GameManager.players.size():
			var player = GameManager.players[i]
			container.visible = true
			_update_player_container(container, player)
		else:
			container.visible = false

func _update_player_container(container: Control, player: GameManager.Player):
	# This will be implemented based on the actual UI structure
	# For now, just show basic info
	var name_label = container.get_node("PlayerName") as Label
	var expression_label = container.get_node("Expression") as Label
	var numbers_label = container.get_node("Numbers") as Label
	
	if name_label:
		name_label.text = player.name
	if expression_label:
		expression_label.text = player.current_expression
	if numbers_label:
		numbers_label.text = "Numbers: " + str(player.numbers)

func _on_game_finished():
	# Show game results
	print("Game finished!")
	# Implement game results display