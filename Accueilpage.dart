import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'AcheterCreditPage.dart';
import 'SimulationPage.dart';
import 'ProfilPage.dart';
import 'HistoriquePage.dart';
import 'services/notification_service.dart';
import 'Notification.dart';
import 'bottom_nav.dart';

class Pagee extends StatefulWidget {
  const Pagee({super.key});

  @override
  State<Pagee> createState() => _PageeState();
}

class _PageeState extends State<Pagee> {

  final user = FirebaseAuth.instance.currentUser!;
  double totalKwh = 0;
  Timer? consumptionTimer;

  @override
  void initState() {
    super.initState();
    startConsumption();
    listenCreditPurchase(); 
  }

  @override
  void dispose() {
    consumptionTimer?.cancel();
    super.dispose();
  }


  void listenCreditPurchase() {

    FirebaseFirestore.instance
        .collection("credits")
        .where("uid", isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {

      for (var change in snapshot.docChanges) {

        if (change.type == DocumentChangeType.added) {

          final data = change.doc.data() as Map<String, dynamic>;

          NotificationsService.showNotification(
            id: 20,
            title: "Crédit ajouté",
            body: "+ ${data["kwh"]} kWh ajouté",
          );
        }
      }
    });
  }


  void startConsumption() {

    consumptionTimer =
        Timer.periodic(const Duration(minutes: 1), (timer) async {

      final creditsRef = FirebaseFirestore.instance.collection('credits');

      final snap = await creditsRef
          .where('uid', isEqualTo: user.uid)
          .orderBy('date', descending: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return;

      final doc = snap.docs.first;
      final data = doc.data();

      double oldKwh = ((data["kwh"] ?? 0) as num).toDouble();

      double oldConsomme = 0;
      if (data.containsKey("kwhConsomme")) {
        oldConsomme = ((data["kwhConsomme"] ?? 0) as num).toDouble();
      }

      if (oldKwh <= 0) return;

      double newValue = oldKwh - 2;
      if (newValue < 0) newValue = 0;

      await creditsRef.doc(doc.id).update({
        "kwh": newValue,
        "kwhConsomme": oldConsomme + (oldKwh - newValue),
      });

 

      if (newValue <= 10 && newValue > 5) {
        NotificationsService.showNotification(
          id: 1,
          title: "Attention",
          body: "Crédit bientôt faible (${newValue.toStringAsFixed(1)} kWh)",
        );
      }

      if (newValue <= 5 && newValue > 1) {
        NotificationsService.showNotification(
          id: 2,
          title: "Crédit faible",
          body: "Il reste ${newValue.toStringAsFixed(1)} kWh",
        );
      }

      if (newValue <= 1 && newValue > 0) {
        NotificationsService.showNotification(
          id: 3,
          title: "Crédit très faible",
          body: "Rechargez vite (${newValue.toStringAsFixed(1)} kWh)",
        );
      }

      if (newValue == 0) {
        NotificationsService.showNotification(
          id: 4,
          title: "Crédit terminé",
          body: "Votre crédit est fini ⚠",
        );
      }

    });
  }


  String conseilDuJour() {
    int day = DateTime.now().day;
    if (day <= 15) {
      return "Acheter maintenant vous donne 2% de kWh en plus.";
    }
    return "Surveillez votre consommation pour éviter les coupures.";
  }

  DateTime get today => DateTime.now();


  @override
  Widget build(BuildContext context) {

    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),


      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(user.uid)
              .snapshots(),
          builder: (context, snapshot) {

            String name = "Utilisateur";

            if (snapshot.hasData && snapshot.data!.exists) {
              final data = snapshot.data!.data() as Map<String, dynamic>;
              name = data["fullName"] ?? name;
            }

            return Text(
              "Bonjour, $name",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            );
          },
        ),

        actions: [

          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilPage()),
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),

          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsPage()),
                  );
                },
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            ],
          ),
        ],
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [


            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("credits")
                  .where("uid", isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {

                totalKwh = 0;
                double totalMontant = 0;

                if (snapshot.hasData) {
                  for (var doc in snapshot.data!.docs) {
                    final data = doc.data() as Map<String, dynamic>;

                    totalKwh += ((data["kwh"] ?? 0) as num).toDouble();
                    totalMontant +=
                        ((data["montant"] ?? 0) as num).toDouble();
                  }
                }

                double progress = (totalKwh / 50).clamp(0, 1);

                return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.indigo],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text(
                        "Crédit restant",
                        style:
                            TextStyle(color: Colors.white70, fontSize: 18),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "${totalKwh.toStringAsFixed(1)} kWh",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${totalMontant.toStringAsFixed(0)} F CFA",
                        style:
                            const TextStyle(color: Colors.white70),
                      ),

                      const SizedBox(height: 15),

                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        color: Colors.amberAccent,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 25),


            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_shopping_cart,color: Colors.yellowAccent,),
                label: const Text(
                  "Acheter du crédit",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AcheterCreditPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 25),


            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb,
                        color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(child: Text(conseilDuJour())),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),


            Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HistoriquePageFiltered(
                            start: startOfDay,
                            end: endOfDay,
                          ),
                        ),
                      );
                    },
                    child: _box(
                        Colors.blue, Colors.indigo,
                        Icons.today, "Aujourd'hui"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoriquePage()),
                      );
                    },
                    child: _box(
                        Colors.green, Colors.teal,
                        Icons.history, "Dernières actions"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),


      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.indigo],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          onTap: (i) {
            if (i == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SimulationPage()));
            }
            if (i == 2) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const HistoriquePage()));
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Accueil"),
            BottomNavigationBarItem(
                icon: Icon(Icons.calculate), label: "Simulation"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: "Historique"),
          ],
        ),
      ),
    );
  }


  Widget _box(Color c1, Color c2, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [c1, c2]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 10),
          Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
class HistoriquePageFiltered extends StatelessWidget {

  final DateTime? start;
  final DateTime? end;
  final int? limit;

  const HistoriquePageFiltered({
    super.key,
    this.start,
    this.end,
    this.limit,
  });

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    Query query = FirebaseFirestore.instance
        .collection("credits")
        .where("uid", isEqualTo: user!.uid)
        .orderBy("date", descending: true);

    if (start != null && end != null) {
      query = query
          .where("date",
              isGreaterThanOrEqualTo:
                  Timestamp.fromDate(start!))
          .where("date",
              isLessThanOrEqualTo:
                  Timestamp.fromDate(end!));
    }

    if (limit != null) {
      query = query.limit(limit!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Historique"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Aucune donnée"));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {

              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;

              final date =
                  (data['date'] as Timestamp).toDate();

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flash_on,
                      color: Colors.blue),
                  title: Text("${data['kwh']} kWh"),
                  subtitle:
                      Text("${data['montant']} F CFA"),
                  trailing:
                      Text(DateFormat("dd/MM/yyyy").format(date)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
