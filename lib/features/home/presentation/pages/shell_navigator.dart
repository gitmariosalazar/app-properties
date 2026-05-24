// lib/features/home/presentation/pages/shell_navigator.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ShellNavigator extends StatelessWidget {
  final Widget child;
  const ShellNavigator({super.key, required this.child});

  static const _destinations = [
    _NavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Inicio',
      route: '/home',
    ),
    _NavItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
      label: 'Dashboard',
      route: '/dashboard',
    ),
    _NavItem(
      icon: Icons.map_outlined,
      activeIcon: Icons.map_rounded,
      label: 'Predios',
      route: '/search-connection',
    ),
    _NavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Config.',
      route: '/settings',
    ),
  ];

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/dashboard')) return 1;
    if (loc.startsWith('/search-connection')) return 2;
    if (loc.startsWith('/settings')) return 3;
    return 0; // /home
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final idx = _tabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: _DashboardNavBar(
        selectedIndex: idx,
        destinations: _destinations,
        onTap: (i) => context.go(_destinations[i].route),
        background: cs.surfaceContainerHighest,
        indicatorColor: cs.primary,
        selectedColor: cs.primary,
        unselectedColor: cs.onSurfaceVariant,
      ),
    );
  }
}

// ── Custom Bottom Nav ──────────────────────────────────────────────────────

class _DashboardNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> destinations;
  final ValueChanged<int> onTap;
  final Color background;
  final Color indicatorColor;
  final Color selectedColor;
  final Color unselectedColor;

  const _DashboardNavBar({
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
    required this.background,
    required this.indicatorColor,
    required this.selectedColor,
    required this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 62,
          child: Row(
            children: destinations.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? indicatorColor.withValues(alpha: 0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected ? selectedColor : unselectedColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: selected ? selectedColor : unselectedColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
