import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AlarmScreen extends StatefulWidget {
  final String medicineName;
  final VoidCallback onTaken;
  final VoidCallback onSnooze;

  const AlarmScreen({
    required this.medicineName,
    required this.onTaken,
    required this.onSnooze,
  });

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen> {
  final FlutterTts tts = FlutterTts();
  bool isSpeaking = true;

  @override
  void initState() {
    super.initState();
    startSpeaking();
  }

  Future startSpeaking() async {
    await tts.setLanguage("en-US");
    await tts.setSpeechRate(0.5);

    while (isSpeaking) {
      await tts.speak("It's time to take ${widget.medicineName}");
      await Future.delayed(Duration(seconds: 3));
    }
  }

  Future stopSpeaking() async {
    isSpeaking = false;
    await tts.stop();
  }

  @override
  void dispose() {
    tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("⏰ Medicine Time",
                style: TextStyle(fontSize: 24, color: Colors.white)),

            SizedBox(height: 10),

            Text(widget.medicineName,
                style: TextStyle(fontSize: 32, color: Colors.white)),

            SizedBox(height: 40),

            ElevatedButton(
              onPressed: () async {
                await stopSpeaking();
                widget.onTaken();
                Navigator.pop(context);
              },
              child: Text("Taken"),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await stopSpeaking();
                widget.onSnooze();
                Navigator.pop(context);
              },
              child: Text("Remind after 2 min"),
            ),
          ],
        ),
      ),
    );
  }
}