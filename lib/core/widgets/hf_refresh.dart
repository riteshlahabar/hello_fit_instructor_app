import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// Pull-to-refresh — the one spinner every trainer screen uses.
///
/// Wraps a scrollable in a `RefreshIndicator` in the app's orange. The point
/// of having it here rather than per screen is [physics]: a `RefreshIndicator`
/// only fires when its child *accepts* an over-scroll drag, and a scrollable
/// whose content fits the viewport refuses one. So the screens that most need
/// the gesture — an error panel, an empty list, a short profile — are exactly
/// the ones a bare `RefreshIndicator` silently does nothing on.
///
/// [child] must therefore carry `physics: HFRefresh.physics`.
/// `ScrollConfiguration` is not a way round it: that replaces the platform
/// physics instead of wrapping them, which costs the clamp and the fling.
/// [HFRefreshList] is the pairing already made — prefer it.
class HFRefresh extends StatelessWidget {
  const HFRefresh({super.key, required this.onRefresh, required this.child});

  /// Re-fetches. The spinner stays up until this future answers, so hand it
  /// `ref.refresh(someProvider.future)` and not a fire-and-forget invalidate.
  final Future<void> Function() onRefresh;

  /// A scrollable built with `physics: HFRefresh.physics`.
  final Widget child;

  /// Always drag-able, platform feel kept: a `ScrollView` applies this *to*
  /// the physics it would otherwise have, rather than replacing them.
  static const ScrollPhysics physics = AlwaysScrollableScrollPhysics();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: HFColors.primary,
      backgroundColor: HFColors.white,
      strokeWidth: 2.4,
      displacement: 22,
      child: child,
    );
  }
}

/// [HFRefresh] over a `ListView` — the body of every tab screen.
class HFRefreshList extends StatelessWidget {
  const HFRefreshList({
    super.key,
    required this.onRefresh,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 4, 20, 20),
  });

  final Future<void> Function() onRefresh;
  final List<Widget> children;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return HFRefresh(
      onRefresh: onRefresh,
      child: ListView(
        physics: HFRefresh.physics,
        padding: padding,
        children: children,
      ),
    );
  }
}

/// The spinner a screen shows while its first read is in flight, as a list
/// row so it sits inside the refreshable scrollable instead of replacing it.
class HFLoadingRow extends StatelessWidget {
  const HFLoadingRow({super.key, this.top = 40});

  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: top),
      child: const Center(
        child: CircularProgressIndicator(color: HFColors.primary),
      ),
    );
  }
}
