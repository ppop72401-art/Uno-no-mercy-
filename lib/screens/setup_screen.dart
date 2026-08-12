import 'dart:io';
import 'package:flutter/material.dart';
import '../core/network_manager.dart';
import 'lobby_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});
  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  List<String> myIps = [];
  final nameController = TextEditingController();
  final ipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchIps();
  }

  Future<void> _fetchIps() async {
    List<String> ips = [];
    for (var interface in await NetworkInterface.list()) {
      for (var addr in interface.addresses) {
        if (addr.type == InternetAddressType.IPv4) ips.add(addr.address);
      }
    }
    setState(() => myIps = ips);
  }

  void _hostGame() async {
    if (nameController.text.isEmpty) return;
    await NetworkManager().startHost(8080, nameController.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LobbyScreen()));
  }

  void _joinGame() async {
    if (nameController.text.isEmpty || ipController.text.isEmpty) return;
    await NetworkManager().joinGame(ipController.text, 8080, nameController.text);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LobbyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "أونو هوت سبوت",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFFFF4B4B)),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "اسمك",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 20),
              Text("الـ IP الخاص بك: ${myIps.join(' | ')}", textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _hostGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF58CC02),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: const Text("إنشاء روم (Host)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              const SizedBox(height: 30),
              const Divider(color: Colors.grey),
              const SizedBox(height: 30),
              TextField(
                controller: ipController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "أدخل IP السيرفر للاتصال",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                onPressed: _joinGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1CB0F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: const Text("انضمام للروم (Client)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
