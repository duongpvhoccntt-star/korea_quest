import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.hint,
    this.controller,
    this.errorText,
    this.enabled = true,
    this.prefixIcon,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool enabled;
  final IconData? prefixIcon;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class PasswordField extends StatefulWidget {
  const PasswordField({required this.label, super.key, this.controller});

  final String label;
  final TextEditingController? controller;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      controller: widget.controller,
      obscureText: _obscured,
      prefixIcon: Icons.lock_outline_rounded,
      suffixIcon: IconButton(
        tooltip: _obscured ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
        onPressed: () => setState(() => _obscured = !_obscured),
        icon: Icon(
          _obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        ),
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({super.key, this.controller, this.onChanged});

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    onChanged: onChanged,
    decoration: const InputDecoration(
      hintText: 'Tìm địa điểm, hành trình…',
      prefixIcon: Icon(Icons.search_rounded),
    ),
  );
}
