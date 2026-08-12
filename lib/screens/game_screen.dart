import '../widgets/playing_card_widget.dart'; // لا تنسَ استدعاء الملف الجديد في الأعلى

// ... (بقية كود شاشة GameScreen الموجود مسبقاً)

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
                      side: const BorderSide(color: Color(0xFFCB3232), width: 4), // حافة سفلية
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
                        isPlayable: isMyTurn, // لاحقاً يمكن إضافة دالة من GameEngine للتحقق الفعلي
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
