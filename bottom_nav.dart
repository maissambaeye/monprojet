import 'package:flutter/material.dart';
import 'Accueilpage.dart';
import 'SimulationPage.dart'; 
import 'HistoriquePage.dart';

BottomNavigationBar customBottomNavBar(BuildContext context, int currentIndex) {
  return BottomNavigationBar(
    currentIndex: currentIndex,
    onTap: (i) {
      if (i == 0) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const Pagee()));
      } else if (i == 1) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const SimulationPage()));
      } else if (i == 2) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HistoriquePage()));
      }
    },
    backgroundColor: Colors.white,
    elevation: 12,
    type: BottomNavigationBarType.fixed,
    selectedItemColor: const Color(0xFF1D668B),
    unselectedItemColor: Colors.grey.shade400,
    selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5),
    unselectedLabelStyle: const TextStyle(fontSize: 12, letterSpacing: 0.3),
    showUnselectedLabels: true,
    items: [
      BottomNavigationBarItem(
        icon: Icon(Icons.home, size: currentIndex == 0 ? 32 : 28),
        label: "Accueil",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.calculate, size: currentIndex == 1 ? 32 : 28),
        label: "Simulation",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.history, size: currentIndex == 2 ? 32 : 28),
        label: "Historique",
      ),
    ],
  );
}
