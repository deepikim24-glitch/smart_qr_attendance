part of 'admin_bloc.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class AdminDashboardRequested extends AdminEvent {
  const AdminDashboardRequested();
}

class AdminDateFiltered extends AdminEvent {
  const AdminDateFiltered(this.date);
  final String? date;
  @override
  List<Object?> get props => [date];
}

class AdminQrGenerated extends AdminEvent {
  const AdminQrGenerated({this.expirySeconds = 120});
  final int expirySeconds;
  @override
  List<Object?> get props => [expirySeconds];
}

class AdminQrDeactivated extends AdminEvent {
  const AdminQrDeactivated();
}

class AdminTicked extends AdminEvent {
  const AdminTicked();
}
