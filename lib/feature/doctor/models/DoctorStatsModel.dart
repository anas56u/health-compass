class DoctorStatsModel {
  final int totalPatients;
  final int stableCases;
  final int emergencyCases;

  DoctorStatsModel({
    required this.totalPatients,
    required this.stableCases,
    required this.emergencyCases,
  });
  
  // Best Practice: إضافة دالة لتحويل البيانات من JSON إذا كانت تأتي مباشرة من الـ Backend
  factory DoctorStatsModel.fromMap(Map<String, dynamic> json) {
    return DoctorStatsModel(
      totalPatients: json['totalPatients'] ?? 0,
      stableCases: json['stableCases'] ?? 0,
      emergencyCases: json['emergencyCases'] ?? 0,
    );
  }
}