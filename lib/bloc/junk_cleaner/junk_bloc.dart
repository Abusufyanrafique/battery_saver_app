import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    // UI mein package names cycle karo scan ke dauran
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _packageIndex = (_packageIndex + 1) % _packages.length;
      add(ScanTickEvent(_packages[_packageIndex]));
    });

    // Real device scan — returns JunkScanResult
    final JunkScanResult rawResult = await JunkScannerService.scanAll();

    _scanTimer?.cancel();

    // toUIList() se List<Map> milti hai — service wali method use karo
    final uiList = rawResult.toUIList();

    final items = uiList.map((e) {
      final mb = e['mb'] as double;
      return JunkItem(
        label: e['label'] as String,
        size: JunkScannerService.formatSize(mb),
        sizeInMB: mb,
        isChecked: mb > 0,
      );
    }).toList();

    debugPrint('ITEMS COUNT: ${items.length}');

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

    final checkedLabels = state.items
        .where((e) => e.isChecked)
        .map((e) => e.label)
        .toSet();

    // Labels exactly match karte hain toUIList() ke saath
    await Future.wait([
      if (checkedLabels.contains('Cache Junk'))    JunkScannerService.cleanCacheJunk(),
      if (checkedLabels.contains('Residual Junk')) JunkScannerService.cleanResidualJunk(),
      if (checkedLabels.contains('APK Files'))     JunkScannerService.cleanAPKJunk(),
      if (checkedLabels.contains('Tracked Files')) JunkScannerService.cleanTrackedFiles(),
      // 'Memory Used' skip — OS-controlled hai, clean nahi hoti
    ]);

    final cleanedItems = state.items.map((e) {
      if (e.isChecked) {
        return e.copyWith(isChecked: false, size: '0 MB', sizeInMB: 0);
      }
      return e;
    }).toList();

    emit(state.copyWith(
      phase: ScanPhase.cleaned,
      totalJunkDisplay: '0 MB',
      items: cleanedItems,
    ));
  }

  String _calcTotal(List<JunkItem> items) {
    // Memory Used ko total mein mat jodo — sirf actual junk
    const memoryLabel = 'Memory Used';
    final totalMB = items
        .where((e) => e.isChecked && e.label != memoryLabel)
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