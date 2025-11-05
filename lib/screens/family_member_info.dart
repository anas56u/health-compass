import 'package:flutter/material.dart';

class FamilyMemberInfoScreen extends StatelessWidget {
  const FamilyMemberInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Family Member Info")),
      body: const Center(
        child: Text(
          "صفحة فرد من العائلة - Test",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
