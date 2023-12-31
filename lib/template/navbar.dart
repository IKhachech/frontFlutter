import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NavBar extends StatelessWidget implements PreferredSizeWidget {
  String navTitle;
  NavBar(this.navTitle, {super.key});
  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 68, 255, 224), // Change the background color
      title: Text(
        navTitle,
        style: const TextStyle(
          color: Color.fromARGB(255, 189, 63, 10), // Change the text color
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            Navigator.of(context).popAndPushNamed('/login');
          },
          color: Colors.white, // Change the icon color
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
