import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/wallet/wallet_page.dart';
import 'features/budget/budget_page.dart';
import 'features/credit/credit_page.dart';
import 'features/shared/add_sheet.dart';
import 'utils/custom_painter.dart';

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

class MainPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainPage({super.key, required this.navigationShell});

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 80;
    const double barBottomMargin = 20;
    const double fabSize = 60;
    const double fabPopHeight =
        30; // how much sticks out above the bar — lower this to reduce popup

    return Scaffold(
      body: Stack(
        children: [
          navigationShell,
          Positioned(
            left: 16,
            right: 16,
            bottom: barBottomMargin,
            child: _buildBottomBar(
              context,
            ), // pass fabRadius here too if parametrized
          ),
          Positioned(
            bottom: barBottomMargin + barHeight - fabPopHeight,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: fabSize,
                height: fabSize,
                child: buildFab(context),
              ),
            ),
          ),
        ],
      ),
      // remove floatingActionButton / floatingActionButtonLocation entirely
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return PhysicalShape(
      clipper: BottomBarClipper(notchWidth: 180, notchDepth: 40),
      color: context.colors.onPrimary,
      elevation: 12,
      shadowColor: Colors.black26,
      child: Material(
        type: MaterialType.transparency, 
        child: SizedBox(
          height: 85,
          child: Row(
            children: [
              Expanded(
                child: _navItem(
                  context,
                  index: 0,
                  label: "Home",
                  outline: PhosphorIconsRegular.house,
                  fill: PhosphorIconsFill.house,
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

              const SizedBox(width: 60),

              Expanded(
                child: _navItem(
                  context,
                  index: 2,
                  label: "Budget",
                  outline: PhosphorIconsRegular.handCoins,
                  fill: PhosphorIconsFill.handCoins,
                ),
              ),
              Expanded(
                child: _navItem(
                  context,
                  index: 3,
                  label: "Credit",
                  outline: PhosphorIconsRegular.creditCard,
                  fill: PhosphorIconsFill.creditCard,
                ),
              ),
            ],
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
    final selected = navigationShell.currentIndex == index;
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _onTap(index),
          borderRadius: BorderRadius.circular(16),
          splashFactory: InkRipple.splashFactory,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 1),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? fill : outline, color: color, size: 24),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFab(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: FloatingActionButton(
        heroTag: 'main_fab',
        shape: const CircleBorder(),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) => const AddSheet(isRouter: true),
          );
        },
        child: Icon(
          PhosphorIconsBold.plus,
          size: 28,
          color: context.colors.onPrimary,
        ),
      ),
    );
  }
}
