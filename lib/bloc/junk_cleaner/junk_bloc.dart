import 'dart:async';
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
     
    // Ticker — UI mein package names cycle karo scan ke dauran
    _scanTimer?.cancel();
    _scanTimer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      _packageIndex = (_packageIndex + 1) % _packages.length;
      add(ScanTickEvent(_packages[_packageIndex]));
    });

    // Real device scan
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
    //  DEBUG PRINTS YAHAN LAGAO
  
  print("ITEMS: ${items.length}");
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

    // Sirf checked items ko clean karo — label ke basis par
    final checkedLabels = state.items
        .where((e) => e.isChecked)
        .map((e) => e.label)
        .toSet();

    await Future.wait([
      if (checkedLabels.contains('Cache Junk'))    JunkScannerService.cleanCacheJunk(),
      if (checkedLabels.contains('Residual Junk')) JunkScannerService.cleanResidualJunk(),
      if (checkedLabels.contains('Ad Junk'))       JunkScannerService.cleanAdJunk(),
      if (checkedLabels.contains('APK Junk'))      JunkScannerService.cleanAPKJunk(),
      if (checkedLabels.contains('Memory Junk'))   JunkScannerService.cleanMemoryJunk(),
    ]);

    // Cleaned items ki size 0 kar do
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