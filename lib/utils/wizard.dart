import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:UangKu/theme/theme_extensions.dart';

class StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final bool showIndicatorStep;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const StepHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.currentStep = 0,
    this.totalSteps = 0,
    this.activeColor = Colors.blue,
    this.showIndicatorStep = true,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(title, style: context.text.titleLarge),
            if (subtitle != '')
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: context.extra.grayColor),
              ),
          ],
        ),

        Row(
          spacing: 2,
          children: [
            if (showIndicatorStep)
              StepDotsIndicator(
                currentStep: currentStep,
                totalSteps: totalSteps,
                activeColor: activeColor,
              ),

            if (showCloseButton)
              InkWell(
                borderRadius: BorderRadius.circular(15),
                onTap: onClose ?? () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(PhosphorIconsRegular.xCircle, size: 26),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class StepDotsIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color activeColor;
  final Color? inactiveColor;
  final double size;
  final double spacing;
  final VoidCallback? onClose;
  final bool showCloseButton;

  const StepDotsIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.activeColor,
    this.inactiveColor,
    this.size = 6,
    this.spacing = 4,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final inactive = inactiveColor ?? Colors.grey.shade300;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final isActive = index == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? size + 20 : size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactive,
            borderRadius: BorderRadius.circular(size),
          ),
        );
      }),
    );
  }
}

// class StepIndicator extends StatelessWidget {
//   final int currentStep;
//   final int totalSteps;
//   final List<String> titles;

//   const StepIndicator({
//     super.key,
//     required this.currentStep,
//     required this.totalSteps,
//     required this.titles,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: List.generate(totalSteps * 2 - 1, (index) {
//         // Circle
//         if (index.isEven) {
//           final step = index ~/ 2;

//           final active = step <= currentStep;

//           return Expanded(
//             flex: 0,
//             child: Column(
//               children: [
//                 AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color: active
//                         ? Theme.of(context).colorScheme.primary
//                         : Colors.grey.shade300,
//                   ),
//                   child: Center(
//                     child: step < currentStep
//                         ? const Icon(
//                             Icons.check,
//                             color: Colors.white,
//                             size: 18,
//                           )
//                         : Text(
//                             "${step + 1}",
//                             style: TextStyle(
//                               color: active
//                                   ? Colors.white
//                                   : Colors.grey.shade600,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   titles[step],
//                   style: const TextStyle(fontSize: 12),
//                 ),
//               ],
//             ),
//           );
//         }

//         // Line
//         return Expanded(
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 250),
//             height: 3,
//             margin: const EdgeInsets.only(bottom: 20),
//             color: (index ~/ 2) < currentStep
//                 ? Theme.of(context).colorScheme.primary
//                 : Colors.grey.shade300,
//           ),
//         );
//       }),
//     );
//   }
// }
