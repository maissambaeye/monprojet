import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MaPage extends StatefulWidget {
  const MaPage({super.key});

  @override
  State<MaPage> createState() => _MaPageState();
}

class _MaPageState extends State<MaPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final compteurController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue, Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              children: [
              
                const Text(
                  "SENECONSOM",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

               
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 60,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Créer un compte",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 25),

                     
                      _inputField(
                        controller: nameController,
                        label: "Nom complet",
                        hint: "Ex : Amadou Ndiaye",
                        icon: Icons.person,
                      ),
                      const SizedBox(height: 15),

                     
                      _inputField(
                        controller: emailController,
                        label: "Email",
                        hint: "Ex : amadou@gmail.com",
                        icon: Icons.email,
                      ),
                      const SizedBox(height: 15),

                     
                      _inputField(
                        controller: compteurController,
                        label: "Numéro compteur",
                        hint: "Ex : 123456789",
                        icon: Icons.electric_meter,
                      ),
                      const SizedBox(height: 15),


                      _inputField(
                        controller: passwordController,
                        label: "Mot de passe",
                        hint: "Minimum 6 caractères",
                        icon: Icons.lock,
                        obscure: true,
                      ),
                      const SizedBox(height: 15),

                      
                      _inputField(
                        controller: confirmController,
                        label: "Confirmer mot de passe",
                        hint: "Retapez le mot de passe",
                        icon: Icons.lock_outline,
                        obscure: true,
                      ),
                      const SizedBox(height: 25),

                      
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: () async {
                            if (passwordController.text !=
                                confirmController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Les mots de passe ne correspondent pas"),
                                ),
                              );
                              return;
                            }

                            try {
                             
                              UserCredential userCredential =
                                  await FirebaseAuth.instance
                                      .createUserWithEmailAndPassword(
                                email: emailController.text.trim(),
                                password: passwordController.text.trim(),
                              );

                              final uid = userCredential.user!.uid;

                             
                              await FirebaseFirestore.instance
                                  .collection("users")
                                  .doc(uid)
                                  .set({
                                "fullName": nameController.text.trim(),
                                "email": emailController.text.trim(),
                                "numeroCompteur":
                                    compteurController.text.trim(),
                                "createdAt": Timestamp.now(),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Compte créé avec succès !"),
                                ),
                              );

                              Navigator.pop(context);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          },
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(
                                fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Déjà un compte ? Se connecter",
                          style: TextStyle(
                            color: Colors.indigo,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.indigo),
        filled: true,
        fillColor: const Color(0xFFE0F0FF), // fond bleu clair
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
