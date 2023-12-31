import 'package:flutter/material.dart';
import 'package:tp70/template/navbar.dart';

class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NavBar('Dashboard'),
      backgroundColor: Color.fromARGB(255, 214, 215, 215), // Change the background color
      drawer: Drawer(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 68, 255, 224), // Change the header background color
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Etudiant'),
              onTap: () {
                Navigator.pushNamed(context, '/students');
              },
            ),
            ListTile(
              title: const Text('Classes'),
              onTap: () {
                Navigator.pushNamed(context, '/class');
              },
            ),
            ListTile(
              title: const Text('Matiers'),
              onTap: () {
                Navigator.pushNamed(context, '/matier');
              },
            ),
            ListTile(
              title: const Text('Absences'),
              onTap: () {
                Navigator.pushNamed(context, '/absences');
              },
            ),
            ListTile(
              title: const Text('Formations'),
              onTap: () {
                Navigator.pushNamed(context, '/formation');
              },
            ),

            ////////up
             ListTile(
              title: const Text('AbscenceMat'),
              onTap: () {
                Navigator.pushNamed(context, '/abscencesMat');
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Hello world',
              style: TextStyle(
                fontSize: 30.0,
                fontFamily: 'Agne',
                color: Colors.white, // Change the text color
              ),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
