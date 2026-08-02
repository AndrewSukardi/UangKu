import 'package:UangKu/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:UangKu/utils/wizard.dart';
import 'package:UangKu/features/sheet/step_sheet.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:UangKu/utils/icon_assets.dart';

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
  final String subtitle;
  AddItem(this.title, this.type, this.leading, this.subtitle);
}

List<TransactionStep> homeSteps = [
  TransactionStep(title: "Amount & type", content: const SourceStep()),

  TransactionStep(title: "Category", content: const TransactionTypeStep()),

  TransactionStep(title: "Details", content: const DetailsStep()),

  TransactionStep(title: "Confimation", content: const ConfirmationStep()),
];

List<TransactionStep> walletSteps = [
  TransactionStep(title: "Type", content: const TransactionTypeStep()),

  TransactionStep(title: "Details", content: const DetailsStep()),

  TransactionStep(title: "Confirm", content: const ConfirmationStep()),
];

class ActionSheet extends StatefulWidget {
  final bool isRouter;
  final String titleRouter;
  final AddType? type;

  const ActionSheet({
    super.key,
    required this.isRouter,
    this.titleRouter = '',
    this.type,
  });

  @override
  State<ActionSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<ActionSheet> {
  int currentStep = 0;
  AddType? selectedType;
  String selectedTitle = '';

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
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Image.asset(
              IconAssets.transaction.path,
              width: 24,
              height: 24,
            ),
          ),
        ),
        "Record an expense or income",
      ),
      AddItem(
        "Budget",
        AddType.budget,
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Image.asset(IconAssets.budget.path, width: 24, height: 24),
          ),
        ),
        "Create a category spending limit",
      ),
      AddItem(
        "Credit",
        AddType.credit,
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Image.asset(
              IconAssets.creditCard.path,
              width: 24,
              height: 24,
            ),
          ),
        ),
        "Track a new card, debt, or bill",
      ),
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
                width: 75,
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 6),

              StepHeader(
                title: "Quick Add",
                subtitle: "What would you like to do ?",
                showCloseButton: false,
                showIndicatorStep: false,
              ),

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 6),
              //   child: Column(
              //     children: [
              //       Align(
              //         alignment: Alignment.centerLeft,
              //         child: Text(
              //           "Quick Add",
              //           style: Theme.of(context).textTheme.headlineSmall
              //               ?.copyWith(fontWeight: FontWeight.bold),
              //         ),
              //       ),

              //       SizedBox(height: 2),

              //       Align(
              //         alignment: Alignment.centerLeft,
              //         child: Text(
              //           "What would you like to do ?",
              //           style: Theme.of(context).textTheme.bodySmall?.copyWith(
              //             color: context.extra.grayColor,
              //           ),
              //         ),
              //       ),

              //       SizedBox(height: 8),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 12),

              ...items.map((item) {
                final isSelected = selectedType == item.type;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: item.leading,
                    title: Text(
                      item.title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      item.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    horizontalTitleGap: 8,

                    titleTextStyle: Theme.of(context).textTheme.labelMedium,

                    contentPadding: const EdgeInsets.symmetric(horizontal: 5),

                    tileColor: isSelected
                        ? context.colors.primaryContainer
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
                        selectedTitle = item.title;
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
                            builder: (_) => ActionSheet(
                              isRouter: false,
                              titleRouter: selectedTitle,
                              type: selectedType,
                            ),
                          );
                        },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      Text(
                        "Continue",
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(width: 4),
                      Icon(PhosphorIconsBold.arrowRight, size: 16),
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
          padding: const EdgeInsets.fromLTRB(
            20, // left
            20, // top
            20, // right
            40, // bottom
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 3,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              // const SizedBox(height: 8),

              // StepIndicator(
              //   currentStep: currentStep,
              //   totalSteps: currentSteps.length,
              //   titles: currentSteps.map((e) => e.title).toList(),
              // ),
              StepHeader(
                title: widget.titleRouter,
                subtitle: currentSteps[currentStep].title,
                currentStep: currentStep,
                totalSteps: currentSteps.length,
                activeColor: Colors.blue,
                showCloseButton: false,
              ),

              const SizedBox(height: 24),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: currentSteps[currentStep].content,
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentStep > 0) {
                          setState(() {
                            currentStep--;
                          });
                        } else {
                          Navigator.pop(context);
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const ActionSheet(isRouter: true),
                          );
                        }
                      },
                      child: Text(
                        currentStep > 0 ? "Back" : "Change",
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: (currentStep > 0 || currentStep == 0) ? 2 : 1,

                    child: ElevatedButton(
                      // onTap:(){

                      // },
                      
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedType == null
                            ? Colors.grey
                            : context.colors.primary,
                        foregroundColor: selectedType == null
                            ? Colors.grey.shade300
                            : Colors.black,
                      ),
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
                        currentStep == currentSteps.length - 1
                            ? "Save"
                            : "Next",
                        style: context.text.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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


