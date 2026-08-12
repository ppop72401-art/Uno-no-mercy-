import 'dart:convert';

class CardModel {
  final String id;
  final String color;
  final String value;

  CardModel({required this.id, required this.color, required this.value});

  Map<String, dynamic> toJson() => {'id': id, 'color': color, 'value': value};

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      color: json['color'] as String,
      value: json['value'] as String,
    );
  }
}

class Player {
  final String id;
  final String name;
  List<CardModel> hand;
  bool isEliminated;

  Player({required this.id, required this.name, required this.hand, this.isEliminated = false});

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'hand': hand.map((c) => c.toJson()).toList(),
    'isEliminated': isEliminated,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      hand: (json['hand'] as List).map((c) => CardModel.fromJson(c as Map<String, dynamic>)).toList(),
      isEliminated: json['isEliminated'] ?? false,
    );
  }
}

class GameState {
  String status;
  List<Player> players;
  String currentTurnId;
  List<CardModel> discardPile;
  List<CardModel> deck;
  int direction; // 1 مع عقارب الساعة, -1 عكس عقارب الساعة
  int stackAmount; // للتراكم (قوانين لا رحمة)
  String activeColor;

  GameState({
    required this.status,
    required this.players,
    required this.currentTurnId,
    required this.discardPile,
    required this.deck,
    this.direction = 1,
    this.stackAmount = 0,
    this.activeColor = '',
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'players': players.map((p) => p.toJson()).toList(),
    'currentTurnId': currentTurnId,
    'discardPile': discardPile.map((c) => c.toJson()).toList(),
    'deck': deck.map((c) => c.toJson()).toList(),
    'direction': direction,
    'stackAmount': stackAmount,
    'activeColor': activeColor,
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      status: json['status'] as String,
      players: (json['players'] as List).map((p) => Player.fromJson(p as Map<String, dynamic>)).toList(),
      currentTurnId: json['currentTurnId'] as String,
      discardPile: (json['discardPile'] as List).map((c) => CardModel.fromJson(c as Map<String, dynamic>)).toList(),
      deck: (json['deck'] as List).map((c) => CardModel.fromJson(c as Map<String, dynamic>)).toList(),
      direction: json['direction'] as int,
      stackAmount: json['stackAmount'] as int,
      activeColor: json['activeColor'] as String,
    );
  }
}
