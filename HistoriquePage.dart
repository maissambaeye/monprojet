import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'Accueilpage.dart';
import 'SimulationPage.dart';
import 'AcheterCreditPage.dart';
import 'main.dart';
import 'bottom_nav.dart';

class HistoriquePage extends StatelessWidget {
  const HistoriquePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

////////////////////////////////////////////////////////////
/// APPBAR
////////////////////////////////////////////////////////////
      appBar: AppBar(
        title: const Text("Historique", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.blue),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "logout",
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.black54),
                    SizedBox(width: 10),
                    Text("Déconnexion"),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == "logout") {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MyApp()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),

////////////////////////////////////////////////////////////
/// BODY
////////////////////////////////////////////////////////////
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("credits")
            .where("uid", isEqualTo: user!.uid)
            .orderBy("date", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Aucune recharge trouvée",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {

              final data = docs[index].data() as Map<String, dynamic>;

              double montant = ((data["montant"] ?? 0) as num).toDouble();
              double kwhRestant = ((data["kwh"] ?? 0) as num).toDouble();
              double kwhConsomme = ((data["kwhConsomme"] ?? 0) as num).toDouble();

              // 🔥 BLOQUE A ZERO
              if (kwhRestant < 0) kwhRestant = 0;

              final date = (data["date"] as Timestamp).toDate();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.8),
                      Colors.indigo.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),

////////////////////////////////////////////////////////////
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

////////////////////////////////////////////////////////////
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${montant.toStringAsFixed(0)} FCFA",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          DateFormat('dd/MM/yyyy').format(date),
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

////////////////////////////////////////////////////////////
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        Row(
                          children: [
                            const Icon(Icons.flash_on,
                                color: Colors.yellowAccent),
                            const SizedBox(width: 6),
                            Text(
                              "${kwhRestant.toStringAsFixed(2)} kWh restant",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            const Icon(Icons.power,
                                color: Colors.orangeAccent),
                            const SizedBox(width: 6),
                            Text(
                              "${kwhConsomme.toStringAsFixed(2)} kWh consommé",
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

////////////////////////////////////////////////////////////
/// PROGRESS
////////////////////////////////////////////////////////////
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: kwhRestant == 0
                            ? 1
                            : (kwhConsomme / (kwhConsomme + kwhRestant))
                                .clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: Colors.white24,
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.indigo],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: 2,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Pagee()),
                );
              }
              if (i == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SimulationPage()),
                );
              }
              if (i == 2) {
                // On est déjà sur Historique
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 28),
                label: "Accueil",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calculate, size: 28),
                label: "Simulation",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history, size: 28),
                label: "Historique",
              ),
            ],
          ),
        ),
      ),

    );
  }
}
