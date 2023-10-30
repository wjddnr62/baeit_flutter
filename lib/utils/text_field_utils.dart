import 'package:flutter/material.dart';

blankCheck(
    {required String text,
    required TextEditingController controller,
    bool multiline = false}) {
  if (multiline) {
    if (text.contains('  ')) {
      int position = controller.text.indexOf('  ');
      controller.text = text.replaceAll('  ', ' ');
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: position + 1));
    }
    if (text.contains('\n\n\n\n')) {
      int position = controller.text.indexOf('\n\n\n\n');
      controller.text = text.replaceAll('\n\n\n\n', '\n\n\n');
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: position + 3));
    }
    if (controller.selection.baseOffset == 1 && text.substring(0, 1) == ' ') {
      controller.text = controller.text.substring(1);
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.selection.baseOffset));
    }
    if (controller.selection.baseOffset == 1 && text.substring(0, 1) == '\n') {
      controller.text = controller.text.substring(1);
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.selection.baseOffset));
    }
    if (text.length == 1 && text == '\n') {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    }
    if (text.length == 1 && text == ' ') {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    }
    if (text.length > 1 && text.contains('\n')) {
      if ((text.length > 4 &&
              text.substring(text.length - 5, text.length - 4) == '\n') &&
          (text.length > 3 &&
              text.substring(text.length - 4, text.length - 3) == '\n') &&
          (text.length > 2 &&
              text.substring(text.length - 3, text.length - 2) == '\n') &&
          (text.length > 1 &&
              text.substring(text.length - 2, text.length - 1) == '\n') &&
          text.substring(text.length - 1) == '\n') {
        controller.text = text.substring(0, text.length - 1);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
      if (text.substring(text.length - 2, text.length - 1) == '\n' &&
          text.substring(text.length - 1) == ' ') {
        controller.text = text.substring(0, text.length - 1);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }
    if (text.length > 1) {
      if (text.substring(text.length - 2, text.length - 1) == ' ' &&
          text.substring(text.length - 1) == ' ') {
        controller.text = text.substring(0, text.length - 1);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }
  } else {
    if (text.contains('  ')) {
      int position = controller.text.indexOf('  ');
      controller.text = text.replaceAll('  ', ' ');
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: position + 1));
    }
    if (controller.selection.baseOffset == 1 && text.substring(0, 1) == ' ') {
      controller.text = controller.text.substring(1);
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.selection.baseOffset));
    }
    if (text.length == 1 && text == ' ') {
      controller.text = '';
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    }
    if (text.length > 1) {
      if (text.substring(text.length - 2, text.length - 1) == ' ' &&
          text.substring(text.length - 1) == ' ') {
        controller.text = text.substring(0, text.length - 1);
        controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length));
      }
    }
  }
}
