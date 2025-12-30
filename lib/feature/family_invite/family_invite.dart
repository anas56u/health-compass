import 'package:flutter/material.dart';

class FamilyInvitePage extends StatefulWidget {
  const FamilyInvitePage({super.key});

  @override
  State<FamilyInvitePage> createState() => _FamilyInvitePageState();
}

class _FamilyInvitePageState extends State<FamilyInvitePage> {
  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFFE8EEF5); 
    const primaryColor = Color(0xFF1ABC9C);
    const darkText = Color(0xFF2D3E50);

    return Theme(
      data: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            backgroundColor: primaryColor,
            elevation: 4,
            shape: const CircleBorder(), 
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(darkText),

                Expanded(
                  child: Center(
                    child: SingleChildScrollView( 
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'قم باضافة افراد عائلتك لمتابعه حالتك الصحيه',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF5A6B7C),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          
                          _buildActionCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeader(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حليم المجالي',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'حساب مرافق',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],
          ),

          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey.shade600, size: 28),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4), 
      ),
      child: Column(
        children: [
          _buildStyledButton(
            text: 'قم بدعوة افراد عائلتك من خلال الرابط او من واتس اب',
            icon: Icons.chat_bubble, 
            iconColor: Colors.green,
            onPressed: () {},
          ),

          const SizedBox(height: 20),

          _buildOrDivider(),

          const SizedBox(height: 20),

          _buildStyledButton(
            text: 'قم بالتسجيل يدوياً',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStyledButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    Color? iconColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55, 
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE8EEF5),
          foregroundColor: Colors.black54, 
          elevation: 4,
          shadowColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Colors.grey, width: 0.5), 
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
            ],
            Flexible( 
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'أو',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey, thickness: 1)),
      ],
    );
  }
}