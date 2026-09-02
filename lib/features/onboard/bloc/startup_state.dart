import 'package:equatable/equatable.dart';

// common cubit state which is used overall the app
// note: do not create any unwanted state while creating new cubit

abstract class MainState<T> {
  const MainState();
}

class StartupState extends Equatable implements MainState {
  const StartupState({this.statusCode});
  final int? statusCode;
  @override
  List<Object?> get props => [];
}

class StartupInitial extends StartupState {}

// use it for loading
class StartupLoading extends StartupState {}

// use it for loading

class StartupDummyLoading extends StartupState {}

// use it for error
class StartupError extends StartupState {
  final String message;
  const StartupError({required this.message, int? statusCode})
    : super(statusCode: statusCode);
  bool get isNoConnection => statusCode == 1000;
  @override
  List<Object?> get props => [message];
}

// use it , it response has no data or empty
class StartupNoData extends StartupState {
  const StartupNoData();
  @override
  List<Object?> get props => [];
}

// use it for success if response data is in List<T>

class StartupDataFetchSuccess<T> extends StartupState {
  final List<T> data;
  const StartupDataFetchSuccess({required this.data});

  @override
  List<T> get props => [...data];
}

// use it for success if you dont want any data in ui

class StartupSuccess extends StartupState {}

// use it for success if response data is any type generic
class StartupStateSuccess<T> extends StartupState {
  final T data;
  const StartupStateSuccess({required this.data});

  StartupStateSuccess<T> copyWith({T? data}) {
    return StartupStateSuccess<T>(data: data ?? this.data);
  }

  @override
  List<Object?> get props => [data];
}

class LocationAllowed extends StartupState {
  const LocationAllowed();
  @override
  List<Object?> get props => [];
}

class LocationPermissionDenied extends StartupState {
  const LocationPermissionDenied();
  @override
  List<Object?> get props => [];
}

class CountrySelected extends StartupState {
  const CountrySelected();
  @override
  List<Object?> get props => [];
}

class CountrySelectionRequired extends StartupState {
  const CountrySelectionRequired();
  @override
  List<Object?> get props => [];
}

class NotificationAllowed extends StartupState {
  const NotificationAllowed();
  @override
  List<Object?> get props => [];
}

class NotificationPermissionDenied extends StartupState {
  const NotificationPermissionDenied();
  @override
  List<Object?> get props => [];
}

class OnboardingRequired extends StartupState {
  const OnboardingRequired();
  @override
  List<Object?> get props => [];
}
