import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/widgets/custom_button.dart';

class WhiteScreen extends StatefulWidget {
  const WhiteScreen({super.key});

  @override
  State<WhiteScreen> createState() => _WhiteScreenState();
}

class _WhiteScreenState extends State<WhiteScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogosScreen()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

class LogosScreen extends StatefulWidget {
  const LogosScreen({super.key});

  @override
  State<LogosScreen> createState() => _LogosScreenState();
}

class _LogosScreenState extends State<LogosScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FirstScreen()),
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('assets/images/logo.jpeg', height: 350, width: 350),
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  void _goToNextScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SecondScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          skipButton(),
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 150),
            child: Center(
              child: Image.asset(
                'assets/images/firstpic.jpg',
                height: 350,
                width: 350,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              'حافظ على صحتك بسهولة مع تطبيقنا الذكي الذي يجمع بين التذكير، المتابعة، والدعم الطبي في مكان واحد',
              style: GoogleFonts.tajawal(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 25, width: 150),
          custom_button(buttonText: 'التالي', width: 150),
        ],
      ),
    );
  }
}

class SecondScreen extends StatefulWidget {
  const SecondScreen({super.key});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          skipButton(),
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 150),
            child: Center(
              child: Image.asset(
                'assets/images/firstpic.jpg',
                height: 350,
                width: 350,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150, bottom: 150),
            child: Center(
              child: Image.asset(
                'assets/images/2ndpic.jpg',
                height: 350,
                width: 350,
              ),
            ),
          ),
          Text(
            'ذكاء اصطناعي يتابعك خطوة بخطوة - من تذكير الأدوية إلى تحليل القراءات وإعطاءك توصيات فورية.',
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,

              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25, width: 150),
          custom_button(buttonText: 'التالي', width: 150),
        ],
      ),
    );
  }
}

class ThirdScreen extends StatefulWidget {
  const ThirdScreen({super.key});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          skipButton(),
          Padding(
            padding: const EdgeInsets.only(top: 60, bottom: 150),
            child: Center(
              child: Image.asset(
                'assets/images/firstpic.jpg',
                height: 350,
                width: 350,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 150, bottom: 150),
            child: Center(
              child: Image.asset(
                'assets/images/3rdpic.jpg',
                height: 350,
                width: 350,
              ),
            ),
          ),
          Text(
            'تابع تقدمك، احصل على مكافآت، وتواصل مع مجتمع يدعمك في رحلتك الصحية.',
            style: GoogleFonts.tajawal(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 25, width: 150),
          custom_button(buttonText: 'التالي', width: 150),
        ],
      ),
    );
  }
}

Padding skipButton() {
  return Padding(
    padding: const EdgeInsets.only(top: 55),
    child: Row(
      children: [
        SizedBox(width: 320),
        GestureDetector(
          onTap: () {
            print('sucess');
          },
          child: Text(
            'تخطي',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    ),
  );
}
