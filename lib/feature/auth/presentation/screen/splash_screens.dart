import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_compass/core/widgets/custom_button.dart';
import 'package:health_compass/feature/auth/presentation/screen/login_page.dart';

// --- شاشة البداية (Splash Screen) ---
class SplashScreens extends StatefulWidget {
  const SplashScreens({super.key});

  @override
  State<SplashScreens> createState() => _SplashScreensState();
}

class _SplashScreensState extends State<SplashScreens> {
  @override
  void initState() {
    super.initState();
    // الانتقال بعد ثانية واحدة
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LogosScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(backgroundColor: Colors.white);
  }
}

// --- شاشة اللوجو (Logos Screen) ---
class LogosScreen extends StatefulWidget {
  const LogosScreen({super.key});

  @override
  State<LogosScreen> createState() => _LogosScreenState();
}

class _LogosScreenState extends State<LogosScreen> {
  @override
  void initState() {
    super.initState();
    // الانتقال لصفحات الترحيب بعد ثانيتين
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingPageView()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeInImage(
          // إضافة تأثير ظهور ناعم للوجو
          placeholder: const AssetImage(
            'assets/images/logo.jpeg',
          ), // يمكن وضع صورة مؤقتة هنا
          image: const AssetImage('assets/images/logo.jpeg'),
          height: 350,
          width: 350,
          fadeInDuration: const Duration(milliseconds: 500),
        ),
      ),
    );
  }
}

// --- المودل الخاص ببيانات كل صفحة ---
class OnboardingItem {
  final String image;
  final String title;
  final String description;

  OnboardingItem({
    required this.image,
    required this.title,
    required this.description,
  });
}

// --- المتحكم الرئيسي في صفحات الترحيب (PageView) ---
class OnboardingPageView extends StatefulWidget {
  const OnboardingPageView({super.key});

  @override
  State<OnboardingPageView> createState() => _OnboardingPageViewState();
}

class _OnboardingPageViewState extends State<OnboardingPageView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // قائمة البيانات (النصوص والصور)
  final List<OnboardingItem> _pages = [
    OnboardingItem(
      image: 'assets/images/firstpic.jpg',
      title: 'صحتك في مكان واحد',
      description:
          'حافظ على صحتك بسهولة مع تطبيقنا الذكي الذي يجمع بين التذكير، المتابعة، والدعم الطبي.',
    ),
    OnboardingItem(
      image: 'assets/images/2ndpic.jpg',
      title: 'ذكاء اصطناعي يرافقك',
      description:
          'متابعة خطوة بخطوة - من تذكير الأدوية إلى تحليل القراءات وإعطائك توصيات فورية.',
    ),
    OnboardingItem(
      image: 'assets/images/3rdpic.jpg',
      title: 'مجتمع داعم ومكافآت',
      description:
          'تابع تقدمك، احصل على مكافآت، وتواصل مع مجتمع يدعمك في رحلتك الصحية.',
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // زر التخطي يظهر دائماً في الأعلى اليسار (أو اليمين حسب اللغة)
          TextButton(
            onPressed: _navigateToLogin,
            child: Text(
              'تخطي',
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // منطقة العرض المتغيرة (PageView)
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(item: _pages[index]);
                },
              ),
            ),

            // منطقة التحكم السفلية (مؤشر الصفحات + الزر)
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // مؤشر الصفحات (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => buildDot(index),
                    ),
                  ),

                  // زر التالي / ابدأ
                  GestureDetector(
                    onTap: _nextPage,
                    child: custom_button(
                      buttonText: _currentPage == _pages.length - 1
                          ? 'ابدأ الآن'
                          : 'التالي',
                      width: 200, // عرض مناسب
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ودجت بناء النقطة (Dot Indicator)
  Widget buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8, // النقطة الحالية أطول
      decoration: BoxDecoration(
        color: _currentPage == index
            ? const Color(0xFF41BFAA)
            : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// --- تصميم محتوى الصفحة الواحدة ---
class OnboardingContent extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingContent({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الصورة
          Expanded(
            child: Image.asset(
              item.image,
              fit: BoxFit.contain, // يضمن ظهور الصورة كاملة
            ),
          ),
          const SizedBox(height: 20),

          // العنوان (اختياري، قمت بإضافته لتحسين التصميم)
          // Text(
          //   item.title,
          //   textAlign: TextAlign.center,
          //   style: GoogleFonts.tajawal(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: const Color(0xFF41BFAA),
          //   ),
          // ),
          // const SizedBox(height: 10),

          // الوصف
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.w600, // وزن خط مريح للقراءة
              color: Colors.black87,
              height: 1.5, // مسافة بين الأسطر للقراءة المريحة
            ),
          ),
        ],
      ),
    );
  }
}
