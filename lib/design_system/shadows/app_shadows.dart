import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const small = [
    BoxShadow(color: Color(0x14202B3A), blurRadius: 24, offset: Offset(0, 8)),
  ];
  static const large = [
    BoxShadow(color: Color(0x1C182B3A), blurRadius: 50, offset: Offset(0, 18)),
  ];
}
