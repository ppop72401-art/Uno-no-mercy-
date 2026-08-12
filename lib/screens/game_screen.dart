import 'package:flutter/material.dart';
import '../core/network_manager.dart';
import '../models/game_state.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ValueListenableBuilder<GameState?>(
          valueListenable: NetworkManager().gameStateNotifier,
          builder: (context, state, child) {
            if (state == null) return const SizedBox();

            // العثور على أوراق اللاعب الحالي لعرضها
            Player me = state.players.firstWhere((p) => p.id == NetworkManager().myPlayerId, 
              orElse: () => Player(id: '', name: '', hand: []));
            
            bool isMyTurn = state.currentTurnId == NetworkManager().myPlayerId;

            return Column(
              children: [
                // الشريط العلوي (الخصوم)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1F2C34),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: state.players.where((p) => p.id != me.id).map((p) => Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: state.currentTurnId == p.id ? const Color(0xFFFFC800) : Colors.grey,
                          radius: 30,
                          child: Text(p.name[0], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
                          child: Text("${p.hand.length} أوراق", style: const TextStyle(fontSize: 12)),
                        )
                      ],
                    )).toList(),
                  ),
                ),
                
                // الطاولة (السحب والرمي)
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // كومة السحب
                        GestureDetector(
                          onTap: isMyTurn ? () {
                            NetworkManager().sendAction({'action': 'draw_card', 'playerId': me.id});
                          } : null,
                          child: Container(
                            width: 80, height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B333A),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(-4, 4))],
                            ),
                            child: const Center(child: Text("UNO", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.grey))),
                          ),
                        ),
                        const SizedBox(width: 40),
                        // كومة اللعب
                        Container(
                          width: 80, height: 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFF1CB0F6), // مثال لون أزرق
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                          ),
                          child: const Center(child: Text("5", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                      ],
                    ),
                  ),
                ),

                // أوراق اللاعب الحالي
                Container(
                  height: 150,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: me.hand.isNotEmpty ? me.hand.length : 5, // 5 للتمثيل المرئي فقط إذا كانت فارغة
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: isMyTurn ? () {
                          // إرسال أمر اللعب
                          NetworkManager().sendAction({'action': 'play_card', 'cardId': 'some_id'});
                        } : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: 70,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF4B4B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.3), width: 6)),
                          ),
                          child: const Center(child: Text("7", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
