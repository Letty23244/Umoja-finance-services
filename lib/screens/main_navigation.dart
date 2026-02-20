import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/profile_screen.dart';
import 'home_screen.dart';
import 'saving_screens.dart';
import 'loan_screen.dart';
import 'StatementScreen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    SavingsScreen(),
    LoansScreen(),
    StatementsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF795548),
        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: "Savings",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Loans",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: "Statements",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person),
              label: "Profile"),
        ],
      ),
    );
  }
}
