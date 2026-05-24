// lib/features/properties/dashboard/presentation/cubit/dashboard_state.dart
import 'package:equatable/equatable.dart';
import 'package:app_properties/features/properties/dashboard/domain/entities/dashboard_stats.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  const DashboardLoaded(this.stats);
  @override
  List<Object?> get props => [stats];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}
