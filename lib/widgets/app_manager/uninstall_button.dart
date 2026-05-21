// import 'package:flutter/material.dart';
// import '../constants/app_colors.dart';

// class UninstallButton extends StatelessWidget {
//   final int selectedCount;
//   final VoidCallback onUninstall;

//   const UninstallButton({
//     super.key,
//     required this.selectedCount,
//     required this.onUninstall,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: selectedCount > 0 ? onUninstall : null,
//       child: Container(
//         height: 52,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [
//               AppColors.uninstallButton,
//               AppColors.uninstallButtonEnd,
//             ],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ),
//           borderRadius: BorderRadius.circular(28),
//           boxShadow: selectedCount > 0
//               ? [
//                   BoxShadow(
//                     color: AppColors.uninstallButton.withOpacity(0.4),
//                     blurRadius: 12,
//                     offset: const Offset(0, 4),
//                   ),
//                 ]
//               : [],
//         ),
//         child: Center(
//           child: Text(
//             'Uninstall ($selectedCount)',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.3,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }