import 'package:flutter/material.dart';

class CustomTextFieldPW extends StatefulWidget {
  final void Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final IconData prefixIcon;
  final String hintText;
  final String labelText;
  const CustomTextFieldPW({
    Key? key,
    this.onSaved,
    this.validator,
    this.controller,
    required this.prefixIcon,
    required this.hintText, this.labelText = 'Password',
  }) : super(key: key);

  @override
  State<CustomTextFieldPW> createState() => _CustomTextFieldPWState();
}

class _CustomTextFieldPWState extends State<CustomTextFieldPW> {

  bool _isHidden = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onSaved: widget.onSaved,
      validator: widget.validator,
      keyboardType: TextInputType.text,
      controller: widget.controller,
      textInputAction: TextInputAction.go,
      obscuringCharacter: '*',
      obscureText: _isHidden,
      decoration: InputDecoration(
        filled: false,
        prefixIcon: Icon(
          widget.prefixIcon,
        ),
        suffixIcon: IconButton(
          splashRadius: 5,
          onPressed: () {
            setState(() {
              _isHidden = !_isHidden;
            });
          },
          icon: Icon(
            _isHidden ? Icons.visibility : Icons.visibility_off,
          ),
        ),
        hintText: widget.hintText,
        labelText: widget.labelText,
      ),
    );
  }
}
