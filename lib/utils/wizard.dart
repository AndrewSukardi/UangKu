import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> titles;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.titles,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Circle
        if (index.isEven) {
          final step = index ~/ 2;

          final active = step <= currentStep;

          return Expanded(
            flex: 0,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                  child: Center(
                    child: step < currentStep
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : Text(
                            "${step + 1}",
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  titles[step],
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        }

        // Line
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            margin: const EdgeInsets.only(bottom: 20),
            color: (index ~/ 2) < currentStep
                ? Theme.of(context).colorScheme.primary
                : Colors.grey.shade300,
          ),
        );
      }),
    );
  }
}