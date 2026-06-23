part of 'app_manager_bloc.dart';

abstract class AppManagerEvent extends Equatable {
  const AppManagerEvent();
  @override
  List<Object?> get props => [];
}

class AppManagerLoadApps extends AppManagerEvent {
  const AppManagerLoadApps();
}

class AppManagerTabChanged extends AppManagerEvent {
  final int tabIndex;
  const AppManagerTabChanged(this.tabIndex);
  @override
  List<Object?> get props => [tabIndex];
}

class AppManagerToggleApp extends AppManagerEvent {
  final int index;
  const AppManagerToggleApp(this.index);
  @override
  List<Object?> get props => [index];
}

class AppManagerUninstallSelected extends AppManagerEvent {
  const AppManagerUninstallSelected();
}

//  NEW: Install APK event
class AppManagerInstallApk extends AppManagerEvent {
  final String apkPath;
  const AppManagerInstallApk(this.apkPath);
  @override
  List<Object?> get props => [apkPath];
}