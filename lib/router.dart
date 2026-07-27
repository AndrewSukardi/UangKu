import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_page.dart';
import 'features/wallet/wallet_page.dart';
import 'features/budget/budget_page.dart';
import 'features/credit/credit_page.dart';
import 'features/shared/add_sheet.dart';

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
        addBraches('/transactions', const WalletPage()),
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
    return Scaffold(
      body: navigationShell,
      floatingActionButton: buildFab(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onTap,
        destinations: [
          navigationPage(
            "Home",
            Icon(PhosphorIconsRegular.house),
            Icon(PhosphorIconsFill.house),
          ),
          navigationPage(
            "Transactions",
            Icon(PhosphorIconsRegular.piggyBank),
            Icon(PhosphorIconsFill.piggyBank),
          ),
          navigationPage(
            "Budget",
            Icon(PhosphorIconsRegular.handCoins),
            Icon(PhosphorIconsFill.handCoins),
          ),
          navigationPage(
            "Credit",
            Icon(PhosphorIconsRegular.creditCard),
            Icon(PhosphorIconsFill.creditCard),
          ),
        ],
      ),
    );
  }

  Widget buildFab(BuildContext context) {
    return FloatingActionButton.small(
      
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (_) => const AddSheet(isRouter: true,),
        );
      },

      shape: const CircleBorder(),
      
      child: Icon(PhosphorIconsBold.plus, size: 20,color: context.colors.onPrimary),
    );
  }
}
