import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// D-pad friendly keyboard for TV remote input
/// Grid of keys like phone dialpad with letters A-Z, numbers 0-9, and special keys
class KeyboardInputView extends StatefulWidget {
  const KeyboardInputView({
    super.key,
    required this.onKeyPressed,
  });

  final void Function(String key) onKeyPressed;

  @override
  State<KeyboardInputView> createState() => _KeyboardInputViewState();
}

class _KeyboardInputViewState extends State<KeyboardInputView> {
  late final FocusNode _focusNode;
  int _focusedIndex = 0;

  // Keyboard layout: rows of keys
  // QWERTY layout for TV remote familiarity
  static const List<List<String>> _keyboardRows = [
    ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'],
    ['Space', '⌫', 'Confirm'],
  ];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  int get _totalKeys {
    int count = 0;
    for (final row in _keyboardRows) {
      count += row.length;
    }
    return count;
  }

  int _getIndexInGrid(int row, int col) {
    int index = 0;
    for (int r = 0; r < row; r++) {
      index += _keyboardRows[r].length;
    }
    return index + col;
  }

  (int row, int col)? _getRowColFromIndex(int index) {
    int currentIndex = 0;
    for (int r = 0; r < _keyboardRows.length; r++) {
      final row = _keyboardRows[r];
      if (index < currentIndex + row.length) {
        return (r, index - currentIndex);
      }
      currentIndex += row.length;
    }
    return null;
  }

  String _getKeyLabel(String key) {
    switch (key) {
      case 'Space':
        return 'Space';
      case '⌫':
        return '⌫';
      case 'Confirm':
        return 'Confirm';
      default:
        return key;
    }
  }

  String _getKeyValue(String key) {
    switch (key) {
      case 'Space':
        return ' ';
      case '⌫':
        return '\b'; // backspace
      case 'Confirm':
        return '\n'; // enter
      default:
        return key;
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight) {
      setState(() => _focusedIndex = (_focusedIndex + 1).clamp(0, _totalKeys - 1));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() => _focusedIndex = (_focusedIndex - 1).clamp(0, _totalKeys - 1));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      // Move to next row
      final current = _getRowColFromIndex(_focusedIndex);
      if (current != null) {
        final (row, col) = current;
        if (row < _keyboardRows.length - 1) {
          final nextRow = _keyboardRows[row + 1];
          final newCol = col.clamp(0, nextRow.length - 1);
          setState(() => _focusedIndex = _getIndexInGrid(row + 1, newCol));
        }
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      // Move to previous row
      final current = _getRowColFromIndex(_focusedIndex);
      if (current != null) {
        final (row, col) = current;
        if (row > 0) {
          final prevRow = _keyboardRows[row - 1];
          final newCol = col.clamp(0, prevRow.length - 1);
          setState(() => _focusedIndex = _getIndexInGrid(row - 1, newCol));
        }
      }
    } else if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.gameButtonA) {
      // Confirm selection
      _selectFocusedKey();
    }
  }

  void _selectFocusedKey() {
    final pos = _getRowColFromIndex(_focusedIndex);
    if (pos != null) {
      final (row, col) = pos;
      final key = _keyboardRows[row][col];
      widget.onKeyPressed(_getKeyValue(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        _handleKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _totalKeys,
          itemBuilder: (context, index) {
            final pos = _getRowColFromIndex(index);
            if (pos == null) return const SizedBox.shrink();
            final (row, col) = pos;
            final key = _keyboardRows[row][col];
            final isFocused = index == _focusedIndex;

            return _KeyboardKey(
              label: _getKeyLabel(key),
              isFocused: isFocused,
              onTap: () => widget.onKeyPressed(_getKeyValue(key)),
            );
          },
        ),
      ),
    );
  }
}

class _KeyboardKey extends StatelessWidget {
  const _KeyboardKey({
    required this.label,
    required this.isFocused,
    required this.onTap,
  });

  final String label;
  final bool isFocused;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isFocused ? Colors.blue : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: isFocused
              ? Border.all(color: Colors.blueAccent, width: 3)
              : null,
          boxShadow: isFocused
              ? [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: label.length > 1 ? 12 : 18,
            fontWeight: isFocused ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}