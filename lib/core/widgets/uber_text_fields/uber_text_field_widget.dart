import 'package:flutter/material.dart';


class UberTextFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final String? hintText;
  final String? label; 
  final TextInputType? inputType;
  final Icon? prefixIcon;
  final ValueNotifier<bool> _obscureTextVN;

  UberTextFieldWidget({
    super.key,
    required this.controller,
    this.obscureText = false,
    this.hintText,
    this.label,
    this.validator,
    this.prefixIcon,
    this.inputType,
  }) : _obscureTextVN = ValueNotifier(obscureText);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
        valueListenable: _obscureTextVN,
        builder: (_, vNObscureText, __) {
          return TextFormField(
            controller: controller,
            keyboardType: inputType,
            validator:validator ,
            obscureText: vNObscureText,
            decoration: InputDecoration(
              errorStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              label:label != null ? Text(label!,style:TextStyle(fontSize: 20),) : null,
              suffixIcon: obscureText
                        ? IconButton(
                            onPressed: () {
                              _obscureTextVN.value = !vNObscureText;
                            },
                            icon: Icon(_obscureTextVN.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                          )
                        : null,
              hintText: hintText,
              filled: true,
              fillColor: Colors.white,
              prefixIcon: prefixIcon,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
            style: const TextStyle(fontSize: 18),
          );
        });
  }
}
