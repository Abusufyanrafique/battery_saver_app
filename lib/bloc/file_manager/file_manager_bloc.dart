import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/data/repositories/file_manager_repository.dart';

// ─────────────────────────────────────────────
// EVENTS
// ─────────────────────────────────────────────

abstract class FileManagerEvent extends Equatable {
  const FileManagerEvent();

  @override
  List<Object?> get props => [];
}

class FileManagerLoadEvent extends FileManagerEvent {
  const FileManagerLoadEvent();
}

class FileManagerRetryEvent extends FileManagerEvent {
  const FileManagerRetryEvent();
}

class FileManagerRefreshEvent extends FileManagerEvent {
  const FileManagerRefreshEvent();
}

class FileManagerSearchEvent extends FileManagerEvent {
  final String query;
  const FileManagerSearchEvent(this.query);

  @override
  List<Object?> get props => [query];
}

// ─────────────────────────────────────────────
// STATES
// ─────────────────────────────────────────────

abstract class FileManagerState extends Equatable {
  const FileManagerState();

  @override
  List<Object?> get props => [];
}

class FileManagerLoadingState extends FileManagerState {
  const FileManagerLoadingState();
}

class FileManagerPermissionDeniedState extends FileManagerState {
  final String message;
  const FileManagerPermissionDeniedState(this.message);

  @override
  List<Object?> get props => [message];
}

class FileManagerErrorState extends FileManagerState {
  final String message;
  const FileManagerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}

class FileManagerLoadedState extends FileManagerState {
  final List<FileCategoryModel> categories;
  final List<FileCategoryModel> filteredCategories;
  final StorageDeviceModel internalStorage;
  final StorageDeviceModel? sdCardStorage;
  final bool isRefreshing;
  final String searchQuery;

  const FileManagerLoadedState({
    required this.categories,
    required this.filteredCategories,
    required this.internalStorage,
    this.sdCardStorage,
    this.isRefreshing = false,
    this.searchQuery = '',
  });

  FileManagerLoadedState copyWith({
    List<FileCategoryModel>? categories,
    List<FileCategoryModel>? filteredCategories,
    StorageDeviceModel? internalStorage,
    StorageDeviceModel? sdCardStorage,
    bool clearSdCard = false,
    bool? isRefreshing,
    String? searchQuery,
  }) {
    return FileManagerLoadedState(
      categories:         categories         ?? this.categories,
      filteredCategories: filteredCategories ?? this.filteredCategories,
      internalStorage:    internalStorage    ?? this.internalStorage,
      sdCardStorage:      clearSdCard ? null : (sdCardStorage ?? this.sdCardStorage),
      isRefreshing:       isRefreshing       ?? this.isRefreshing,
      searchQuery:        searchQuery        ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        categories,
        filteredCategories,
        internalStorage,
        sdCardStorage,
        isRefreshing,
        searchQuery,
      ];
}

// ─────────────────────────────────────────────
// BLOC
// ─────────────────────────────────────────────

class FileManagerBloc extends Bloc<FileManagerEvent, FileManagerState> {
  final FileManagerRepository _repo;

  FileManagerBloc({FileManagerRepository? repository})
      : _repo = repository ?? FileManagerRepository(),
        super(const FileManagerLoadingState()) {
    on<FileManagerLoadEvent>(_onLoad);
    on<FileManagerRetryEvent>(_onRetry);
    on<FileManagerRefreshEvent>(_onRefresh);
    on<FileManagerSearchEvent>(_onSearch);
  }

  Future<void> _onLoad(
    FileManagerLoadEvent event,
    Emitter<FileManagerState> emit,
  ) async {
    print("⏳ LOAD EVENT — showing loading for 2.5s");

    // FIX: 2.5 second loading screen dikhao — user ko pata chale app kaam kar rahi hai
    await Future.delayed(const Duration(milliseconds: 2500));

    await _loadData(emit, forceRefresh: false);
  }

  Future<void> _onRetry(
    FileManagerRetryEvent event,
    Emitter<FileManagerState> emit,
  ) async {
    emit(const FileManagerLoadingState());
    // Retry pe bhi thoda delay — consistent feel
    await Future.delayed(const Duration(milliseconds: 2500));
    await _loadData(emit, forceRefresh: true);
  }

  Future<void> _onRefresh(
    FileManagerRefreshEvent event,
    Emitter<FileManagerState> emit,
  ) async {
    if (state is FileManagerLoadedState) {
      emit((state as FileManagerLoadedState).copyWith(isRefreshing: true));
    }
    // Pull-to-refresh pe delay nahi — woh already spinner dikhata hai
    await _loadData(emit, forceRefresh: true);
  }

  void _onSearch(
    FileManagerSearchEvent event,
    Emitter<FileManagerState> emit,
  ) {
    if (state is! FileManagerLoadedState) return;
    final current = state as FileManagerLoadedState;
    final q = event.query.toLowerCase().trim();
    final filtered = q.isEmpty
        ? current.categories
        : current.categories
            .where((e) => e.name.toLowerCase().contains(q))
            .toList();
    emit(current.copyWith(
      filteredCategories: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _loadData(
    Emitter<FileManagerState> emit, {
    required bool forceRefresh,
  }) async {
    try {
      print("🚀 LOAD DATA START");

      final hasPermission = await _repo
          .requestStoragePermission()
          .timeout(const Duration(seconds: 5), onTimeout: () {
        print("⛔ Permission timeout");
        return false;
      });

      print("🔐 PERMISSION: $hasPermission");

      if (!hasPermission) {
        emit(const FileManagerPermissionDeniedState(
          "Storage permission required",
        ));
        return;
      }

      final results = await Future.wait([
        _repo.fetchInternalStorage(),
        _repo.fetchSdCardStorage(),
      ]);

      final storage = results[0] as StorageDeviceModel;
      final sdCard  = results[1] as StorageDeviceModel?;

      print("📦 STORAGE: internal=${storage.totalLabel}  sdCard=${sdCard?.totalLabel ?? 'null'}");

      emit(FileManagerLoadedState(
        categories:         const [],
        filteredCategories: const [],
        internalStorage:    storage,
        sdCardStorage:      sdCard,
        isRefreshing:       true,
      ));

      final categories = await _repo
          .fetchFileCategories(forceRefresh: forceRefresh)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              print("⛔ Scan timeout — returning empty");
              return [];
            },
          );

      print("📁 CATEGORIES: ${categories.length}");

      emit(FileManagerLoadedState(
        categories:         categories,
        filteredCategories: categories,
        internalStorage:    storage,
        sdCardStorage:      sdCard,
        isRefreshing:       false,
      ));
    } catch (e) {
      print("❌ ERROR: $e");
      emit(FileManagerErrorState(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _repo.cancelScan();
    return super.close();
  }
}