import 'package:battery_saver_app/configs/text_style/text_style.dart';
import 'package:battery_saver_app/utils/SizeConfig.dart';
import 'package:flutter/material.dart';

// ─── DATA MODELS ─────────────────────────────────────────────

class FileCategory {
  final String name;
  final String size;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  const FileCategory({
    required this.name,
    required this.size,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });
}

class StorageDevice {
  final String name;
  final double used;
  final double total;
  final String usedLabel;
  final String totalLabel;
  final IconData icon;
  final Color progressColor;

  const StorageDevice({
    required this.name,
    required this.used,
    required this.total,
    required this.usedLabel,
    required this.totalLabel,
    required this.icon,
    required this.progressColor,
  });
}

// ─── MAIN SCREEN ─────────────────────────────────────────────

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final TextEditingController _searchController = TextEditingController();

  final List<FileCategory> _categories = const [
    FileCategory(
      name: 'Images',
      size: '1.28 GB',
      icon: Icons.image_rounded,
      iconColor: Color(0xFFFF6B6B),
      iconBg: Color(0xFF2A1A1A),
    ),
    FileCategory(
      name: 'Videos',
      size: '2.35 GB',
      icon: Icons.play_circle_fill_rounded,
      iconColor: Color(0xFF4ECDC4),
      iconBg: Color(0xFF0F2A29),
    ),
    FileCategory(
      name: 'Audio',
      size: '320 MB',
      icon: Icons.music_note_rounded,
      iconColor: Color(0xFFFF6B9D),
      iconBg: Color(0xFF2A0F1E),
    ),
    FileCategory(
      name: 'Documents',
      size: '245 MB',
      icon: Icons.description_rounded,
      iconColor: Color(0xFF74B9FF),
      iconBg: Color(0xFF0F1E2A),
    ),
    FileCategory(
      name: 'Downloads',
      size: '512 MB',
      icon: Icons.download_rounded,
      iconColor: Color(0xFF55EFC4),
      iconBg: Color(0xFF0A2A1E),
    ),
    FileCategory(
      name: 'APKs',
      size: '156 MB',
      icon: Icons.android_rounded,
      iconColor: Color(0xFFA29BFE),
      iconBg: Color(0xFF1A0F2A),
    ),
  ];

  final List<StorageDevice> _storages = const [
    StorageDevice(
      name: 'Internal Storage',
      used: 91.2,
      total: 128,
      usedLabel: '91.2 GB',
      totalLabel: '128 GB',
      icon: Icons.smartphone_rounded,
      progressColor: Color(0xFF6C63FF),
    ),
    StorageDevice(
      name: 'SD Card',
      used: 12.7,
      total: 32,
      usedLabel: '12.7 GB',
      totalLabel: '32 GB',
      icon: Icons.sd_card_rounded,
      progressColor: Color(0xFF00B4D8),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ─── UI ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B3E),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),

                      _buildSearchBar(),
                      const SizedBox(height: 24),

                      _buildCategoryGrid(),
                      const SizedBox(height: 24),

                      _buildStorageCards(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BACKGROUND ─────────────────────────────────────────────

  Widget _buildBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _BackgroundPainter(),
      ),
    );
  }

  // ─── HEADER ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        _GlassIconButton(icon: Icons.arrow_back_ios_new, onTap: () {}),
        const Expanded(
          child: Center(
            child: Text(
              'File Manager',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        _GlassIconButton(icon: Icons.more_vert, onTap: () {}),
      ],
    );
  }

  // ─── SEARCH ─────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: getHeight(40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232C6D), Color(0xFF13173A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
        border:Border.all(
          color:Color(0xFF4103AC),
          width: 1,
        )
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.white54),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search files...',
                hintStyle: TextStyle(color: Colors.white38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CATEGORY GRID ─────────────────────────────────────────────

  Widget _buildCategoryGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _categories.map((c) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 72) / 3,
          child: _CategoryCard(category: c, delay: 0),
        );
      }).toList(),
    );
  }

  // ─── STORAGE ─────────────────────────────────────────────

  Widget _buildStorageCards() {
    return Column(
      children: _storages
          .map(
            (s) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _StorageCard(storage: s),
            ),
          )
          .toList(),
    );
  }
}

// ─── CATEGORY CARD ─────────────────────────────────────────────

class _CategoryCard extends StatefulWidget {
  final FileCategory category;
  final int delay;

  const _CategoryCard({required this.category, required this.delay});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232C6D), Color(0xFF13173A)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF4103AC),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.category.icon,
              color: widget.category.iconColor, size: 28),
          const SizedBox(height: 8),
          Text(widget.category.name,
                 style: AppTextStyles.bodyMedium.copyWith(
                fontSize:getFont(16),
                color:Color(0xFFFFFFFF),
                fontWeight: FontWeight.w600,
              )
              
              ),
          Text(widget.category.size,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: getFont(16),
                color: Color(0xFFFFFFFF),

              )),
        ],
      ),
    );
  }
}

// ─── STORAGE CARD ─────────────────────────────────────────────

class _StorageCard extends StatelessWidget {
  final StorageDevice storage;

  const _StorageCard({required this.storage});

  @override
  Widget build(BuildContext context) {
    final pct = storage.used / storage.total;

    return Container(
      padding:  EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF232C6D), Color(0xFF13173A)],
        ),
        borderRadius: BorderRadius.circular(12),
         border:Border.all(
          color:Color(0xFF4103AC)
        )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         Row(
          
          children: [
           Text(storage.name,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize:getFont(16)
              )
              ),
              SizedBox(width: getWidth(80),),
               Text("91.2 GB / 128 GB",
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize:getFont(16)
              )
              ),
         ],),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: pct,
            color: storage.progressColor,
            backgroundColor: Colors.white12,
          ),
        ],
      ),
    );
  }
}

// ─── GLASS BUTTON ─────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: getWidth(40),
        height: getHeight(40),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

// ─── BACKGROUND ─────────────────────────────────────────────

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.shader = RadialGradient(
      colors: [Colors.blueAccent.withOpacity(0.2), Colors.transparent],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}