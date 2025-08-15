// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../providers/bilingual_provider.dart';
// import '../providers/translation_stats_provider.dart';
//
// class LanguageSettingsDialog extends ConsumerWidget {
//   const LanguageSettingsDialog({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final bilingualState = ref.watch(bilingualProvider);
//     final bilingualNotifier = ref.read(bilingualProvider.notifier);
//     final translationStats = ref.watch(translationStatsProvider);
//
//     return Dialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header
//             Row(
//               children: [
//                 Icon(
//                   Icons.language,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 const SizedBox(width: 12),
//                 Text(
//                   'Language Settings',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 24),
//
//             // Vietnamese toggle
//             _buildToggleOption(
//               context,
//               title: 'Enable Vietnamese',
//               subtitle: 'Show both English and Vietnamese text',
//               icon: Icons.translate,
//               value: bilingualState.isEnabled,
//               onChanged: bilingualState.isLoading ? null : (value) {
//                 bilingualNotifier.toggleBilingual();
//               },
//               isLoading: bilingualState.isLoading,
//             ),
//
//             // Translation stats
//             if (bilingualState.isEnabled) ...[
//               const SizedBox(height: 16),
//               _buildTranslationStats(context, translationStats),
//             ],
//
//             // Error message
//             if (bilingualState.error != null) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.red.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.red.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: Colors.red, size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         bilingualState.error!,
//                         style: TextStyle(color: Colors.red[700], fontSize: 12),
//                       ),
//                     ),
//                     IconButton(
//                       onPressed: () => bilingualNotifier.clearError(),
//                       icon: Icon(Icons.close, size: 16),
//                       constraints: BoxConstraints(maxWidth: 32, maxHeight: 32),
//                       padding: EdgeInsets.zero,
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//
//             const SizedBox(height: 24),
//
//             // Close button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: Text('Close'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildToggleOption(
//       BuildContext context, {
//         required String title,
//         required String subtitle,
//         required IconData icon,
//         required bool value,
//         required ValueChanged<bool>? onChanged,
//         bool isLoading = false,
//       }) => Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.withOpacity(0.3)),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(
//               icon,
//               color: Theme.of(context).primaryColor,
//               size: 20,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isLoading)
//             SizedBox(
//               width: 20,
//               height: 20,
//               child: CircularProgressIndicator(strokeWidth: 2),
//             )
//           else
//             Switch(
//               value: value,
//               onChanged: onChanged,
//               activeColor: Theme.of(context).primaryColor,
//             ),
//         ],
//       ),
//     );
//
//   Widget _buildTranslationStats(BuildContext context, AsyncValue<TranslationStats?> statsAsync) => Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.blue.withOpacity(0.2)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.analytics_outlined, color: Colors.blue, size: 16),
//               const SizedBox(width: 8),
//               Text(
//                 'Translation Coverage',
//                 style: Theme.of(context).textTheme.titleSmall?.copyWith(
//                   color: Colors.blue[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           statsAsync.when(
//             data: (stats) {
//               if (stats == null) return Text('No data available', style: TextStyle(fontSize: 12));
//               return Column(
//                 children: [
//                   _buildStatRow('Questions', stats.questionsCoverage),
//                   const SizedBox(height: 4),
//                   _buildStatRow('Answers', stats.answersCoverage),
//                 ],
//               );
//             },
//             loading: () => const SizedBox(
//               height: 20,
//               child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
//             ),
//             error: (_, __) => const Text('Failed to load stats', style: TextStyle(fontSize: 12)),
//           ),
//         ],
//       ),
//     );
//
//   Widget _buildStatRow(String label, double percentage) => Row(
//       children: [
//         Expanded(
//           flex: 2,
//           child: Text(label, style: TextStyle(fontSize: 12)),
//         ),
//         Expanded(
//           flex: 3,
//           child: LinearProgressIndicator(
//             value: percentage / 100,
//             backgroundColor: Colors.grey.withOpacity(0.2),
//             valueColor: AlwaysStoppedAnimation<Color>(
//               percentage >= 80 ? Colors.green :
//               percentage >= 50 ? Colors.orange : Colors.red,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text('${percentage.toInt()}%', style: TextStyle(fontSize: 12)),
//       ],
//     );
// }