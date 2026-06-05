part of 'app_manager_bloc.dart';

enum AppManagerStatus { initial, loading, success, failure }

class RealAppModel {
  final String name;
  final String packageName;
  final double sizeMB;
  final Uint8List? icon;
  final String? versionName;
  bool isSelected;

  RealAppModel({
    required this.name,
    required this.packageName,
    required this.sizeMB,
    this.icon,
    this.versionName,
    this.isSelected = false,
  });

  String get formattedSize {
    if (sizeMB >= 1024) return '${(sizeMB / 1024).toStringAsFixed(2)} GB';
    return '${sizeMB.toStringAsFixed(0)} MB';
  }

  RealAppModel copyWith({bool? isSelected, double? sizeMB}) => RealAppModel(
        name: name,
        packageName: packageName,
        sizeMB: sizeMB ?? this.sizeMB,
        icon: icon,
        versionName: versionName,
        isSelected: isSelected ?? this.isSelected,
      );
}

class ApkFileModel {
  final String name;
  final String path;
  final double sizeMB;
  final String version;
  bool isSelected;

  ApkFileModel({
    required this.name,
    required this.path,
    required this.sizeMB,
    this.version = '1.0.0',
    this.isSelected = false,
  });

  String get formattedSize {
    if (sizeMB >= 1024) return '${(sizeMB / 1024).toStringAsFixed(2)} GB';
    return '${sizeMB.toStringAsFixed(1)} MB';
  }
}

class AppManagerState extends Equatable {
  final AppManagerStatus status;
  final List<RealAppModel> installedApps;
  final List<ApkFileModel> apkFiles;
  final int selectedTabIndex;
  final String? errorMessage;

  const AppManagerState({
    this.status = AppManagerStatus.initial,
    this.installedApps = const [],
    this.apkFiles = const [],
    this.selectedTabIndex = 0,
    this.errorMessage,
  });

  bool get isApkMode => selectedTabIndex == 1;

  double get totalSizeGB {
    if (isApkMode) {
      final total = apkFiles.fold<double>(0, (s, a) => s + a.sizeMB);
      return total / 1024;
    }
    final total = installedApps.fold<double>(0, (s, a) => s + a.sizeMB);
    debugPrint('=== Total MB: $total');
    return total / 1024;
  }

  int get totalCount =>
      isApkMode ? apkFiles.length : installedApps.length;

  List<RealAppModel> get selectedApps =>
      installedApps.where((a) => a.isSelected).toList();

  AppManagerState copyWith({
    AppManagerStatus? status,
    List<RealAppModel>? installedApps,
    List<ApkFileModel>? apkFiles,
    int? selectedTabIndex,
    String? errorMessage,
  }) =>
      AppManagerState(
        status: status ?? this.status,
        installedApps: installedApps ?? this.installedApps,
        apkFiles: apkFiles ?? this.apkFiles,
        selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
        errorMessage: errorMessage,
      );

  @override
  List<Object?> get props => [
        status,
        installedApps,
        apkFiles,
        selectedTabIndex,
        errorMessage,
      ];
}