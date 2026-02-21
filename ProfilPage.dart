import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'main.dart';
import 'CreerCompte.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      
      appBar: AppBar(
        title: const Text("Mon profil"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),

      
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user!.uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          String fullName = data?["fullName"] ?? "Non défini";
          String email = data?["email"] ?? user.email ?? "Non défini";
          String compteur = data?["numeroCompteur"] ?? "Non défini";

          return Column(
            children: [

             
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                       Colors.blue,
                      Colors.indigo,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.blue,
                        size: 50,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

             
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [

                        _infoRow(Icons.person, "Nom", fullName),
                        const Divider(),

                        _infoRow(Icons.email, "Email", email),
                        const Divider(),

                        _infoRow(Icons.electric_meter, "Numéro compteur", compteur),
                        const Divider(),

                        _infoRow(Icons.verified_user, "Statut", "Utilisateur actif"),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(

                    onPressed: () async {

                      await FirebaseAuth.instance.signOut();

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AppliTest()),
                        (route) => false,
                      );
                    },

                    icon: const Icon(Icons.logout),
                    label: const Text("Se déconnecter"),

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  
  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [

          Icon(icon, color: Colors.blue),

          const SizedBox(width: 12),

          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
