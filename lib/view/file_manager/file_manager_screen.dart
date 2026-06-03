import 'package:battery_saver_app/bloc/file_manager/file_manager_bloc.dart';
import 'package:battery_saver_app/configs/colors/app_colors.dart';
import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/data/repositories/file_manager_repository.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ──────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ──────────────────────────────────────────────────────────────────────────────

class FileManagerPage extends StatelessWidget {
  const FileManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    print("📱 FILE MANAGER PAGE OPENED");

    return BlocProvider(
      create: (_) {
        print("📦 BLOC CREATED");

        final bloc = FileManagerBloc(
          repository: FileManagerRepository(),
        );

        bloc.stream.listen((state) {
          print("🔄 STATE: $state");
        });

        bloc.add(const FileManagerLoadEvent());

        return bloc;
      },
      child: const FileManagerScreen(),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// MAIN SCREEN
// ──────────────────────────────────────────────────────────────────────────────

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim  = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.allscreenBackgroundColor,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: BlocConsumer<FileManagerBloc, FileManagerState>(
              listener: (_, state) {
                // FIX: Sirf jab scan complete ho tab animation chalao
                if (state is FileManagerLoadedState && !state.isRefreshing) {
                  _animController.forward(from: 0);
                }
              },
              builder: (ctx, state) {
                // FIX: FileManagerLoadingState sirf permission check tak — storage
                // resolve hone ke baad hum LoadedState emit karte hain isRefreshing:true ke saath
                if (state is FileManagerLoadingState)          return _loadingView();
                if (state is FileManagerPermissionDeniedState) return _permissionView(ctx, state.message);
                if (state is FileManagerErrorState)            return _errorView(ctx, state.message);
                if (state is FileManagerLoadedState)           return _loadedView(ctx, state);
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── BACKGROUND ─────────────────────────────────────────────────────────────

  Widget _background() => Positioned.fill(
    child: CustomPaint(painter: _BgPainter()),
  );

  // ── HEADER ─────────────────────────────────────────────────────────────────

  Widget _header({bool showMore = true}) => Row(
    children: [
      _GlassBtn(
        icon: Icons.arrow_back_ios_new,
        onTap: () => Navigator.of(context).maybePop(),
      ),
      Expanded(
        child: Center(
          child: Text(
            'File Manager',
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: getFont(24),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      showMore
          ? _GlassBtn(icon: Icons.more_vert, onTap: () {})
          : const SizedBox(width: 40),
    ],
  );

  // ── SEARCH ─────────────────────────────────────────────────────────────────

  Widget _searchBar(BuildContext context, FileManagerLoadedState state) =>
      Container(
        height: getHeight(40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF232C6D), Color(0xFF13173A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4103AC), width: 1),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFFD9D9D9)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (q) => context
                    .read<FileManagerBloc>()
                    .add(FileManagerSearchEvent(q)),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search files...',
                  hintStyle: TextStyle(color: Color(0xFFD9D9D9)),
                ),
              ),
            ),
            if (state.searchQuery.isNotEmpty)
              Text(
                '${state.filteredCategories.length}',
                style: const TextStyle(color: Color(0xFF6C63FF), fontSize: 13),
              ),
          ],
        ),
      );

  // ── LOADING ────────────────────────────────────────────────────────────────
  // Sirf permission check aur storage resolve hone tak dikhta hai — bahut short

  Widget _loadingView() => Column(
    children: [
      Padding(padding: const EdgeInsets.all(24), child: _header(showMore: false)),
      const Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // ── PERMISSION ─────────────────────────────────────────────────────────────

  Widget _permissionView(BuildContext context, String message) => Column(
    children: [
      Padding(padding: const EdgeInsets.all(24), child: _header(showMore: false)),
      Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.folder_off, color: Colors.white38, size: 64),
                const SizedBox(height: 16),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15)),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<FileManagerBloc>()
                      .add(const FileManagerRetryEvent()),
                  icon: const Icon(Icons.security),
                  label: const Text('Grant Permission'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  // ── ERROR ──────────────────────────────────────────────────────────────────

  Widget _errorView(BuildContext context, String message) => Column(
    children: [
      Padding(padding: const EdgeInsets.all(24), child: _header(showMore: false)),
      Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 56),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => context
                    .read<FileManagerBloc>()
                    .add(const FileManagerRetryEvent()),
                child: const Text('Retry',
                    style: TextStyle(color: Color(0xFF6C63FF))),
              ),
            ],
          ),
        ),
      ),
    ],
  );

  // ── LOADED ─────────────────────────────────────────────────────────────────

  Widget _loadedView(BuildContext context, FileManagerLoadedState state) =>
      FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: RefreshIndicator(
            color: const Color(0xFF6C63FF),
            backgroundColor: const Color(0xFF13173A),
            onRefresh: () async {
              context
                  .read<FileManagerBloc>()
                  .add(const FileManagerRefreshEvent());
              await Future.doWhile(() async {
                await Future.delayed(const Duration(milliseconds: 200));
                if (!mounted) return false;
                final s = context.read<FileManagerBloc>().state;
                return s is FileManagerLoadedState && s.isRefreshing;
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  // FIX: isRefreshing:true pe thin progress bar — poori screen loading nahi
                  if (state.isRefreshing) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        color: Color(0xFF6C63FF),
                        backgroundColor: Color(0xFF232C6D),
                        minHeight: 3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _searchBar(context, state),
                  const SizedBox(height: 24),
                  _categoryGrid(state),
                  const SizedBox(height: 24),
                  _StorageCard(storage: state.internalStorage),
                if (state.sdCardStorage != null) ...[
  const SizedBox(height: 12),
  _StorageCard(storage: state.sdCardStorage!),
],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      );

  // ── CATEGORY GRID ──────────────────────────────────────────────────────────

  Widget _categoryGrid(FileManagerLoadedState state) {
    // FIX: Scan chal rahi hai aur abhi koi data nahi — spinner dikhao
    if (state.isRefreshing && state.categories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF6C63FF)),
              SizedBox(height: 12),
              Text(
                'Scanning files...',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'This may take a few seconds',
                style: TextStyle(color: Colors.white30, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    // Search se koi result nahi mila
    if (state.filteredCategories.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No categories found',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: state.filteredCategories
          .map((c) => SizedBox(
                width: (MediaQuery.of(context).size.width - 72) / 3,
                child: _CategoryCard(category: c),
              ))
          .toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CATEGORY CARD
// ══════════════════════════════════════════════════════════════════════════════

class _CategoryCard extends StatelessWidget {
  final FileCategoryModel category;
  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: getHeight(126),
      width: getWidth(120),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232C6D), Color(0xFF1B2153), Color(0xFF13173A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4103AC), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            category.imagePath,
            width: getWidth(40),
            height: getHeight(40),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.folder, color: Colors.white54, size: 36),
          ),
          SizedBox(height: getHeight(8)),
          Text(
            category.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(16),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            category.size,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(13),
              color: const Color(0xFFD9D9D9),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '${category.fileCount} files',
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: getFont(11),
              color: const Color(0xFF9E9E9E),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// STORAGE CARD
// ══════════════════════════════════════════════════════════════════════════════

class _StorageCard extends StatelessWidget {
  final StorageDeviceModel storage;
  const _StorageCard({required this.storage});

  Color get _barColor {
    if (storage.percentage > 0.9) return Colors.redAccent;
    return const Color(0xFF1F8EFF);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF232C6D), Color(0xFF1B2153), Color(0xFF13173A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4103AC)),
      ),
      child: Row(
        children: [
          Icon(
            storage.isSdCard ? Icons.sd_card : Icons.storage,
            color: Colors.white70,
            size: 32,
          ),
          SizedBox(width: getWidth(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      storage.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: getFont(16),
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: storage.usedLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: getFont(18),
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        TextSpan(
                          text: ' / ',
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: getFont(14), color: Colors.white70),
                        ),
                        TextSpan(
                          text: storage.totalLabel,
                          style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: getFont(13), color: Colors.white54),
                        ),
                      ]),
                    ),
                  ],
                ),
                SizedBox(height: getHeight(10)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: storage.percentage),
                  duration: const Duration(milliseconds: 1200),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LinearProgressIndicator(
                      minHeight: getHeight(6),
                      value: v,
                      color: _barColor,
                      backgroundColor: const Color(0xFF232C6D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// GLASS BUTTON
// ══════════════════════════════════════════════════════════════════════════════

class _GlassBtn extends StatelessWidget {
  final IconData     icon;
  final VoidCallback onTap;
  const _GlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width:  getWidth(40),
          height: getHeight(40),
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.white),
        ),
      );
}

// ══════════════════════════════════════════════════════════════════════════════
// BACKGROUND PAINTER
// ══════════════════════════════════════════════════════════════════════════════

class _BgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.blueAccent.withOpacity(0.2), Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter _) => false;
}