import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import 'game_engine.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  bool isHost = false;
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  List<Socket> _clients = [];
  String myPlayerId = '';

  final ValueNotifier<GameState?> gameStateNotifier = ValueNotifier(null);

  Future<void> startHost(int port, String hostName) async {
    isHost = true;
    myPlayerId = 'host_1';
    
    GameState initialState = GameState(
      status: 'waiting',
      players: [Player(id: myPlayerId, name: hostName, hand: [])],
      currentTurnId: '',
      discardPile: [],
      deck: [],
    );
    gameStateNotifier.value = initialState;

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket!.listen((Socket client) {
      _clients.add(client);
      client.listen((data) {
        _handleIncomingDataHost(utf8.decode(data), client);
      }, onDone: () => _clients.remove(client));
    });
  }

  void startGame() {
    if (!isHost || gameStateNotifier.value == null) return;
    
    // ربط المحرك: هنا يتم توليد الأوراق وتوزيعها فعلياً!
    GameEngine.initializeGame(gameStateNotifier.value!);
    _broadcastGameState();
  }

  void _handleIncomingDataHost(String data, Socket client) {
    try {
      final decoded = jsonDecode(data);
      final state = gameStateNotifier.value!;

      if (decoded['action'] == 'join') {
        String newPlayerId = 'player_${_clients.length}';
        state.players.add(Player(id: newPlayerId, name: decoded['name'], hand: []));
        client.add(utf8.encode(jsonEncode({'type': 'assign_id', 'id': newPlayerId})));
        _broadcastGameState();
        
      } else if (decoded['action'] == 'play_card') {
        // ربط المحرك: معالجة لعب الورقة
        if (state.currentTurnId == decoded['playerId']) {
          GameEngine.processPlay(state, decoded['playerId'], decoded['cardId']);
          // إذا كانت الورقة سوداء، نحدث اللون المطلوب
          if (decoded['color'] != null) {
            state.activeColor = decoded['color'];
          }
          _broadcastGameState();
        }
      } else if (decoded['action'] == 'draw_card') {
        // ربط المحرك: معالجة سحب الورقة
        if (state.currentTurnId == decoded['playerId']) {
          GameEngine.processDraw(state, decoded['playerId']);
          _broadcastGameState();
        }
      }
    } catch (e) {
      print("Host error: $e");
    }
  }

  void _broadcastGameState() {
    if (!isHost || gameStateNotifier.value == null) return;
    String stateJson = jsonEncode({'type': 'state_update', 'state': gameStateNotifier.value!.toJson()});
    for (var client in _clients) {
      client.add(utf8.encode(stateJson));
    }
    gameStateNotifier.notifyListeners(); 
  }

  Future<void> joinGame(String ip, int port, String playerName) async {
    isHost = false;
    _clientSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
    sendAction({'action': 'join', 'name': playerName});

    _clientSocket!.listen((data) {
      try {
        final decoded = jsonDecode(utf8.decode(data));
        if (decoded['type'] == 'assign_id') {
          myPlayerId = decoded['id'];
        } else if (decoded['type'] == 'state_update') {
          gameStateNotifier.value = GameState.fromJson(decoded['state']);
        }
      } catch (e) {
        print("Client error: $e");
      }
    });
  }

  void sendAction(Map<String, dynamic> action) {
    // التأكد من إرفاق الـ ID مع كل حركة
    action['playerId'] = myPlayerId;
    
    if (isHost) {
      // السيرفر يعالج حركته داخلياً
      String simulatedNetworkData = jsonEncode(action);
      _handleIncomingDataHost(simulatedNetworkData, _clients.isNotEmpty ? _clients.first : Socket.connect('localhost', 80) as Socket); 
    } else {
      _clientSocket?.add(utf8.encode(jsonEncode(action)));
    }
  }
}
