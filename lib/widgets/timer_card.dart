import 'package:flutter/material.dart';

class TimerCard extends StatelessWidget {
  final String menu;
  final String timeText;
  final VoidCallback onTap;

  const TimerCard({
    super.key,
    required this.menu,
    required this.timeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Text(menu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            timeText,
            style: TextStyle(color: Colors.orange[900], fontWeight: FontWeight.bold),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}