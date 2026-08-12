import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';

class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  bool isHost = false;
  ServerSocket? _serverSocket;
  Socket? _clientSocket;
  List<Socket> _clients = [];
  
  String myPlayerId = '';

  // Stream لبث حالة اللعبة للواجهة
  final ValueNotifier<GameState?> gameStateNotifier = ValueNotifier(null);

  // --- دوال السيرفر (Host) ---
  Future<void> startHost(int port, String hostName) async {
    isHost = true;
    myPlayerId = 'host_1';
    
    // إنشاء حالة مبدئية
    GameState initialState = GameState(
      status: 'waiting',
      players: [Player(id: myPlayerId, name: hostName, hand: [])],
      currentTurnId: '',
      discardPile: [],
    );
    gameStateNotifier.value = initialState;

    _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
    _serverSocket!.listen((Socket client) {
      _clients.add(client);
      
      client.listen((data) {
        _handleIncomingDataHost(utf8.decode(data), client);
      }, onDone: () {
        _clients.remove(client);
      });
    });
  }

  void _handleIncomingDataHost(String data, Socket client) {
    try {
      final decoded = jsonDecode(data);
      if (decoded['action'] == 'join') {
        String newPlayerId = 'player_${_clients.length}';
        String newName = decoded['name'];
        gameStateNotifier.value!.players.add(Player(id: newPlayerId, name: newName, hand: []));
        
        // إرسال الـ ID للاعب الجديد
        client.add(utf8.encode(jsonEncode({'type': 'assign_id', 'id': newPlayerId})));
        _broadcastGameState();
      } else if (decoded['action'] == 'play_card') {
        // هنا يتم كتابة منطق اللعب المركزي (تحديث الأوراق والدور)
        // ثم البث للجميع:
        _broadcastGameState();
      }
    } catch (e) {
      print("Host parse error: $e");
    }
  }

  void _broadcastGameState() {
    if (!isHost || gameStateNotifier.value == null) return;
    String stateJson = jsonEncode({'type': 'state_update', 'state': gameStateNotifier.value!.toJson()});
    for (var client in _clients) {
      client.add(utf8.encode(stateJson));
    }
    // تحديث واجهة السيرفر نفسه
    gameStateNotifier.notifyListeners(); 
  }

  // بدأ اللعبة من قبل السيرفر
  void startGame() {
    if (!isHost) return;
    gameStateNotifier.value!.status = 'playing';
    gameStateNotifier.value!.currentTurnId = gameStateNotifier.value!.players.first.id;
    // (هنا تقوم بتوزيع الأوراق برمجياً على اللاعبين)
    _broadcastGameState();
  }


  // --- دوال العميل (Client) ---
  Future<void> joinGame(String ip, int port, String playerName) async {
    isHost = false;
    _clientSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
    
    // إرسال طلب انضمام
    sendAction({'action': 'join', 'name': playerName});

    _clientSocket!.listen((data) {
      String msgs = utf8.decode(data);
      // قد تصل عدة رسائل مدمجة، يجب معالجتها بشكل صحيح (تم التبسيط هنا)
      try {
        final decoded = jsonDecode(msgs);
        if (decoded['type'] == 'assign_id') {
          myPlayerId = decoded['id'];
        } else if (decoded['type'] == 'state_update') {
          gameStateNotifier.value = GameState.fromJson(decoded['state']);
        }
      } catch (e) {
        print("Client parse error: $e");
      }
    });
  }

  void sendAction(Map<String, dynamic> action) {
    if (isHost) {
      // إذا كان السيرفر هو من يلعب، يعالجها مباشرة
      // _processAction(action); 
      _broadcastGameState();
    } else {
      _clientSocket?.add(utf8.encode(jsonEncode(action)));
    }
  }
}
