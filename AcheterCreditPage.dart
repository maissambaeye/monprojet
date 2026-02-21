import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'bottom_nav.dart';
import 'services/notification_service.dart'; 

class AcheterCreditPage extends StatefulWidget {
  const AcheterCreditPage({super.key});

  @override
  State<AcheterCreditPage> createState() => _AcheterCreditPageState();
}

class _AcheterCreditPageState extends State<AcheterCreditPage> {

  final montantController = TextEditingController();

  double? kwhAchete;
  int? dureeEstimee;
  bool achatEffectue = false;
  bool loading = false;

  final mainColor = Colors.blue;

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),


      appBar: AppBar(
        elevation: 0,
        title: const Text("Acheter du crédit"),
        centerTitle: true,
        backgroundColor: mainColor,
      ),


      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [


            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [mainColor, mainColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: mainColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                children: const [
                  Icon(Icons.flash_on, size: 50, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    "Achetez votre crédit électricité",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),


            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                  )
                ],
              ),
              child: Column(
                children: [

                  TextField(
                    controller: montantController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Montant FCFA",
                      prefixIcon: const Icon(Icons.money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),


                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: mainColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),

                      onPressed: loading ? null : () async {

                        if (montantController.text.isEmpty) return;

                        setState(() => loading = true);

                        double montant =
                            double.tryParse(montantController.text) ?? 0;

                        double kwh = montant / 82;
                        double consoMoyenneJour = 17;

                        await FirebaseFirestore.instance
                            .collection("credits")
                            .add({
                          "uid": user!.uid,
                          "montant": montant,
                          "kwh": kwh,
                          "kwhConsomme": 0.0,
                          "date": Timestamp.now(),
                        });


                        NotificationsService.showNotification(
                          id: 50,
                          title: "Achat réussi",
                          body:
                              "Vous avez acheté ${kwh.toStringAsFixed(2)} kWh",
                        );

                        setState(() {
                          kwhAchete = kwh;
                          dureeEstimee =
                              (kwh / consoMoyenneJour).round();
                          achatEffectue = true;
                          loading = false;
                        });
                      },

                      child: loading
                          ? const CircularProgressIndicator(
                              color: Colors.white)
                          : const Text(
                              "Acheter maintenant",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),


            if (achatEffectue)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  children: [

                    const Icon(Icons.check_circle,
                        size: 60, color: Colors.white),

                    const SizedBox(height: 15),

                    const Text(
                      "Achat réussi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "🔋 Crédit obtenu : ${kwhAchete!.toStringAsFixed(2)} kWh",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "⏳ Durée estimée : $dureeEstimee jours",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
