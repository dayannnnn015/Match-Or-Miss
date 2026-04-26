# Match-Or-Miss Codebase Exploration - Complete Findings
**Date**: April 26, 2026  
**Status**: All implementation patterns identified and documented

---

## Executive Summary

The codebase is well-structured with clear separation of concerns. Game modes are implemented with distinct time/move limits. The timer is currently an elapsed stopwatch (not mode-aware). History and hints infrastructure exist but need updates per your planned changes. Bottle alignment checking is solid using color-matching logic.

---

## 1️⃣ GAME MODES IMPLEMENTATION

### Enum Definition
- **File**: `lib/models/game_models.dart` (Line 4)
- **Definition**: `enum GameMode { quick, standard, competitive }`

### Mode Configuration & Constants
- **File**: `lib/utils/constants.dart` (Lines 13-25)

| Mode | Time Limit | Max Moves | Color | Description |
|------|-----------|-----------|-------|-------------|
| **Quick** | 240s (4 min) | 12 | Green | Relaxed intro—fewer moves, think smart |
| **Standard** | 240s (4 min) | 10 | Blue | Balanced challenge—main experience |
| **Competitive** | 180s (3 min) | 8 | Red | Max pressure—limited time & moves |

### Mode Logic in GameProvider
- **File**: `lib/providers/game_provider.dart` (Lines 112-127)
- Methods:
  - `_getTimeLimit(GameMode mode)` → returns AppConstants value
  - `_getMaxMoves(GameMode mode)` → returns AppConstants value
- **Called During**: `initializeGame(GameMode mode)` to set session parameters

### Mode Display in UI
- **File**: `lib/screens/game_screen_with_ai.dart` (Lines 200-240)
- Animated badge showing mode name with color-coded border
- Competitive mode displays extra time-remaining bar (Line 225-249)

---

## 2️⃣ TIMER IMPLEMENTATION

### Timer Widget
- **File**: `lib/widgets/timer_widget.dart`
- **Type**: Elapsed stopwatch (counts UP from 00:00)
- **Update Frequency**: Every 1 second via `Timer.periodic(Duration(seconds: 1))`
- **Display Format**: MM:SS (e.g., "04:32")
- **Location on Screen**: Top-right header in cyan box with schedule icon

### Current Timer State
```dart
// Starts from 0 and counts upward
int _elapsedSeconds = 0;

_startTimer() {
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    setState(() {
      _elapsedSeconds++;  // ← Just keeps incrementing
    });
  });
}
```

### Remaining Time Calculation
- **File**: `lib/models/game_models.dart` (Lines 48-50)
- **Getter**: `remainingTime`
```dart
int get remainingTime {
  final elapsed = DateTime.now().difference(startTime).inSeconds;
  return (timeLimit + timeBonus) - elapsed;
}
```
- Computes from session startTime, not from timer widget
- Competitive mode shows remaining time in separate bar below mode badge

### ⚠️ Timer Issues
- Timer widget shows elapsed time (not mode-aware)
- Timer doesn't enforce time limits or trigger timeout
- `GameSession.remainingTime` exists but timer widget doesn't use it
- No countdown display currently implemented

---

## 3️⃣ ATTEMPTS HISTORY DISPLAY

### Location & Widget
- **File**: `lib/widgets/attempt_history.dart`
- **Where Shown**: Bottom section of GameScreenWithAI (below feedback box, above buttons)
- **Controlled By**: `GameProvider._showHistory` (toggleable, currently always true)

### History Data Structure
- Source: `GameSession.attempts` (List<Attempt>)
- Each Attempt contains:
  - `attemptNumber` (1-based)
  - `guess` (List<Bottle?> positions)
  - `matches` (0-8)
  - `matchedPositions` (List<int> of correct indexes)
  - `variablesChanged` (count)
  - `wasImpulsive` (bool)
  - `timestamp`

### Display Format
```
MOVE HISTORY     [✓ correct position legend]

[Latest Move Highlighted]
Move 5 | 5/8 ✓ | Changed 2 | [impulsive indicator if true]

[Older Moves]
Move 4 | 4/8 ✓ | Changed 1 |
Move 3 | 3/8 ✓ | Changed 3 | ⚠️ IMPULSIVE
...
```

### Features
- Sorted newest-first (reversed list)
- Latest attempt has different background color
- Impulsive moves highlighted in yellow
- Empty state message: "Your move history will appear here"

### Integration Points
- **Game Screen**: `if (gameProvider.showHistory) → AttemptHistory(attempts: session.attempts)`
- **GameProvider**: Attempts added during `swapBottles()` method

---

## 4️⃣ HINTS IMPLEMENTATION

### Hint Infrastructure
- **AiHint Class**: `lib/models/ai_models.dart` (Lines 3+)
  - Fields: `message`, `confidence` (0-1 double)
- **Storage**: `GameProvider._lastHint` (String)
- **Getters**: 
  - `hasHint` → bool
  - `lastHint` → String

### Predefined Hints
- **File**: `lib/utils/constants.dart` (Lines 99-107)
```dart
static const Map<String, String> aiHints = {
  'too_many_changes':
      '🎯 You changed {count} variables. Try isolating 1-2 at a time!',
  'no_progress':
      '💡 No matches found. Try a completely different pattern.',
  'impulsive':
      '⚠️ Take a moment to analyze before making large changes.',
  'good_progress':
      '👍 Good! You have {matches} matches. Keep them and modify others.',
  'default_hint':
      '🎮 Keep going! Methodical changes lead to solutions.',
  'strategy_hint':
      '💡 Try the binary search method: test half the positions at once.',
  'memory_hint':
      '🧠 Remember which colors worked in previous attempts.',
};
```

### Runtime Hints
- **Method**: `GameService.getStrategyHint(int attemptsCount, int maxMatches)`
- **File**: `lib/services/game_service.dart` (Lines 116-133)
- **Examples**:
  - 0 attempts: "Each color is used exactly once. Drag bottles into slots..."
  - 0 matches: "No matches yet — every bottle is in the wrong position..."
  - 1-3 matches: "You have X correct positions! Lock those in..."
  - 4+ matches: "More than halfway! Focus on the remaining X positions..."

### ⚠️ Current Status
- Hints are defined but **NOT displayed** during gameplay
- No hint button currently wired
- `AiHint` class exists but not instantiated anywhere in game flow
- Only used in post-game feedback from AI service

---

## 5️⃣ GAME CONSTANTS & LIMITS

### Sequence Configuration
- **File**: `lib/utils/constants.dart`
```dart
static const int sequenceLength = 8;

static const List<Color> availableColors = [
  Color(0xFFE53935), // Red
  Color(0xFF1E88E5), // Blue
  Color(0xFF43A047), // Green
  Color(0xFFFDD835), // Yellow
  Color(0xFF8E24AA), // Purple
  Color(0xFFFF6F00), // Orange
  Color(0xFF00ACC1), // Cyan
  Color(0xFFEC407A), // Pink
];
```

### Time & Move Limits
```dart
// Time (seconds)
quickModeTime       = 240
standardModeTime    = 240
competitiveModeTime = 180

// Move limit
quickModeMaxMoves       = 12
standardModeMaxMoves    = 10
competitiveModeMaxMoves = 8
```

### AI Analysis Thresholds
```dart
impulsiveChangeThreshold = 3.0    // > 3 changes = impulsive
highImpulsiveCount       = 3      // 3+ impulsive moves
highRepeatedMistakes     = 2      // 2+ repeated errors
lowProgressRate          = 0.1
mediumProgressRate       = 0.3
highProgressRate         = 0.5
```

### Score Calculation
- **File**: `lib/services/game_service.dart` (Lines 83-102)
```dart
baseScore = matches * 100

moveBonus = (maxMoves - movesUsed) * moveMultiplier
timeBonus = (timeRemaining / 10) * timeMultiplier

// Competitive only:
speedBonus = 500 (if solved with > 50% time remaining)
```

---

## 6️⃣ BOTTLE ALIGNMENT & PUZZLE SOLVED CHECK

### Core Alignment Logic
- **File**: `lib/services/game_service.dart` (Lines 55-77)

#### Method 1: `calculateMatches(List<Bottle?> guess, List<Bottle> hidden)`
```dart
int calculateMatches(List<Bottle?> guess, List<Bottle> hidden) {
  int matches = 0;
  for (int i = 0; i < SEQUENCE_LENGTH; i++) {
    if (guess[i] != null && guess[i]!.color == hidden[i].color) {
      matches++;  // ← COLOR matching at position i
    }
  }
  return matches;  // 0-8
}
```
- **Logic**: Pure COLOR comparison (bottle IDs don't matter)
- **Position-based**: Each position checked independently
- **Returns**: Count of matching positions (0-8)

#### Method 2: `getMatchedPositions(List<Bottle?> guess, List<Bottle> hidden)`
```dart
List<int> getMatchedPositions(List<Bottle?> guess, List<Bottle> hidden) {
  final positions = <int>[];
  for (int i = 0; i < SEQUENCE_LENGTH; i++) {
    if (guess[i] != null && guess[i]!.color == hidden[i].color) {
      positions.add(i);  // ← Record which indexes match
    }
  }
  return positions;
}
```
- **Returns**: List of indexes where colors match (e.g., [0, 2, 5, 7])

#### Method 3: `isSequenceSolved(List<Bottle?> guess, List<Bottle> hidden)`
```dart
bool isSequenceSolved(List<Bottle?> guess, List<Bottle> hidden) =>
    calculateMatches(guess, hidden) == SEQUENCE_LENGTH;  // Must be 8/8
```
- **Win Condition**: All 8 positions must have matching colors

### Where Alignment is Checked
1. **Periodic Check**: `GameScreenWithAI._checkGamePeriodically()` (every 300ms)
   - Calls `GameProvider.isSolved()`
   - Which calls `GameService.isSequenceSolved()`
   
2. **On Match**: `GameProvider.getCurrentMatches()` (real-time feedback)
   - Shows live match count in feedback box (e.g., "5/8 ✓")
   
3. **On Win**: When `isSolved()` returns true:
   - Triggers `checkGameState()` → `loadPostGameInsight()`
   - Shows result dialog with score and feedback

### Match Count Display
- **File**: `lib/screens/game_screen_with_ai.dart` (Line 287)
- Shows in main feedback box: "Correct Positions: 5/8"
- Animated scaling when puzzle is solved (1.1x scale)

---

## CURRENT IMPLEMENTATION SNAPSHOT

### What's Working ✅
- ✅ Game modes defined with distinct configs
- ✅ Move attempt recording (after previous session fix)
- ✅ AI feedback on game completion
- ✅ Bottle alignment checking (color-based)
- ✅ Attempt history widget displaying move data
- ✅ Score calculation with mode multipliers
- ✅ Competitive mode time display

### What Needs Updates ⚠️ (Per Your Plan)
- ⚠️ **Timer**: Currently elapsed stopwatch, needs mode-aware countdown
  - Quick mode: No time enforcement needed?
  - Standard mode: Implement countdown display
  - Competitive mode: Upgrade from current time display
  
- ⚠️ **History**: Currently always shown, needs to be removed
  - Remove `AttemptHistory` widget from game screen
  - Remove `_showHistory` toggle from GameProvider
  
- ⚠️ **Hints**: Currently defined but unused during gameplay
  - Need to remove hint infrastructure
  - Remove from constants and models
  
- ⚠️ **AI Feedback**: Needs adjustment for new game flow
  - May need different prompt if history/hints removed
  - Consider impact on cognitive analysis

- ⚠️ **Player Alignment Logic**: Need to implement mode-specific
  - Quick: Player manually aligns bottles (no auto-check needed?)
  - Standard: Current logic (stopwatch + timer)
  - Competitive: Current logic (countdown timer)

---

## FILE REFERENCE GUIDE

```
lib/models/
├── game_models.dart          ← GameMode enum, GameSession, Attempt
└── ai_models.dart            ← AiHint, AIPlayerAnalysis

lib/providers/
├── game_provider.dart        ← Game logic, attempt recording, insights
└── ai_provider.dart

lib/services/
├── game_service.dart         ← Bottle alignment, match calculation
├── openai_service.dart       ← AI feedback generation
└── ...

lib/screens/
├── game_screen_with_ai.dart  ← Main game UI, timer display, result dialog
├── home_screen.dart
└── ...

lib/widgets/
├── timer_widget.dart         ← Elapsed stopwatch widget
├── attempt_history.dart      ← Move history display
├── bottle_widget.dart
├── bottle_slot.dart
└── ai_feedback.dart

lib/utils/
└── constants.dart            ← AppConstants with all game settings
```

---

## NEXT STEPS FOR IMPLEMENTATION

Based on this exploration, your planned changes will affect:

1. **Remove History** → Delete/modify `attempt_history.dart`, game screen logic
2. **Remove Hints** → Clean `constants.dart`, remove from flow
3. **Update AI Feedback** → Adjust prompts in `openai_service.dart`
4. **Implement Mode-Specific Behaviors**:
   - **Quick Mode**: Modify timer logic (no time pressure?)
   - **Standard Mode**: Keep current elapsed timer
   - **Competitive Mode**: Switch to countdown (need new widget)
5. **Player Alignment in Quick Mode**: Logic to implement in `game_provider.dart`

All core infrastructure is in place—these are modifications to existing features, not new implementations.
