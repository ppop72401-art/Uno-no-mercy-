import 'package:flutter/material.dart';
import '../core/network_manager.dart';
import '../models/game_state.dart';
import 'game_screen.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("غرفة الانتظار"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<GameState?>(
        valueListenable: NetworkManager().gameStateNotifier,
        builder: (context, state, child) {
          if (state == null) return const Center(child: CircularProgressIndicator());
          
          // إذا تم تحويل الحالة إلى playing، ننتقل فوراً لشاشة اللعب
          if (state.status == 'playing') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GameScreen()));
            });
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.players.length,
                  itemBuilder: (context, index) {
                    return Card(
                      color: const Color(0xFF1F2C34),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: Color(0xFF58CC02), child: Icon(Icons.person, color: Colors.white)),
                        title: Text(state.players[index].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    );
                  },
                ),
              ),
              if (NetworkManager().isHost)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    onPressed: () => NetworkManager().startGame(),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      backgroundColor: const Color(0xFFFF4B4B),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text("بدء اللعبة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
