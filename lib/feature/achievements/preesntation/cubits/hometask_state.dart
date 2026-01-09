import 'package:health_compass/feature/achievements/data/model/daily_tracking_model.dart';

abstract class HometaskState {}

class HomeInitial extends HometaskState {}

class HomeLoading extends HometaskState {}

class HomeError extends HometaskState {
  final String message;
  HomeError(this.message);
}

class HomeLoaded extends HometaskState {
  final DailyTrackingModel dailyData;
  HomeLoaded(this.dailyData);
}
