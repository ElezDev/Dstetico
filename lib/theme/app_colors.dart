import 'package:flutter/material.dart';

class AppColors {
  // Colores existentes
  static const Color color1 = Color(0xFF74A3E4);
  static const Color color2 = Color(0xFF1886E4);
  static const Color color3 = Color(0xFF053B99);
  static const Color color4 = Color(0xFF11D6F8);
  static const Color color5 = Color(0xFFE3EEF9);
  static const Color color6 = Color(0xFF588EE2);
  static const Color color7 = Color(0xFF17B8F2);
  static const Color color8 = Color(0xFF075DCE);
  static const Color color9 = Color(0xFF12599F);
  static const Color color10 = Color(0xFF9CB4EC);
  

  static const Color esteticaMorado = Color(0xFFb357a7);
  static const Color esteticaAzul = Color(0xFF76aeee);

  static const LinearGradient esteticaGradient = LinearGradient(
    colors: [esteticaMorado, esteticaAzul],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static final LinearGradient esteticaGradientGlass = LinearGradient(
  colors: [
    esteticaMorado.withOpacity(0.2),
    esteticaAzul.withOpacity(0.2),
  ],
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
);
}
