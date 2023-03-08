import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final String hintText;
  final String? labelText;
  final TextInputType textInputType;
  final TextInputAction inputAction;
  final bool filled;
  final List<TextInputFormatter>? inputFormatter;
  const CustomTextField({
    Key? key,
    this.onSaved,
    this.filled = false,
    this.inputFormatter,
    this.validator,
    this.controller,
    required this.prefixIcon,
    this.suffixIcon,
    required this.hintText,
    this.labelText,
    this.textInputType = TextInputType.text,
    this.inputAction = TextInputAction.next,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      inputFormatters: inputFormatter,
      onSaved: onSaved,
      validator: validator,
      keyboardType: textInputType,
      controller: controller,
      textInputAction: inputAction,
      decoration: InputDecoration(
        filled: filled,
        labelText: labelText,
        prefixIcon: Icon(
          prefixIcon,
        ),
        hintText: hintText,
      ),
    );
  }
}
