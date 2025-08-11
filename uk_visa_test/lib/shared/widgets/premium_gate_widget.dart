import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';

class PremiumGateWidget extends StatelessWidget {
  final Widget child;
  final String featureName;
  final VoidCallback? onUpgradePressed;

  const PremiumGateWidget({
    super.key,
    required this.child,
    required this.featureName,
    this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) => Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authProvider);
        final isPremium = authState.user?.isPremium ?? false;

        if (isPremium) {
          return child;
        }

        return Stack(
          children: [
            // Blurred content
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: child,
                ),
              ),
            ),
            // Premium overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Premium Feature',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upgrade to access $featureName',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: onUpgradePressed,
                        icon: const Icon(Icons.star),
                        label: const Text('Upgrade Now'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
}