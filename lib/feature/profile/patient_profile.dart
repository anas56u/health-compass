import 'package:flutter/material.dart';

class PatientProfilePage extends StatefulWidget {
  const PatientProfilePage({super.key});

  @override
  State<PatientProfilePage> createState() => _PatientProfilePageState();
}

class _PatientProfilePageState extends State<PatientProfilePage> {
  bool _isEnglish = false;
  bool _isPointsSystem = true;
  bool _isVoiceAssistant = true;
  bool _isNotifications = true;

  @override
  Widget build(BuildContext context) {
    const primaryTurquoise = Color(0xFF169086);
    const lightCardBg = Color(0xFFEDF1F6);
    const buttonBg = Color(0xFFE2E8F0);
    const mainText = Colors.black;

   
    return Theme(
      data: ThemeData(
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTurquoise,
          primary: primaryTurquoise,
          surface: lightCardBg,
          onSurface: mainText,
        ),
        scaffoldBackgroundColor: primaryTurquoise,
        
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            backgroundColor: buttonBg,
            foregroundColor: const Color(0xFF555555),
            side: const BorderSide(color: primaryTurquoise, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(fontSize: 14, fontFamily: 'Arial'),
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
        
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return primaryTurquoise;
            return Colors.white;
          }),
          trackColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) return primaryTurquoise.withOpacity(0.5);
            return Colors.grey.shade300;
          }),
        ),
        
        textTheme: const TextTheme(
          titleMedium: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          bodyMedium: TextStyle(fontSize: 14),
        ),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Stack(
            children: [
              _buildHeader(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(Theme.of(context)),
                        const SizedBox(height: 25),
                        Text('الاضافات:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        _buildActionButtons(),
                        const SizedBox(height: 25),
                        Text('اعدادات التطبيق:', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 10),
                        _buildSettingsSection(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeader() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white), 
                  onPressed: () {
                     if (Navigator.canPop(context)) {
                       Navigator.pop(context);
                     }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black), 
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('حليم المجالي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('Haleemmajale89@gmail.com', style: TextStyle(fontSize: 12)),
                    Text('ذكر/45', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildInfoColumn('نوع المرض:', 'سكري نوع 2', theme),
        _buildInfoColumn('سنة التشخيص:', '2019', theme),
      ],
    );
  }

  Widget _buildInfoColumn(String title, String value, ThemeData theme) {
    return Column(
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    final buttons = [
      'اضافة قراءة يدوية',
      'اضافة ربط مع العائلة',
      'اضافة او تعديل اوقات الصيام',
    ];

    return Column(
      children: buttons.map((text) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton(
          onPressed: () {},
          child: Text(text),
        ),
      )).toList(),
    );
  }

  Widget _buildSettingsSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildSwitchRow('اللغة الانجليزية', _isEnglish, (v) => setState(() => _isEnglish = v)),
              _buildSwitchRow('نظام النقاط', _isPointsSystem, (v) => setState(() => _isPointsSystem = v)),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            children: [
              _buildSwitchRow('المساعد الصوتي', _isVoiceAssistant, (v) => setState(() => _isVoiceAssistant = v)),
              _buildSwitchRow('الاشعارات', _isNotifications, (v) => setState(() => _isNotifications = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchRow(String text, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.grey))),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}