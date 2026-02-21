import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MaPage extends StatefulWidget {
  const MaPage({super.key});

  @override
  State<MaPage> createState() => _MaPageState();
}

class _MaPageState extends State<MaPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 29, 102, 139),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 29, 102, 139),
        title: const Text(
          "SENECONSOM",
          style: TextStyle(color: Colors.white, fontSize: 26),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        margin: const EdgeInsets.only(top: 80),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 20),
          itemCount: 7,
          itemBuilder: (context, index) {
            switch (index) {
              case 0:
                return const Icon(
                  Icons.account_circle_rounded,
                  size: 80,
                  color: Color.fromARGB(255, 29, 102, 139),
                );

              case 1:
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Inscription",
                      style:
                          TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                );

              case 2:
                return champ(emailController, "Email", Icons.email);

              case 3:
                return champ(
                    passwordController, "Mot de passe", Icons.lock, true);

              case 4:
                return champ(
                    confirmController, "Confirmer", Icons.lock, true);

              case 5:
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color.fromARGB(255, 29, 102, 139),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
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
                        await FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: emailController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                        Navigator.pop(context);
                      } on FirebaseAuthException catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text(e.message ?? "Erreur d'inscription")),
                        );
                      }
                    },
                    child: const Text(
                      "S'enregistrer",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );

              default:
                return const SizedBox(height: 20);
            }
          },
        ),
      ),
    );
  }

  Widget champ(TextEditingController c, String label, IconData icon,
      [bool hide = false]) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color.fromARGB(255, 223, 246, 249),
      ),
      child: TextField(
        controller: c,
        obscureText: hide,
        decoration: InputDecoration(
          icon: Icon(icon),
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
