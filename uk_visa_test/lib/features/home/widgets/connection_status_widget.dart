import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_lifecycle_provider.dart';
import '../../../app/theme/app_colors.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  const ConnectionStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycleState = ref.watch(appLifecycleProvider);
    final theme = Theme.of(context);

    if (lifecycleState.isBackendConnected) {
      return const SizedBox.shrink(); // Don't show anything when connected
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: AppColors.warning,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unable to connect to server. Some features may not work.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(appLifecycleProvider.notifier).retryConnection();
            },
            child: Text(
              'Retry',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}