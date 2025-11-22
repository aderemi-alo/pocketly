import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocketly/features/shared/widgets/network_restored_banner.dart';

class BannerService {
  static OverlayEntry? _currentBanner;
  static BuildContext? _context;

  /// Show network restored banner
  static void showNetworkRestoredBanner(
    BuildContext context,
    int pendingCount,
  ) {
    _context = context;
    _dismissCurrentBanner();

    _currentBanner = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        left: 16,
        right: 16,
        child: NetworkRestoredBanner(pendingCount: pendingCount),
      ),
    );

    Overlay.of(context).insert(_currentBanner!);
  }

  /// Show long offline reminder banner
  static void showLongOfflineReminder(BuildContext context) {
    _context = context;
    _dismissCurrentBanner();

    _currentBanner = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + kToolbarHeight + 16,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.tertiary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.cloud_off,
                color: Theme.of(context).colorScheme.tertiary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Sign in to backup your data to cloud',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  // Navigate to login
                  Navigator.of(context).pushNamed('/login');
                  _dismissCurrentBanner();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.tertiary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('Sign In'),
              ),
              TextButton(
                onPressed: _dismissCurrentBanner,
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onTertiaryContainer,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                ),
                child: const Text('Dismiss'),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_currentBanner!);
  }

  /// Dismiss current banner
  static void _dismissCurrentBanner() {
    _currentBanner?.remove();
    _currentBanner = null;
  }

  /// Dismiss current banner (public method)
  static void dismissBanner() {
    _dismissCurrentBanner();
  }
}

/// Banner state provider
class BannerState {
  final bool isNetworkRestoredBannerVisible;
  final bool isLongOfflineBannerVisible;
  final DateTime? lastBannerDismissal;

  BannerState({
    this.isNetworkRestoredBannerVisible = false,
    this.isLongOfflineBannerVisible = false,
    this.lastBannerDismissal,
  });

  BannerState copyWith({
    bool? isNetworkRestoredBannerVisible,
    bool? isLongOfflineBannerVisible,
    DateTime? lastBannerDismissal,
  }) {
    return BannerState(
      isNetworkRestoredBannerVisible:
          isNetworkRestoredBannerVisible ?? this.isNetworkRestoredBannerVisible,
      isLongOfflineBannerVisible:
          isLongOfflineBannerVisible ?? this.isLongOfflineBannerVisible,
      lastBannerDismissal: lastBannerDismissal ?? this.lastBannerDismissal,
    );
  }
}

class BannerNotifier extends StateNotifier<BannerState> {
  BannerNotifier() : super(BannerState());

  void showNetworkRestoredBanner() {
    state = state.copyWith(isNetworkRestoredBannerVisible: true);
  }

  void showLongOfflineBanner() {
    state = state.copyWith(isLongOfflineBannerVisible: true);
  }

  void dismissBanner() {
    state = state.copyWith(
      isNetworkRestoredBannerVisible: false,
      isLongOfflineBannerVisible: false,
      lastBannerDismissal: DateTime.now(),
    );
  }
}

final bannerProvider = StateNotifierProvider<BannerNotifier, BannerState>((
  ref,
) {
  return BannerNotifier();
});
