import 'package:flutter/material.dart';
import '../core/network_manager.dart';
import '../models/game_state.dart';
import '../widgets/playing_card_widget.dart';

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
                            color: const Color(0xFF1CB0F6), 
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 10)],
                          ),
                          child: const Center(child: Text("5", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white))),
                        ),
                      ],
                    ),
                  ),
                ),

                // زر الأونو! (يوضع فوق الأوراق)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: isMyTurn ? () {
                      NetworkManager().sendAction({'action': 'call_uno', 'playerId': me.id});
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF4B4B),
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: const BorderSide(color: Color(0xFFCB3232), width: 4),
                      elevation: 0,
                    ),
                    child: const Text("UNO!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),

                // أوراق اللاعب الحالي الحقيقية (ديناميكية)
                Container(
                  height: 130,
                  padding: const EdgeInsets.only(bottom: 15),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: me.hand.length,
                    itemBuilder: (context, index) {
                      final card = me.hand[index];
                      return PlayingCardWidget(
                        card: card,
                        isPlayable: isMyTurn, 
                        onTap: () {
                          // إرسال أمر لعب الورقة للسيرفر
                          NetworkManager().sendAction({'action': 'play_card', 'cardId': card.id});
                        },
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
