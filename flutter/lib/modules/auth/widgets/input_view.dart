import 'package:flutter/material.dart';
import 'package:flutter_outfit/index.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputView extends StatelessWidget {
  const InputView({
    super.key,
    required this.controller,
    this.obscureText,
    required this.label,
    required this.icon,
    required this.tip,
    this.email = false,
  });

  final dynamic controller;
  final dynamic obscureText;
  final dynamic label;
  final dynamic icon;
  final dynamic tip;
  final dynamic email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
      validator: (v) {
        if (email && !RegExp(r'^.+@.+\..+$').hasMatch(v!)) {
          return l10n.emailInvalidTip;
        }
        return v!.isEmpty ? tip : null;
      },
    );
  }
}
