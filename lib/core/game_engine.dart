import 'dart:math';
import '../models/game_state.dart';

class GameEngine {
  static const List<String> colors = ['red', 'blue', 'green', 'yellow'];

  // توليد أوراق اللعبة الـ 168 (قوانين لا رحمة)
  static List<CardModel> generateDeck() {
    List<CardModel> deck = [];
    final random = Random();

    for (var c in colors) {
      // الأرقام من 1 إلى 9 (3 نسخ لكل رقم)
      for (int i = 1; i <= 9; i++) {
        deck.add(CardModel(id: _generateId(), color: c, value: i.toString()));
        deck.add(CardModel(id: _generateId(), color: c, value: i.toString()));
        deck.add(CardModel(id: _generateId(), color: c, value: i.toString()));
      }
      // الأرقام 0 و 7 (نسختان لكل رقم)
      deck.add(CardModel(id: _generateId(), color: c, value: '0'));
      deck.add(CardModel(id: _generateId(), color: c, value: '0'));
      deck.add(CardModel(id: _generateId(), color: c, value: '7'));
      deck.add(CardModel(id: _generateId(), color: c, value: '7'));
      
      // الأوامر الملونة (3 نسخ لكل منها، ونسختين لبعض الأوامر القاسية)
      for (int i = 0; i < 3; i++) {
        deck.add(CardModel(id: _generateId(), color: c, value: 'Skip'));
        deck.add(CardModel(id: _generateId(), color: c, value: 'Rev'));
        deck.add(CardModel(id: _generateId(), color: c, value: '+2'));
      }
      deck.add(CardModel(id: _generateId(), color: c, value: '+4'));
      deck.add(CardModel(id: _generateId(), color: c, value: '+4'));
      deck.add(CardModel(id: _generateId(), color: c, value: 'Skip All'));
      deck.add(CardModel(id: _generateId(), color: c, value: 'Skip All'));
      deck.add(CardModel(id: _generateId(), color: c, value: 'Discard All'));
      deck.add(CardModel(id: _generateId(), color: c, value: 'Discard All'));
    }
    
    // البطاقات البرية / السوداء
    for (int i = 0; i < 6; i++) {
      deck.add(CardModel(id: _generateId(), color: 'black', value: 'W'));
      deck.add(CardModel(id: _generateId(), color: 'black', value: 'W+6'));
      deck.add(CardModel(id: _generateId(), color: 'black', value: 'W+10'));
      deck.add(CardModel(id: _generateId(), color: 'black', value: 'Roulette'));
    }
    
    // خلط الأوراق
    deck.shuffle(random);
    return deck;
  }

  // توليد ID فريد لكل ورقة
  static String _generateId() {
    return DateTime.now().microsecondsSinceEpoch.toString() + Random().nextInt(100000).toString();
  }

  // التحقق مما إذا كانت الورقة الملعوبة صالحة للعب
  static bool isValidPlay(CardModel playedCard, CardModel topCard, String activeColor, int stackAmount) {
    // إذا كان هناك تراكم (سحب قيد الانتظار)
    if (stackAmount > 0) {
      if (playedCard.value == '+2' || playedCard.value == '+4' || playedCard.value == 'W+6' || playedCard.value == 'W+10') {
        return true; // يمكن الرد ببطاقة سحب أخرى (يفضل إضافة منطق للتحقق من قيمة السحب الأكبر لاحقاً)
      }
      return false;
    }

    // الوضع الطبيعي
    if (playedCard.color == 'black') return true;
    return playedCard.color == activeColor || playedCard.value == topCard.value;
  }
}
