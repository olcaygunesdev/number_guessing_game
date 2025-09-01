import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/app_colors.dart';

class DigitInputField extends StatefulWidget {
  final Function(String) onCompleted;
  final int digitCount;

  const DigitInputField({
    super.key,
    required this.onCompleted,
    this.digitCount = 4,
  });

  @override
  State<DigitInputField> createState() => DigitInputFieldState();
}

class DigitInputFieldState extends State<DigitInputField> {
  late List<TextEditingController> controllers;
  late List<FocusNode> focusNodes;

  @override
  void initState() {
    super.initState();
    controllers = List.generate(
      widget.digitCount,
      (index) => TextEditingController(),
    );
    focusNodes = List.generate(
      widget.digitCount,
      (index) => FocusNode(),
    );
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Validate the input
      if (!_validateInput(index, value)) {
        // Invalid input, clear the field and stay focused
        controllers[index].clear();
        return;
      }
      
      // Move to next field
      if (index < widget.digitCount - 1) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Last digit entered, unfocus
        focusNodes[index].unfocus();
      }
    }
    
    // Check if all digits are entered
    _checkCompletion();
  }

  bool _validateInput(int index, String value) {
    // Check if starting with 0
    if (index == 0 && value == '0') {
      _showErrorDialog('Invalid Input', 'Number cannot start with 0');
      return false;
    }
    
    // Check for duplicate digits
    for (int i = 0; i < controllers.length; i++) {
      if (i != index && controllers[i].text == value) {
        _showErrorDialog('Invalid Input', 'Each digit must be different.\nDigit "$value" is already used.');
        return false;
      }
    }
    
    return true;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _onDigitDeleted(int index) {
    if (controllers[index].text.isEmpty && index > 0) {
      // Move to previous field when backspace on empty field
      focusNodes[index - 1].requestFocus();
    }
  }

  void _checkCompletion() {
    String number = '';
    for (var controller in controllers) {
      number += controller.text;
    }
    
    if (number.length == widget.digitCount) {
      widget.onCompleted(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.digitCount,
        (index) => Container(
          width: 60,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.digitInputBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focusNodes[index].hasFocus 
                  ? AppColors.primary 
                  : AppColors.digitInputBorder,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '',
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(1),
            ],
            onChanged: (value) => _onDigitChanged(index, value),
            onTap: () {
              // Clear field when tapped
              controllers[index].clear();
            },
            onEditingComplete: () {
              if (index < widget.digitCount - 1) {
                focusNodes[index + 1].requestFocus();
              }
            },
          ),
        ),
      ),
    );
  }

  // Public method to clear all fields
  void clear() {
    for (var controller in controllers) {
      controller.clear();
    }
    focusNodes[0].requestFocus();
  }

  // Public method to get current value
  String get value {
    String number = '';
    for (var controller in controllers) {
      number += controller.text;
    }
    return number;
  }
}
