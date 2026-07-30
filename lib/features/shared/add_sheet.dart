import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:UangKu/utils/wizard.dart';
import 'package:UangKu/features/shared/step_sheet.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

// final pages = {
//   'router': SelectPage(),
//   'home': HomePage(),
//   'settings': SettingsPage(),
// };

enum AddType { transaction, budget, credit }

class AddItem {
  final String title;
  final AddType type;
  final Widget leading;
  AddItem(this.title, this.type, this.leading);
}

List<TransactionStep> homeSteps = [
  TransactionStep(title: "Source", content: const SourceStep()),

  TransactionStep(title: "Type", content: const TransactionTypeStep()),

  TransactionStep(title: "Details", content: const DetailsStep()),

  TransactionStep(title: "Confirm", content: const ConfirmationStep()),
];

List<TransactionStep> walletSteps = [
  TransactionStep(title: "Type", content: const TransactionTypeStep()),

  TransactionStep(title: "Details", content: const DetailsStep()),

  TransactionStep(title: "Confirm", content: const ConfirmationStep()),
];

class AddSheet extends StatefulWidget {
  final bool isRouter;
  final AddType? type;

  const AddSheet({super.key, required this.isRouter, this.type});

  @override
  State<AddSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<AddSheet> {
  int currentStep = 0;
  AddType? selectedType;

  List<TransactionStep> get steps {
    switch (widget.type) {
      case AddType.transaction:
        return homeSteps;

      case AddType.budget:
        return homeSteps;

      case AddType.credit:
        return homeSteps;

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRouter) {
      return _buildRouter();
    }

    return _buildSteps();
  }

  Widget _buildRouter() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    final items = [
      AddItem(
        "Transaction",
        AddType.transaction,
        Icon(PhosphorIconsRegular.piggyBank),
      ),
      AddItem("Budget", AddType.budget, Icon(PhosphorIconsRegular.handCoins)),
      AddItem("Credit", AddType.credit, Icon(PhosphorIconsRegular.creditCard)),
    ];

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 2.5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 6),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Quick Add",
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: context.extra.grayColor),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "What would you like to do ?",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              ...items.map((item) {
                final isSelected = selectedType == item.type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: item.leading,
                    title: Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(text: "|  "),
                          TextSpan(text: item.title),
                        ],
                      ),
                    ),
                    horizontalTitleGap: 8,
                    titleTextStyle: Theme.of(context).textTheme.labelMedium,

                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),

                    tileColor: isSelected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),

                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,

                        width: 2,
                      ),
                    ),

                    onTap: () {
                      setState(() {
                        selectedType = item.type;
                      });
                    },
                  ),
                );
              }),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedType == null
                        ? Colors.grey
                        : context.colors.primary,
                    foregroundColor: selectedType == null
                        ? Colors.grey.shade300
                        : Colors.black,
                  ),
                  onPressed: selectedType == null
                      ? null
                      : () {
                          Navigator.pop(context);

                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) =>
                                AddSheet(isRouter: false, type: selectedType),
                          );
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        "Continue",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Icon(PhosphorIconsRegular.caretRight, size: 16),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSteps() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final currentSteps = steps;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 2.5,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 12),

              StepIndicator(
                currentStep: currentStep,
                totalSteps: currentSteps.length,
                titles: currentSteps.map((e) => e.title).toList(),
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentSteps[currentStep].content,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  if (currentStep > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStep--;
                        });
                      },
                      child: const Text("Back"),
                    ),

                  const Spacer(),

                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (currentStep < currentSteps.length - 1) {
                        setState(() {
                          currentStep++;
                        });
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Text(
                      currentStep == currentSteps.length - 1 ? "Save" : "Next",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}





// class _CreateMultiSheetState() extends State<AddSheet> {
//   int currentStep = 0;

//   List<TransactionStep> get steps {
//     return homeSteps;
//   }

//   final form = TransactionFormData();

//   @override
//   Widget build(BuildContext context) {
//     final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
//     final currentSteps = steps;

//     return AnimatedPadding(
//       duration: const Duration(milliseconds: 200),
//       padding: EdgeInsets.only(bottom: keyboardHeight),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 80,
//                 height: 2.5,
//                 margin: const EdgeInsets.only(bottom: 20),
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(100),
//                 ),
//               ),

//               StepIndicator(
//                 currentStep: currentStep,
//                 totalSteps: currentSteps.length,
//                 titles: currentSteps.map((e) => e.title).toList(),
//               ),

//               const SizedBox(height: 24),

//               AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 child: currentSteps[currentStep].content,
//               ),

//               const SizedBox(height: 24),

//               Row(
//                 children: [
//                   if (currentStep > 0)
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           currentStep--;
//                         });
//                       },
//                       child: const Text("Back"),
//                     ),

//                   const Spacer(),

//                   ElevatedButton(
//                     onPressed: () {
//                       FocusScope.of(context).unfocus();
//                       if (currentStep < currentSteps.length - 1) {
//                         setState(() {
//                           currentStep++;
//                         });
//                       } else {
//                         Navigator.pop(context);
//                       }
//                     },
//                     child: Text(
//                       currentStep == currentSteps.length - 1 ? "Save" : "Next",
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


