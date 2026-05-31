import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:battery_saver_app/models/junk/junk_item.dart';
import 'package:battery_saver_app/services/junk_scanner_service.dart';
import 'junk_event.dart';
import 'junk_state.dart';

class JunkBloc extends Bloc<JunkEvent, JunkState> {
  static const List<String> _packages = [
    'com.whatsapp',
    'com.google.android.youtube',
    'com.instagram.android',
    'com.facebook.katana',
    'com.snapchat.android',
    'com.spotify.music',
    'com.netflix.mediaclient',
    'com.google.android.gm',
    'com.android.chrome',
    'com.tencent.mm',
    'com.twitter.android',
    'com.amazon.mShop.android.shopping',
    'com.google.android.apps.maps',
    'com.microsoft.teams',
    'com.zoom.videomeetings',
  ];

  Timer? _scanTimer;
  int _packageIndex = 0;

  JunkBloc() : super(JunkState.initial()) {
    on<StartScanEvent>(_onStartScan);
    on<ScanTickEvent>(_onScanTick);
    on<ToggleJunkItemEvent>(_onToggleItem);
    on<CleanJunkEvent>(_onClean);
  }

  Future<void> _onStartScan(
    StartScanEvent event,
    Emitter<JunkState> emit,
  ) async {
    _packageIndex = 0;

    emit(state.copyWith(
      items: [],
      phase: ScanPhase.scanning,
      currentPackage: _packages[0],
      totalJunkDisplay: '0 MB',
    ));

    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _packageIndex = (_packageIndex + 1) % _packages.length;
      add(ScanTickEvent(_packages[_packageIndex]));
    });

    // Real scan
    final rawItems = await JunkScannerService.scanAll();

    _scanTimer?.cancel();

    final items = rawItems.map((e) {
      final mb = e['mb'] as double;
      return JunkItem(
        label: e['label'] as String,
        size: JunkScannerService.formatSize(mb),
        sizeInMB: mb,
        isChecked: mb > 0,
      );
    }).toList();

    emit(state.copyWith(
      items: items,
      phase: ScanPhase.done,
      currentPackage: _packages.last,
      totalJunkDisplay: _calcTotal(items),
    ));
  }

  void _onScanTick(ScanTickEvent event, Emitter<JunkState> emit) {
    if (state.phase == ScanPhase.scanning) {
      emit(state.copyWith(currentPackage: event.packageName));
    }
  }

  void _onToggleItem(ToggleJunkItemEvent event, Emitter<JunkState> emit) {
    final updated = List<JunkItem>.from(state.items);
    updated[event.index] = updated[event.index].copyWith(
      isChecked: !updated[event.index].isChecked,
    );
    emit(state.copyWith(
      items: updated,
      totalJunkDisplay: _calcTotal(updated),
    ));
  }

  Future<void> _onClean(CleanJunkEvent event, Emitter<JunkState> emit) async {
    emit(state.copyWith(phase: ScanPhase.cleaning));

    try {
      final checkedLabels = state.items
          .where((e) => e.isChecked)
          .map((e) => e.label)
          .toList();

      if (checkedLabels.contains('Cache Junk')) {
        final dir = await getTemporaryDirectory();
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
          dir.createSync();
        }
      }

      if (checkedLabels.contains('APK Junk') && Platform.isAndroid) {
        final dirs = await getExternalCacheDirectories();
        dirs?.forEach((dir) {
          if (dir.existsSync()) dir.deleteSync(recursive: true);
        });
      }
    } catch (_) {}

    final cleanedItems = state.items
        .map((e) => e.copyWith(
              isChecked: false,
              size: '0 MB',
              sizeInMB: 0,
            ))
        .toList();

    emit(state.copyWith(
      phase: ScanPhase.cleaned,
      totalJunkDisplay: '0 MB',
      items: cleanedItems,
    ));
  }

  String _calcTotal(List<JunkItem> items) {
    final totalMB = items
        .where((e) => e.isChecked)
        .fold<double>(0, (sum, e) => sum + e.sizeInMB);
    if (totalMB >= 1024) {
      return '${(totalMB / 1024).toStringAsFixed(2)} GB';
    }
    return '${totalMB.toStringAsFixed(0)} MB';
  }

  @override
  Future<void> close() {
    _scanTimer?.cancel();
    return super.close();
  }
}