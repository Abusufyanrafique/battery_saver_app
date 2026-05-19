// import 'package:flutter/material.dart';

// // ─────────────────────────────────────────────
// // DATA MODEL
// // ─────────────────────────────────────────────

// class SocialStatItem {
//   final String label;
//   final int count;
//   final Widget icon; // SVG ya custom widget pass karo
//   final bool isChecked;

//   const SocialStatItem({
//     required this.label,
//     required this.count,
//     required this.icon,
//     this.isChecked = true,
//   });
// }

// // ─────────────────────────────────────────────
// // MAIN WIDGET
// // ─────────────────────────────────────────────

// class SocialStatsWidget extends StatelessWidget {
//   final List<SocialStatItem> items;
//   final Color backgroundColor;
//   final Color cardColor;
//   final Color textColor;
//   final Color countColor;
//   final Color checkColor;
//   final Color checkBgColor;
//   final Color dividerColor;
//   final double borderRadius;
//   final EdgeInsetsGeometry padding;

//   const SocialStatsWidget({
//     super.key,
//     required this.items,
//     this.backgroundColor = const Color(0xFF0D1B4B),
//     this.cardColor = const Color(0xFF112266),
//     this.textColor = Colors.white,
//     this.countColor = Colors.white,
//     this.checkColor = Colors.white,
//     this.checkBgColor = const Color(0xFF1A3A8A),
//     this.dividerColor = const Color(0xFF1E2E6A),
//     this.borderRadius = 20,
//     this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: cardColor,
//         borderRadius: BorderRadius.circular(borderRadius),
//         border: Border.all(
//           color: dividerColor,
//           width: 1.2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.35),
//             blurRadius: 24,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(borderRadius),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(items.length, (index) {
//             final isLast = index == items.length - 1;
//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _SocialStatRow(
//                   item: items[index],
//                   padding: padding,
//                   textColor: textColor,
//                   countColor: countColor,
//                   checkColor: checkColor,
//                   checkBgColor: checkBgColor,
//                 ),
//                 if (!isLast)
//                   Divider(
//                     height: 1,
//                     thickness: 1,
//                     color: dividerColor,
//                     indent: 16,
//                     endIndent: 16,
//                   ),
//               ],
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // SINGLE ROW
// // ─────────────────────────────────────────────

// class _SocialStatRow extends StatelessWidget {
//   final SocialStatItem item;
//   final EdgeInsetsGeometry padding;
//   final Color textColor;
//   final Color countColor;
//   final Color checkColor;
//   final Color checkBgColor;

//   const _SocialStatRow({
//     required this.item,
//     required this.padding,
//     required this.textColor,
//     required this.countColor,
//     required this.checkColor,
//     required this.checkBgColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       child: Row(
//         children: [
//           // App Icon
//           SizedBox(
//             width: 40,
//             height: 40,
//             child: item.icon,
//           ),
//           const SizedBox(width: 14),

//           // Label
//           Expanded(
//             child: Text(
//               item.label,
//               style: TextStyle(
//                 color: textColor,
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//                 letterSpacing: 0.2,
//               ),
//             ),
//           ),

//           // Count
//           Text(
//             '${item.count}',
//             style: TextStyle(
//               color: countColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(width: 12),

//           // Check Badge
//           if (item.isChecked)
//             Container(
//               width: 28,
//               height: 28,
//               decoration: BoxDecoration(
//                 color: checkBgColor,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(
//                 Icons.check,
//                 color: checkColor,
//                 size: 16,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // SVG ICON HELPERS  (flutter_svg package use karo)
// // flutter_svg: ^2.0.0  — pubspec.yaml mein add karo
// // ─────────────────────────────────────────────
// //
// // Example usage with flutter_svg:
// //
// // import 'package:flutter_svg/flutter_svg.dart';
// //
// // Widget whatsappIcon() => SvgPicture.asset('assets/icons/whatsapp.svg');
// // Widget facebookIcon() => SvgPicture.asset('assets/icons/facebook.svg');
// // Widget instagramIcon() => SvgPicture.asset('assets/icons/instagram.svg');
// // Widget youtubeIcon() => SvgPicture.asset('assets/icons/youtube.svg');
// //
// // Ya agar SVG string directly embed karna ho:
// //
// // Widget whatsappIconInline() => SvgPicture.string('''
// //   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
// //     <!-- tumhara whatsapp svg yahan -->
// //   </svg>
// // ''');

// // ─────────────────────────────────────────────
// // DEMO: PLACEHOLDER ICONS (flutter_svg k bina)
// // ─────────────────────────────────────────────

// Widget _placeholderIcon(Color color, IconData icon) {
//   return Container(
//     decoration: BoxDecoration(
//       color: color,
//       borderRadius: BorderRadius.circular(10),
//     ),
//     child: Icon(icon, color: Colors.white, size: 22),
//   );
// }

// // ─────────────────────────────────────────────
// // EXAMPLE USAGE
// // ─────────────────────────────────────────────

// class SocialStatsDemo extends StatelessWidget {
//   const SocialStatsDemo({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = [
//       SocialStatItem(
//         label: 'WhatsApp',
//         count: 45,
//     //  icon: SvgPicture.asset('assets/icons/whatsapp.svg'),
//         icon: _placeholderIcon(const Color(0xFF25D366), Icons.chat),
//       ),
//       SocialStatItem(
//         label: 'Facebook',
//         count: 32,
//         icon: _placeholderIcon(const Color(0xFF1877F2), Icons.facebook),
//       ),
//       SocialStatItem(
//         label: 'Instagram',
//         count: 21,
//         icon: _placeholderIcon(const Color(0xFFE1306C), Icons.photo_camera),
//       ),
//       SocialStatItem(
//         label: 'YouTube',
//         count: 16,
//         icon: _placeholderIcon(const Color(0xFFFF0000), Icons.play_circle_fill),
//       ),
//       SocialStatItem(
//         label: 'Others',
//         count: 12,
//         icon: _placeholderIcon(const Color(0xFF6B7280), Icons.more_horiz),
//       ),
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xFF0D1B4B),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: SocialStatsWidget(items: items),
//         ),
//       ),
//     );
//   }
// }

