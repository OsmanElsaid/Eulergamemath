# Euler Math Game - Godot 4.4.1 Project

An educational, multiplayer mathematical game where players compete to reach a target number using lottery-drawn numbers and mathematical operations.

## 🎮 Game Overview

Euler is a turn-based multiplayer game where 2-4 players take turns drawing numbers from a lottery and applying mathematical operations to reach a target number. The first player to reach the target exactly wins!

## 🎯 Key Features

- **Access Code Protection**: Game requires code `39278` to access
- **Multiple Game Modes**: 
  - Local Multiplayer (Pass-and-Play)
  - Online Multiplayer (placeholder)
  - AI Opponent (placeholder)
- **Mathematical Operations**: Addition, Subtraction, Multiplication, Division, Parentheses
- **Special Buttons**: 
  - Free Button (Turns 8-14): Choose any digit
  - No Button (Turn 14+): Skip lottery result
- **Time Pressure**: 10 seconds per turn with automatic penalties
- **Badge System**: Gold, Silver, Bronze for winners

## 🚀 Getting Started

### Prerequisites
- Godot Engine 4.4.1 with OpenGL compatibility
- No additional dependencies required

### Installation
1. Download/clone this project
2. Open Godot Engine 4.4.1
3. Click "Import" and select the `project.godot` file
4. Click "Import & Edit"

### Running the Game
1. In Godot, press `F5` or click the "Play" button
2. Enter access code: `39278`
3. Select your preferred game mode from the main menu
4. Configure game settings and start playing!

## 🎮 How to Play

### Basic Gameplay
1. **Setup**: Choose number of players (2-4) and target number (2-5 digits)
2. **Turn Structure**: Each player takes a turn in random order
3. **Actions per Turn**:
   - Press lottery button to draw a random digit (0-9)
   - Select a mathematical operation
   - Both actions must be completed within 10 seconds

### Special Rules
- **Operation Sequence**: Basic operations (+, -, ×, ÷) cannot follow each other directly
- **Required Operations**: All four basic operations must be used before ending
- **Special Turns**:
  - Turn 8 & 16: Draw two digits (tens and ones)
  - Turn 8-14: Free button available (choose any digit)
  - Turn 14+: No button available (skip lottery result)

### Winning Conditions
- **Primary**: First player to reach target number exactly
- **Secondary**: For incomplete games, closest players get points based on target size

### Penalties
- **First Penalty**: Can't use lottery next turn (must only place operation)
- **Second Penalty**: Eliminated from game

## 🏗️ Project Structure

```
Euler-Math-Game/
├── project.godot          # Main project configuration
├── icon.svg              # Game icon
├── scenes/               # Game scenes (.tscn files)
│   ├── AccessScreen.tscn # Initial access code screen
│   ├── MainMenu.tscn     # Main menu navigation
│   ├── LocalSetup.tscn   # Local multiplayer setup
│   ├── GameScene.tscn    # Main gameplay scene
│   ├── OnlineSetup.tscn  # Online setup (placeholder)
│   └── AISetup.tscn      # AI setup (placeholder)
├── scripts/              # Game logic (.gd files)
│   ├── AccessScreen.gd   # Access code validation
│   ├── MainMenu.gd       # Menu navigation
│   ├── LocalSetup.gd     # Local game configuration
│   ├── GameScene.gd      # Core gameplay logic
│   ├── GameManager.gd    # Global game state management
│   ├── MathEvaluator.gd  # Mathematical expression evaluator
│   ├── OnlineSetup.gd    # Online setup (placeholder)
│   └── AISetup.gd        # AI setup (placeholder)
├── textures/             # Game images (empty)
└── sounds/               # Game audio (empty)
```

## 🧩 Architecture Overview

### Core Components

1. **GameManager (Singleton)**
   - Global game state management
   - Player management and turn tracking
   - Game rules enforcement
   - Score calculation and badge distribution

2. **MathEvaluator**
   - Mathematical expression parsing and evaluation
   - Handles proper order of operations
   - Supports all required operations and parentheses

3. **Game Scenes**
   - **AccessScreen**: Security gate requiring access code
   - **MainMenu**: Navigation hub for different game modes
   - **LocalSetup**: Configuration for local multiplayer games
   - **GameScene**: Main gameplay interface with full UI

### Player Data Structure
Each player tracks:
- Numbers drawn from lottery
- Mathematical operations selected
- Current mathematical expression
- Game statistics (penalties, button usage)
- Final result and badges earned

## 🎨 User Interface

### Main Game Layout
- **Center Panel**: Target number, current turn info, lottery button, special buttons
- **Left/Right Panels**: Player displays showing their numbers and expressions
- **Bottom Panel**: Mathematical operation buttons (+, -, ×, ÷, (, ))

### Special UI Elements
- **Timer Display**: Shows remaining time for current turn
- **Free Button**: Appears turns 8-14 for digit selection
- **No Button**: Appears turn 14+ to skip lottery
- **End Button**: Appears when all operations used

## 🔧 Technical Implementation

### Mathematical Expression Evaluation
- Uses Shunting Yard algorithm for infix to postfix conversion
- Proper order of operations (PEMDAS/BODMAS)
- Division by zero protection
- Input validation and error handling

### Game Rules Engine
- Turn-based state management
- Operation sequence validation
- Time limit enforcement
- Penalty system implementation
- Badge and scoring algorithms

### Godot 4.4.1 Compatibility
- Uses modern Godot 4.x signal syntax
- Proper scene management with get_tree().change_scene_to_file()
- UTF-8 encoding for all files
- GL Compatibility rendering method

## 🚀 Future Enhancements

### Planned Features
1. **Online Multiplayer**
   - Room creation with unique codes
   - Voice communication integration
   - Network synchronization
   - Player timeout handling

2. **AI Opponent**
   - Multiple difficulty levels
   - Strategic decision making
   - Learning algorithms for optimal play

3. **Enhanced UI**
   - Animations and visual effects
   - Sound effects and background music
   - Customizable themes
   - Mobile-friendly interface

4. **Additional Game Modes**
   - Tournament mode
   - Custom rule sets
   - Practice mode with hints
   - Statistics tracking

## 🐛 Known Issues

- Online multiplayer is not yet implemented (placeholder screens)
- AI opponent is not yet implemented (placeholder screens)
- No sound effects or background music
- Mathematical expression evaluation could be enhanced for edge cases

## 📝 Development Notes

### Code Quality
- Comprehensive error handling
- Modular architecture with clear separation of concerns
- Extensive commenting for beginner-friendly code
- Follows Godot best practices

### Testing Recommendations
1. Test access code functionality (correct: 39278, incorrect: any other)
2. Verify local multiplayer setup with different player counts
3. Test mathematical expression evaluation with complex equations
4. Validate game rules enforcement (operation sequences, time limits)
5. Check penalty system (first penalty, elimination)
6. Verify badge distribution and scoring

## 🤝 Contributing

This project is designed to be educational and beginner-friendly. When contributing:
- Maintain extensive commenting
- Follow existing code style
- Test thoroughly before submitting
- Update documentation for new features

## 📄 License

This project is created for educational purposes. Feel free to use, modify, and distribute as needed.

---

**Note**: This game was built as a complete educational project demonstrating game development principles in Godot Engine 4.4.1. All core mathematical game mechanics are fully implemented and functional.