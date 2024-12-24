import 'package:flutter/material.dart';
import 'package:skfinance/PartyDetailScreen.dart';
import 'package:skfinance/Utilities/PartyScreen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<IconData> icons;
  final List<Widget> screens;

  const CustomBottomNavigationBar({
    super.key,
    required this.icons,
    required this.screens,
  }) : assert(icons.length == screens.length,
            'Icons and screens lists must have the same length.');

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 40, 65, 2),
      shape: const CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            return IconButton(
              icon: Icon(icons[index], color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screens[index]),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
