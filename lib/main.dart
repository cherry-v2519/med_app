import 'package:flutter/material.dart';
import 'notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(MyApp());
}

class Medicine {
  String name;
  String time;
  bool taken;
  bool notified;
  DateTime? snoozeUntil;

  Medicine({
    required this.name,
    required this.time,
    this.taken = false,
    this.notified = false,
    this.snoozeUntil,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Medicine> meds = [];

  @override
  void initState() {
    super.initState();
    startTimer();

    NotificationService.onAction = (action, payload) {
      NotificationService.cancelAll();

      if (action == 'taken') {
        setState(() {
          for (var m in meds) {
            if (m.name == payload) {
              m.taken = true;
            }
          }
        });
      }

      if (action == 'snooze') {
        setState(() {
          for (var m in meds) {
            if (m.name == payload) {
              m.snoozeUntil = DateTime.now().add(Duration(minutes: 2));
              m.notified = true;
            }
          }
        });

        Future.delayed(Duration(minutes: 2), () {
          NotificationService.showNotification(
            "Reminder Again",
            "Time to take $payload",
            payload: payload,
          );

          for (var m in meds) {
            if (m.name == payload) {
              m.notified = false;
            }
          }
        });
      }
    };
  }

  void startTimer() {
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 5));
      checkReminder();
      return true;
    });
  }

  void checkReminder() {
    final now = DateTime.now();

    for (var med in meds) {
      final parts = med.time.split(':');

      final medTime = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      if (med.snoozeUntil != null && now.isBefore(med.snoozeUntil!)) {
        continue;
      }

      if (!med.taken &&
          !med.notified &&
          now.hour == medTime.hour &&
          now.minute == medTime.minute) {

        NotificationService.showNotification(
          "Medicine Reminder",
          "Time to take ${med.name}",
          payload: med.name,
        );

        med.notified = true;
      }
    }
  }

  void addMedicine(String name, String time) {
    setState(() {
      meds.add(Medicine(name: name, time: time));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('💊 Medicine Reminder')),

      body: ListView.builder(
        itemCount: meds.length,
        itemBuilder: (context, i) {
          final m = meds[i];

          return Card(
            child: ListTile(
              title: Text(m.name),
              subtitle: Text("Time: ${m.time}"),
              trailing: Text(
                m.taken ? "Taken" : "Pending",
                style: TextStyle(
                  color: m.taken ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final nameController = TextEditingController();
          TimeOfDay? picked;

          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Add Medicine"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: "Medicine Name"),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                    },
                    child: Text("Pick Time"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (picked != null &&
                        nameController.text.isNotEmpty) {

                      final time =
                          "${picked!.hour.toString().padLeft(2, '0')}:${picked!.minute.toString().padLeft(2, '0')}";

                      addMedicine(nameController.text, time);
                    }
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}