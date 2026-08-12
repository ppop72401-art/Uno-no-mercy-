import 'dart:math';
import '../models/game_state.dart';

class GameEngine {
  static const List<String> colors = ['red', 'blue', 'green', 'yellow'];

  // 1. بدء اللعبة وتوزيع الأوراق
  static void initializeGame(GameState state) {
    state.deck = _generateDeck();
    
    // توزيع 7 أوراق لكل لاعب
    for (var player in state.players) {
      player.hand = [];
      for (int i = 0; i < 7; i++) {
        player.hand.add(state.deck.removeLast());
      }
    }

    // سحب أول ورقة للطاولة (يجب ألا تكون ورقة أوامر)
    CardModel firstCard;
    do {
      firstCard = state.deck.removeLast();
      if (int.tryParse(firstCard.value) == null) {
        state.deck.insert(0, firstCard); // إعادتها لأسفل الكومة
      } else {
        break; // ورقة صالحة
      }
    } while (true);

    state.discardPile = [firstCard];
    state.activeColor = firstCard.color;
    state.status = 'playing';
    state.currentTurnId = state.players.first.id;
  }

  // 2. معالجة لعب الورقة
  static void processPlay(GameState state, String playerId, String cardId) {
    Player player = state.players.firstWhere((p) => p.id == playerId);
    CardModel card = player.hand.firstWhere((c) => c.id == cardId);

    // التحقق من صلاحية الورقة
    if (!_isValidPlay(card, state.discardPile.last, state.activeColor, state.stackAmount)) return;

    // نقل الورقة من اليد للطاولة
    player.hand.remove(card);
    state.discardPile.add(card);
    if (card.color != 'black') state.activeColor = card.color;

    // تطبيق القوانين والأوامر
    bool skipNext = false;
    
    if (card.value == 'Rev') {
      state.direction *= -1;
      if (state.players.where((p) => !p.isEliminated).length == 2) skipNext = true;
    } else if (card.value == 'Skip') {
      skipNext = true;
    } else if (card.value == 'Skip All') {
      // يعود الدور لنفس اللاعب
      return; 
    } else if (card.value == '+2') {
      state.stackAmount += 2;
    } else if (card.value == '+4') {
      state.stackAmount += 4;
    } else if (card.value == 'W+6') {
      state.stackAmount += 6;
    } else if (card.value == 'W+10') {
      state.stackAmount += 10;
    }

    // فحص الفوز
    if (player.hand.isEmpty) {
      state.status = 'finished';
      return;
    }

    _advanceTurn(state, skip: skipNext);
  }

  // 3. معالجة سحب الأوراق (بما في ذلك التراكم وقاعدة الرحمة)
  static void processDraw(GameState state, String playerId) {
    Player player = state.players.firstWhere((p) => p.id == playerId);
    
    int drawCount = state.stackAmount > 0 ? state.stackAmount : 1;
    
    for (int i = 0; i < drawCount; i++) {
      if (state.deck.isEmpty) _reshuffleDeck(state);
      player.hand.add(state.deck.removeLast());
      
      // قاعدة الرحمة (25 ورقة = إقصاء)
      if (player.hand.length >= 25) {
        player.isEliminated = true;
        state.deck.insertAll(0, player.hand); // إعادة أوراقه للكومة
        player.hand.clear();
        break;
      }
    }
    
    state.stackAmount = 0;
    
    // إذا تبقى لاعب واحد فقط، يفوز
    if (state.players.where((p) => !p.isEliminated).length <= 1) {
      state.status = 'finished';
      return;
    }

    _advanceTurn(state);
  }

  // دوال مساعدة
  static void _advanceTurn(GameState state, {bool skip = false}) {
    int activePlayersCount = state.players.where((p) => !p.isEliminated).length;
    if (activePlayersCount <= 1) return;

    int currentIndex = state.players.indexWhere((p) => p.id == state.currentTurnId);
    int steps = skip ? 2 : 1;
    
    do {
      currentIndex = (currentIndex + (state.direction * steps) + state.players.length) % state.players.length;
      steps = 1; // إذا كان اللاعب مقصى، نقفز عنه بخطوة واحدة
    } while (state.players[currentIndex].isEliminated);

    state.currentTurnId = state.players[currentIndex].id;
  }

  static bool _isValidPlay(CardModel played, CardModel top, String activeColor, int stackAmount) {
    if (stackAmount > 0) {
      // يجب الرد بورقة سحب
      return played.value.contains('+') && played.value != 'W';
    }
    if (played.color == 'black') return true;
    return played.color == activeColor || played.value == top.value;
  }

  static void _reshuffleDeck(GameState state) {
    CardModel top = state.discardPile.removeLast();
    state.deck.addAll(state.discardPile);
    state.deck.shuffle();
    state.discardPile = [top];
  }

  static List<CardModel> _generateDeck() {
    List<CardModel> deck = [];
    final random = Random();
    for (var c in colors) {
      for (int i = 1; i <= 9; i++) {
        for(int j=0; j<3; j++) deck.add(CardModel(id: _genId(), color: c, value: i.toString()));
      }
      deck.add(CardModel(id: _genId(), color: c, value: '0')); deck.add(CardModel(id: _genId(), color: c, value: '0'));
      deck.add(CardModel(id: _genId(), color: c, value: '7')); deck.add(CardModel(id: _genId(), color: c, value: '7'));
      for (int i = 0; i < 3; i++) {
        deck.add(CardModel(id: _genId(), color: c, value: 'Skip'));
        deck.add(CardModel(id: _genId(), color: c, value: 'Rev'));
        deck.add(CardModel(id: _genId(), color: c, value: '+2'));
      }
      deck.add(CardModel(id: _genId(), color: c, value: '+4')); deck.add(CardModel(id: _genId(), color: c, value: '+4'));
    }
    for (int i = 0; i < 6; i++) {
      deck.add(CardModel(id: _genId(), color: 'black', value: 'W'));
      deck.add(CardModel(id: _genId(), color: 'black', value: 'W+6'));
      deck.add(CardModel(id: _genId(), color: 'black', value: 'W+10'));
    }
    deck.shuffle(random);
    return deck;
  }
  static String _genId() => DateTime.now().microsecondsSinceEpoch.toString() + Random().nextInt(1000).toString();
}
