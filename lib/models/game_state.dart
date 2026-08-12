import 'dart:convert';

class CardModel {
  final String id;
  final String color;
  final String value;

  CardModel({required this.id, required this.color, required this.value});

  Map<String, dynamic> toJson() => {'id': id, 'color': color, 'value': value};

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(id: json['id'], color: json['color'], value: json['value']);
  }
}

class Player {
  final String id;
  final String name;
  List<CardModel> hand;

  Player({required this.id, required this.name, required this.hand});

  Map<String, dynamic> toJson() => {
    'id': id, 
    'name': name, 
    'hand': hand.map((c) => c.toJson()).toList()
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      hand: (json['hand'] as List).map((c) => CardModel.fromJson(c)).toList(),
    );
  }
}

class GameState {
  String status; // 'waiting', 'playing', 'finished'
  List<Player> players;
  String currentTurnId;
  List<CardModel> discardPile;

  GameState({
    required this.status,
    required this.players,
    required this.currentTurnId,
    required this.discardPile,
  });

  Map<String, dynamic> toJson() => {
    'status': status,
    'players': players.map((p) => p.toJson()).toList(),
    'currentTurnId': currentTurnId,
    'discardPile': discardPile.map((c) => c.toJson()).toList(),
  };

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      status: json['status'],
      players: (json['players'] as List).map((p) => Player.fromJson(p)).toList(),
      currentTurnId: json['currentTurnId'],
      discardPile: (json['discardPile'] as List).map((c) => CardModel.fromJson(c)).toList(),
    );
  }
}
