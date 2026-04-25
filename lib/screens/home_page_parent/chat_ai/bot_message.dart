import 'package:flutter/material.dart';

class BotMessage extends StatelessWidget {
  final String text;

  const BotMessage({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.android, color: Colors.white),
        ),
        const SizedBox(width: 8),

        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(maxWidth: 250),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Text(text),
        ),
      ],
    );
  }
}