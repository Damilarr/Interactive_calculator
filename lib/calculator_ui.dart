import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interactive_calculator/calculator_logic.dart';
import 'package:interactive_calculator/data_models.dart';

class CalculatorApp extends StatefulWidget {
  @override
  _CalculatorAppState createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  CalculatorState _state = const CalculatorState();
  bool _showHistory = false;
  bool _showMoreFunctions = false;

  // iPhone-style calculator button layout
  final List<List<CalculatorButton>> _buttonLayout = [
    [
      CalculatorButton(text: "C", value: "C", type: ButtonType.utility),
      CalculatorButton(text: "±", value: "±", type: ButtonType.function),
      CalculatorButton(text: "%", value: "%", type: ButtonType.function),
      CalculatorButton(text: "÷", value: "÷", type: ButtonType.operation),
    ],
    [
      CalculatorButton(text: "7", value: "7", type: ButtonType.number),
      CalculatorButton(text: "8", value: "8", type: ButtonType.number),
      CalculatorButton(text: "9", value: "9", type: ButtonType.number),
      CalculatorButton(text: "×", value: "×", type: ButtonType.operation),
    ],
    [
      CalculatorButton(text: "4", value: "4", type: ButtonType.number),
      CalculatorButton(text: "5", value: "5", type: ButtonType.number),
      CalculatorButton(text: "6", value: "6", type: ButtonType.number),
      CalculatorButton(text: "-", value: "-", type: ButtonType.operation),
    ],
    [
      CalculatorButton(text: "1", value: "1", type: ButtonType.number),
      CalculatorButton(text: "2", value: "2", type: ButtonType.number),
      CalculatorButton(text: "3", value: "3", type: ButtonType.number),
      CalculatorButton(text: "+", value: "+", type: ButtonType.operation),
    ],
    [
      CalculatorButton(text: "0", value: "0", type: ButtonType.number),
      CalculatorButton(text: ".", value: ".", type: ButtonType.number),
      CalculatorButton(text: "=", value: "=", type: ButtonType.operation),
    ],
  ];

  // Additional functions layout (your extra features)
  final List<List<CalculatorButton>> _moreFunctionsLayout = [
    [
      CalculatorButton(text: "MC", value: "MC", type: ButtonType.memory),
      CalculatorButton(text: "MR", value: "MR", type: ButtonType.memory),
      CalculatorButton(text: "M+", value: "M+", type: ButtonType.memory),
      CalculatorButton(text: "M-", value: "M-", type: ButtonType.memory),
    ],
    [
      CalculatorButton(text: "CE", value: "CE", type: ButtonType.utility),
      CalculatorButton(text: "√", value: "√", type: ButtonType.function),
      CalculatorButton(text: "x²", value: "x²", type: ButtonType.function),
      CalculatorButton(text: "1/x", value: "1/x", type: ButtonType.function),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Display area
            _buildDisplay(),

            // Function toggles
            _buildToggles(),

            // Calculator buttons, more functions, or history
            Expanded(
              child:
                  _showHistory
                      ? _buildHistory()
                      : _showMoreFunctions
                      ? _buildMoreFunctionsGrid()
                      : _buildButtonGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      height: 200, // Fixed height instead of flex
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Memory indicator
          if (_state.memory != 0)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "M",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),

          // Current operation display
          if (_state.operation != null && _state.previousValue != null)
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text(
                "${_formatDisplay(_state.previousValue!)} ${_state.operation}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 24,
                ),
              ),
            ),

          // Main display
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              _state.display,
              style: TextStyle(
                color: Colors.white,
                fontSize: 80,
                fontWeight: FontWeight.w200,
                fontFamily: 'SF Pro Display',
              ),
              textAlign: TextAlign.right,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDisplay(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toString();
  }

  Widget _buildToggles() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showMoreFunctions = !_showMoreFunctions;
                if (_showMoreFunctions) _showHistory = false;
              });
            },
            icon: Icon(
              _showMoreFunctions ? Icons.apps : Icons.functions,
              color: Colors.orange,
              size: 20,
            ),
            label: Text(
              _showMoreFunctions ? "Basic" : "More",
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showHistory = !_showHistory;
                if (_showHistory) _showMoreFunctions = false;
              });
            },
            icon: Icon(
              _showHistory ? Icons.calculate : Icons.history,
              color: Colors.orange,
              size: 20,
            ),
            label: Text(
              _showHistory
                  ? "Calculator"
                  : "History (${_state.history.length})",
              style: TextStyle(color: Colors.orange, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children:
              _buttonLayout.map((row) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children:
                          row.map((button) {
                            // Special handling for the "0" button (double width)
                            if (button.text == "0") {
                              return Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildCalculatorButton(
                                    button,
                                    isZero: true,
                                  ),
                                ),
                              );
                            }
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4),
                                child: _buildCalculatorButton(button),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildMoreFunctionsGrid() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            ..._moreFunctionsLayout.map((row) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children:
                        row.map((button) {
                          return Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: _buildCalculatorButton(button),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              );
            }).toList(),
            // Add empty rows to fill space
            Expanded(child: Container()),
            Expanded(child: Container()),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatorButton(
    CalculatorButton button, {
    bool isZero = false,
  }) {
    final isPressed = _state.operation == button.value;

    return SizedBox(
      height: double.infinity, // Takes full available height
      child: ElevatedButton(
        onPressed: () => _handleButtonPress(button.value),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isPressed ? Colors.white : _getButtonColor(button.type),
          foregroundColor:
              isPressed
                  ? _getButtonColor(button.type)
                  : _getTextColor(button.type),
          shape:
              isZero
                  ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  )
                  : CircleBorder(),
          padding: EdgeInsets.all(0),
          elevation: 0,
        ),
        child: Container(
          alignment: isZero ? Alignment.centerLeft : Alignment.center,
          padding: isZero ? EdgeInsets.only(left: 32) : EdgeInsets.zero,
          child: Text(
            button.text,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }

  Color _getButtonColor(ButtonType type) {
    switch (type) {
      case ButtonType.number:
        return Color(0xFF333333); // Dark gray for numbers
      case ButtonType.operation:
        return Color(0xFFFF9500); // Orange for operations
      case ButtonType.function:
      case ButtonType.utility:
        return Color(0xFFA6A6A6); // Light gray for functions
      case ButtonType.memory:
        return Color(0xFF0066CC); // Blue for memory functions
    }
  }

  Color _getTextColor(ButtonType type) {
    switch (type) {
      case ButtonType.function:
      case ButtonType.utility:
        return Colors.black;
      default:
        return Colors.white;
    }
  }

  Widget _buildHistory() {
    if (_state.history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              "No calculations yet",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Clear history button
        Container(
          padding: EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _clearHistory,
            child: Text("Clear History"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
          ),
        ),

        // History list
        Expanded(
          child: ListView.builder(
            itemCount: _state.history.length,
            reverse: true,
            itemBuilder: (context, index) {
              final historyItem =
                  _state.history[_state.history.length - 1 - index];
              return _buildHistoryItem(historyItem);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(CalculationHistory item) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: Colors.grey[850],
      child: ListTile(
        title: Text(item.expression, style: TextStyle(color: Colors.grey[300])),
        subtitle: Text(
          "= ${item.result}",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Text(
          "${item.timestamp.hour.toString().padLeft(2, '0')}:${item.timestamp.minute.toString().padLeft(2, '0')}",
          style: TextStyle(color: Colors.grey),
        ),
        onTap: () => _useHistoryResult(item.result),
      ),
    );
  }

  void _handleButtonPress(String value) {
    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _state = CalculatorLogic.processInput(_state, value);
    });
  }

  void _clearHistory() {
    setState(() {
      _state = _state.copyWith(history: []);
    });
  }

  void _useHistoryResult(String result) {
    final value = double.tryParse(result);
    if (value != null) {
      setState(() {
        _state = _state.copyWith(
          display: result,
          currentValue: value,
          shouldResetDisplay: true,
        );
        _showHistory = false;
      });
    }
  }
}
