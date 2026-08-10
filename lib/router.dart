import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/wallet/wallet_page.dart';
import 'features/budget/budget_page.dart';
import 'features/credit/credit_page.dart';
import 'features/sheet/action_sheet.dart';

StatefulShellBranch addBraches(String path, Widget page) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) {
          return page;
        },
      ),
    ],
  );
}

NavigationDestination navigationPage(String label, Icon outline, Icon fill) {
  return NavigationDestination(icon: outline, selectedIcon: fill, label: label);
}

final router = GoRouter(
  initialLocation: '/home',

  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainPage(navigationShell: navigationShell);
      },
      branches: [
        addBraches('/home', const HomePage()),
        addBraches('/history', const WalletPage()),
        addBraches('/budget', const BudgetPage()),
        addBraches('/credit', const CreditPage()),
      ],
    ),
  ],
);

class MainPage extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // One GlobalKey per nav item icon, used to measure its on-screen center
  // so the indicator dash can animate underneath it.
  final List<GlobalKey> _itemKeys = List.generate(4, (_) => GlobalKey());
  final GlobalKey _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

 

  @override
  Widget build(BuildContext context) {
    // Re-measure every build so a tab switch (even via deep link/back button)
    // moves the dash to the right spot.

    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,

      bottomNavigationBar: _buildFloatingNavBar(context),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: context.colors.onPrimary,
          elevation: 8,
          shadowColor: context.colors.onSurface,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: SizedBox(
              height: 60,
              child: Stack(
                key: _stackKey,
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _navItem(
                          context,
                          index: 0,
                          label: "Home",
                          outline: PhosphorIconsRegular.house,
                          fill: PhosphorIconsBold.house,
                        ),
                      ),
                      Expanded(
                        child: _navItem(
                          context,
                          index: 1,
                          label: "History",
                          outline: PhosphorIconsRegular.listDashes,
                          fill: PhosphorIconsBold.listDashes,
                        ),
                      ),

                      // Centered FAB, inline with the nav items
                      _buildFab(context),

                      Expanded(
                        child: _navItem(
                          context,
                          index: 2,
                          label: "Budget",
                          outline: PhosphorIconsRegular.handCoins,
                          fill: PhosphorIconsBold.handCoins,
                        ),
                      ),
                      Expanded(
                        child: _navItem(
                          context,
                          index: 3,
                          label: "Credit",
                          outline: PhosphorIconsRegular.creditCard,
                          fill: PhosphorIconsBold.creditCard,
                        ),
                      ),
                    ],
                  ),

                  // // Sliding underline dash, anchored to the bottom of the bar
                  // if (_indicatorLeft != null)
                  //   AnimatedPositioned(
                  //     duration: const Duration(milliseconds: 280),
                  //     curve: Curves.easeOutCubic,
                  //     left: _indicatorLeft!,
                  //     bottom: 0,
                  //     width: _pillWidth,
                  //     height: _pillHeight,
                  //     child: DecoratedBox(
                  //       decoration: BoxDecoration(
                  //         color: Theme.of(context).colorScheme.primary,
                  //         borderRadius: BorderRadius.circular(_pillHeight),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context, {
    required int index,
    required String label,
    required IconData outline,
    required IconData fill,
  }) {
    final selected = widget.navigationShell.currentIndex == index;

    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: () => _onTap(index),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // This container is what gets measured by _itemKeys — its center
          // is where the underline dash animates to.
          Container(
            key: _itemKeys[index],
            width: 40,
            height: 32,
            alignment: Alignment.center,
            child: Icon(selected ? fill : outline, color: color, size: 24),
          ),
          if (selected)
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Material(
        color: Theme.of(context).colorScheme.primary,
        shape: const CircleBorder(),
        elevation: 4,
        shadowColor: context.colors.onSurface,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              builder: (sheetContext) => const ActionSheet(isRouter: true),
            );
          },
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(
              PhosphorIconsBold.plus,
              size: 24,
              color: context.colors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
