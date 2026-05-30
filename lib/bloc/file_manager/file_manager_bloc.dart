import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:battery_saver_app/data/repositories/file_manager_repository.dart';

// ══════════════════════════════════════════════════════════════════════════════
// EVENTS
// ══════════════════════════════════════════════════════════════════════════════

abstract class FileManagerEvent extends Equatable {
  const FileManagerEvent();
  @override List<Object?> get props => [];
}

class FileManagerLoadEvent    extends FileManagerEvent { const FileManagerLoadEvent(); }
class FileManagerRetryEvent   extends FileManagerEvent { const FileManagerRetryEvent(); }
class FileManagerRefreshEvent extends FileManagerEvent { const FileManagerRefreshEvent(); }

class FileManagerSearchEvent extends FileManagerEvent {
  final String query;
  const FileManagerSearchEvent(this.query);
  @override List<Object?> get props => [query];
}

// ══════════════════════════════════════════════════════════════════════════════
// STATES
// ══════════════════════════════════════════════════════════════════════════════

abstract class FileManagerState extends Equatable {
  const FileManagerState();
  @override List<Object?> get props => [];
}

class FileManagerLoadingState extends FileManagerState {
  const FileManagerLoadingState();
}

class FileManagerPermissionDeniedState extends FileManagerState {
  final String message;
  const FileManagerPermissionDeniedState({
    this.message = 'Storage permission required to scan files.',
  });
  @override List<Object?> get props => [message];
}

class FileManagerErrorState extends FileManagerState {
  final String message;
  const FileManagerErrorState(this.message);
  @override List<Object?> get props => [message];
}

class FileManagerLoadedState extends FileManagerState {
  final List<FileCategoryModel>  categories;
  final List<FileCategoryModel>  filteredCategories;
  final StorageDeviceModel       internalStorage;
  final bool                     isRefreshing;
  final String                   searchQuery;

  const FileManagerLoadedState({
    required this.categories,
    required this.filteredCategories,
    required this.internalStorage,
    this.isRefreshing = false,
    this.searchQuery  = '',
  });

  FileManagerLoadedState copyWith({
    List<FileCategoryModel>? categories,
    List<FileCategoryModel>? filteredCategories,
    StorageDeviceModel?      internalStorage,
    bool?                    isRefreshing,
    String?                  searchQuery,
  }) => FileManagerLoadedState(
    categories:         categories         ?? this.categories,
    filteredCategories: filteredCategories ?? this.filteredCategories,
    internalStorage:    internalStorage    ?? this.internalStorage,
    isRefreshing:       isRefreshing       ?? this.isRefreshing,
    searchQuery:        searchQuery        ?? this.searchQuery,
  );

  @override
  List<Object?> get props => [
    categories, filteredCategories, internalStorage, isRefreshing, searchQuery,
  ];
}

// ══════════════════════════════════════════════════════════════════════════════
// BLOC
// ══════════════════════════════════════════════════════════════════════════════

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

  Future<void> _onLoad(FileManagerLoadEvent e, Emitter<FileManagerState> emit) async {
    emit(const FileManagerLoadingState());
    await _loadData(emit);
  }

  Future<void> _onRetry(FileManagerRetryEvent e, Emitter<FileManagerState> emit) async {
    emit(const FileManagerLoadingState());
    await _loadData(emit);
  }

  Future<void> _onRefresh(FileManagerRefreshEvent e, Emitter<FileManagerState> emit) async {
    if (state is FileManagerLoadedState) {
      emit((state as FileManagerLoadedState).copyWith(isRefreshing: true));
    }
    await _loadData(emit);
  }

  void _onSearch(FileManagerSearchEvent e, Emitter<FileManagerState> emit) {
    if (state is! FileManagerLoadedState) return;
    final cur   = state as FileManagerLoadedState;
    final query = e.query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? cur.categories
        : cur.categories.where((c) => c.name.toLowerCase().contains(query)).toList();
    emit(cur.copyWith(filteredCategories: filtered, searchQuery: e.query));
  }

  Future<void> _loadData(Emitter<FileManagerState> emit) async {
    try {
      final hasPermission = await _repo.requestStoragePermission();
      if (!hasPermission) {
        emit(const FileManagerPermissionDeniedState());
        return;
      }

      // Parallel fetch — faster
      final results = await Future.wait([
        _repo.fetchFileCategories(),
        _repo.fetchInternalStorage(),
      ]);

      final categories = results[0] as List<FileCategoryModel>;
      final storage    = results[1] as StorageDeviceModel;

      emit(FileManagerLoadedState(
        categories:         categories,
        filteredCategories: categories,
        internalStorage:    storage,
      ));
    } catch (e) {
      emit(FileManagerErrorState('Error: ${e.toString()}'));
    }
  }
}