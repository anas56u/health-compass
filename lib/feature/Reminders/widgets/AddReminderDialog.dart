import 'package:flutter/material.dart';
import 'package:health_compass/feature/Reminders/data/model/reminders_model.dart';

class AddReminderDialog extends StatefulWidget {
  const AddReminderDialog({super.key});

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  List<int> _selectedDays = [];
  int _selectedIcon = Icons.notifications.codePoint;
  final now = DateTime.now();

  final Map<String, int> _icons = {
    'تنبيه': Icons.notifications.codePoint,
    'دواء': Icons.medication.codePoint,
    'قلب': Icons.favorite.codePoint,
    'شخص': Icons.person.codePoint,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFFEFEFEF),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اضافة تذكير',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              _buildTextField(_titleController, 'عنوان التذكير'),
              const SizedBox(height: 10),
              _buildTextField(
                _detailsController,
                'تفاصيل التذكير',
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              _buildTimePicker(),
              const SizedBox(height: 10),
              _buildDaysPicker(),
              const SizedBox(height: 10),
              _buildIconPicker(),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.isEmpty || _selectedDays.isEmpty)
                    return;

                  final String id = DateTime.now().millisecondsSinceEpoch
                      .toString();
                  final int notificationId = DateTime.now()
                      .millisecondsSinceEpoch
                      .remainder(100000);

                  final reminder = ReminderModel(
                    id: id,
                    notificationId: notificationId,
                    title: _titleController.text,
                    details: _detailsController.text,
                    time: DateTime(
                      now.year,
                      now.month,
                      now.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    ),
                    repeatDays: _selectedDays,
                    iconCode: _selectedIcon,
                  );

                  Navigator.pop(context, reminder); 
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137A74),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildTimePicker() {
    return Row(
      children: [
        const Text('الوقت:'),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: _selectedTime,
            );
            if (picked != null) {
              setState(() {
                _selectedTime = picked;
              });
            }
          },
          child: Text('${_selectedTime.format(context)}'),
        ),
      ],
    );
  }


Widget _buildDaysPicker() {
  final days = ['أحد', 'اثنين', 'ثلاثاء', 'أربعاء', 'خميس', 'جمعة', 'سبت'];
  return Wrap(
    spacing: 5,
    children: List.generate(days.length, (index) {
     
      final dayValue = index == 0 ? 7 : index; 
      
      final isSelected = _selectedDays.contains(dayValue);
      return ChoiceChip(
        label: Text(days[index]),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedDays.add(dayValue);
            } else {
              _selectedDays.remove(dayValue);
            }
          });
        },
      );
    }),
  );
}

  Widget _buildIconPicker() {
    return Wrap(
      spacing: 10,
      children: _icons.entries.map((e) {
        final selected = _selectedIcon == e.value;
        return ChoiceChip(
          label: Icon(IconData(e.value, fontFamily: 'MaterialIcons')),
          selected: selected,
          onSelected: (_) {
            setState(() {
              _selectedIcon = e.value;
            });
          },
        );
      }).toList(),
    );
  }
}
