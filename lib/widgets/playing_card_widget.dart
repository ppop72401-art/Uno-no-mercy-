import 'package:flutter/material.dart';
import '../models/game_state.dart';

class PlayingCardWidget extends StatelessWidget {
  final CardModel card;
  final bool isPlayable;
  final VoidCallback? onTap;

  const PlayingCardWidget({
    super.key,
    required this.card,
    this.isPlayable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color shadowColor;
    Color textColor = Colors.white;

    // استخراج ألوان دولينغو بناءً على بيانات الورقة
    switch (card.color) {
      case 'red':
        bgColor = const Color(0xFFFF4B4B);
        shadowColor = const Color(0xFFCB3232);
        break;
      case 'blue':
        bgColor = const Color(0xFF1CB0F6);
        shadowColor = const Color(0xFF1899D6);
        break;
      case 'green':
        bgColor = const Color(0xFF58CC02);
        shadowColor = const Color(0xFF46A302);
        break;
      case 'yellow':
        bgColor = const Color(0xFFFFC800);
        shadowColor = const Color(0xFFCCA000);
        textColor = Colors.black; // نص أسود ليكون مقروءاً على الأصفر
        break;
      default:
        bgColor = const Color(0xFF2B333A);
        shadowColor = const Color(0xFF1D2328);
    }

    return GestureDetector(
      onTap: isPlayable ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isPlayable ? 1.0 : 0.5,
        child: Container(
          width: 75,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border(
              bottom: BorderSide(color: shadowColor, width: 6),
            ),
          ),
          child: Stack(
            children: [
              // الإطار الداخلي الشفاف المميز
              Positioned.fill(
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  ),
                ),
              ),
              Center(
                child: Text(
                  card.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: card.value.length > 2 ? 14 : 28,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
