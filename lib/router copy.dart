// import 'package:UangKu/theme/theme_extensions.dart';
// import 'package:flutter/material.dart';
// import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
// import 'package:go_router/go_router.dart';

// import 'features/home/home_page.dart';
// import 'features/wallet/wallet_page.dart';
// import 'features/budget/budget_page.dart';
// import 'features/credit/credit_page.dart';
// import 'features/shared/add_sheet.dart';

// StatefulShellBranch addBraches(String path, Widget page) {
//   return StatefulShellBranch(
//     routes: [
//       GoRoute(
//         path: path,
//         builder: (context, state) {
//           return page;
//         },
//       ),
//     ],
//   );
// }

// NavigationDestination navigationPage(String label, Icon outline, Icon fill) {
//   return NavigationDestination(icon: outline, selectedIcon: fill, label: label);
// }

// final router = GoRouter(
//   initialLocation: '/home',

//   routes: [
//     StatefulShellRoute.indexedStack(
//       builder: (context, state, navigationShell) {
//         return MainPage(navigationShell: navigationShell);
//       },
//       branches: [
//         addBraches('/home', const HomePage()),
//         addBraches('/history', const WalletPage()),
//         addBraches('/budget', const BudgetPage()),
//         addBraches('/credit', const CreditPage()),
//       ],
//     ),
//   ],
// );

// class MainPage extends StatelessWidget {
//   final StatefulNavigationShell navigationShell;

//   const MainPage({super.key, required this.navigationShell});

//   void _onTap(int index) {
//     navigationShell.goBranch(
//       index,
//       initialLocation: index == navigationShell.currentIndex,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: navigationShell,

//       floatingActionButton: buildFab(context),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

//       bottomNavigationBar: BottomAppBar(
//         color: context.colors.onPrimary,
//         shape: const CircularNotchedRectangle(),
//         notchMargin: 8,
//         // elevation: 8,
//         child: SizedBox(
//           height: 72,
//           child: Row(
//             children: [
//               Expanded(
//                 child: _navItem(
//                   context,
//                   index: 0,
//                   label: "Home",
//                   outline: PhosphorIconsRegular.house,
//                   fill: PhosphorIconsFill.house,
//                 ),
//               ),
//               Expanded(
//                 child: _navItem(
//                   context,
//                   index: 1,
//                   label: "History",
//                   outline: PhosphorIconsRegular.listDashes,
//                   fill: PhosphorIconsFill.listDashes,
//                 ),
//               ),

//               const SizedBox(width: 64),

//               Expanded(
//                 child: _navItem(
//                   context,
//                   index: 2,
//                   label: "Budget",
//                   outline: PhosphorIconsRegular.handCoins,
//                   fill: PhosphorIconsFill.handCoins,
//                 ),
//               ),
//               Expanded(
//                 child: _navItem(
//                   context,
//                   index: 3,
//                   label: "Credit",
//                   outline: PhosphorIconsRegular.creditCard,
//                   fill: PhosphorIconsFill.creditCard,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem(
//     BuildContext context, {
//     required int index,
//     required String label,
//     required IconData outline,
//     required IconData fill,
//   }) {
//     final selected = navigationShell.currentIndex == index;

//     final color = selected
//         ? Theme.of(context).colorScheme.primary
//         : Theme.of(context).colorScheme.onSurfaceVariant;

//     return InkWell(
//       onTap: () => _onTap(index),
//       borderRadius: BorderRadius.circular(16),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(selected ? fill : outline, color: color, size: 24),
//           const SizedBox(height: 5),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: color,
//               fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildFab(BuildContext context) {
//     return SizedBox(
//       width: 56,
//       height: 56,
//       child: FloatingActionButton(
//         shape: const CircleBorder(),

//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             builder: (_) => const AddSheet(isRouter: true),
//           );
//         },
//         child: Icon(
//           PhosphorIconsBold.plus,
//           size: 28,
//           color: context.colors.onPrimary,
//         ),
//       ),
//     );
//   }
// }
