import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_panel/src/cubit/crud/crud_cubit.dart';
import 'package:flutter_panel/src/di/di.dart';
import 'package:flutter_panel/src/widget/blur_dialog.dart';
import 'package:flutter_panel/src/widget/comparison_symbol_selector.dart';
import 'package:flutter_panel/src/widget/crud/crud_scaffold.dart';
import 'package:flutter_panel/src/widget/custom_text.dart';
import 'package:flutter_panel/src/widget/custom_text_field.dart';
import 'package:vibes_common/vibes.dart';

import '../../route/router.gr.dart';

@RoutePage()
class AddPromotionPage extends StatefulWidget {
  const AddPromotionPage({super.key});

  @override
  State<AddPromotionPage> createState() => _AddPromotionPageState();
}

class _AddPromotionPageState extends State<AddPromotionPage> {
  final _titleTextEditingController = TextEditingController();
  final _bodyTextEditingController = TextEditingController();
  final _codeTextEditingController = TextEditingController();
  final frequencyTextEditingController = TextEditingController();

  final daysSinceMembershipStartConstraint = ValueNotifier<Constraint?>(null);
  final _daysSinceMembershipStartTextEditingController = TextEditingController();
  final daysSinceRegistrationConstraint = ValueNotifier<Constraint?>(null);
  final _daysSinceRegistrationTextEditingController = TextEditingController();
  final daysUntilSubEndConstraint = ValueNotifier<Constraint?>(null);
  final _daysUntilSubEndTextEditingController = TextEditingController();

  bool _titleError = false,
      _bodyError = false,
      _codeError = false,
      frequencyError = false,
      _daysSinceMembershipStartError = false,
      _daysSinceRegistrationError = false,
      _daysUntilSubEndError = false;

  PromotionTarget promotionTarget = PromotionTarget.free;
  PromotionSubscriptionType? promotionSubscriptionType;

  late final CrudCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = CrudCubit(api: inject(), uploadApi: inject());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CrudCubit, CrudState>(
      bloc: cubit,
      listener: (BuildContext context, state) {
        state.whenOrNull(
          loading: () => showBlurDialog(context, '', 'Wait a moment please'),
          successfulCreate: () {
            Navigator.of(context).pop();
            AutoRouter.of(context).replace(const PromotionsRoute());
          },
          failure: (e) {
            Navigator.of(context).pop();
          },
        );
      },
      child: CrudScaffold(
        title: strings.addNewPromotion,
        submitButtonLabel: strings.send,
        onResetClickHandler: _resetForm,
        onSubmitClickHandler: _submitForm,
        children: [
          CustomTextField(
            controller: _titleTextEditingController,
            label: strings.title,
            error: _titleError,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _bodyTextEditingController,
            hint: strings.body,
            error: _bodyError,
            maxLines: 6,
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: _codeTextEditingController,
            hint: strings.code,
            error: _codeError,
            maxLines: 4,
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              SizedBox(width: 200, child: CustomText(text: '${strings.target}:')),
              DropdownButton<PromotionTarget>(
                value: promotionTarget,
                items: const [
                  DropdownMenuItem(
                    value: PromotionTarget.free,
                    child: Text('Free Users'),
                  ),
                  DropdownMenuItem(
                    value: PromotionTarget.paid,
                    child: Text('Paid Users'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      promotionTarget = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              SizedBox(width: 200, child: CustomText(text: '${strings.subscriptionType}:')),
              DropdownButton<PromotionSubscriptionType>(
                value: promotionSubscriptionType,
                items: const [
                  DropdownMenuItem(
                    value: PromotionSubscriptionType.monthlyBilling,
                    child: Text('Monthly'),
                  ),
                  DropdownMenuItem(
                    value: PromotionSubscriptionType.annualBilling,
                    child: Text('Annual'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      promotionSubscriptionType = value;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          CustomTextField(
            controller: frequencyTextEditingController,
            label: strings.frequency,
            error: frequencyError,
            errorMessage: 'Must be an integer number',
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              ComparisonSymbolSelector(selectedComparison: daysSinceMembershipStartConstraint),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _daysSinceMembershipStartTextEditingController,
                  label: strings.daysSinceMembershipStart,
                  error: _daysSinceMembershipStartError,
                  errorMessage: 'Must be an integer number',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              ComparisonSymbolSelector(selectedComparison: daysSinceRegistrationConstraint),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _daysSinceRegistrationTextEditingController,
                  label: strings.daysSinceRegistration,
                  error: _daysSinceRegistrationError,
                  errorMessage: 'Must be an integer number',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              ComparisonSymbolSelector(selectedComparison: daysUntilSubEndConstraint),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _daysUntilSubEndTextEditingController,
                  label: strings.daysUntilSubscriptionEnd,
                  error: _daysUntilSubEndError,
                  errorMessage: 'Must be an integer number',
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 96,
          ),
        ],
      ),
    );
  }

  void _resetForm() {
    _titleTextEditingController.clear();
    _bodyTextEditingController.clear();
    _codeTextEditingController.clear();
    frequencyTextEditingController.clear();
    _daysSinceMembershipStartTextEditingController.clear();
    daysSinceMembershipStartConstraint.value = null;
    _daysSinceRegistrationTextEditingController.clear();
    daysSinceRegistrationConstraint.value = null;
    _daysUntilSubEndTextEditingController.clear();
    daysUntilSubEndConstraint.value = null;

    setState(() {
      promotionTarget = PromotionTarget.free;
      promotionSubscriptionType = null;
    });
  }

  void _submitForm() async {
    if (_validateFields()) {
      cubit.addPromotion(
        title: _titleTextEditingController.text,
        body: _bodyTextEditingController.text,
        code: _codeTextEditingController.text,
        target: promotionTarget,
        subscriptionType: promotionSubscriptionType,
        frequency: int.tryParse(frequencyTextEditingController.text),
        daysSinceMembershipStart: int.tryParse(_daysSinceMembershipStartTextEditingController.text),
        daysSinceMembershipStartConstraint: daysSinceMembershipStartConstraint.value,
        daysSinceRegistration: int.tryParse(_daysSinceRegistrationTextEditingController.text),
        daysSinceRegistrationConstraint: daysSinceRegistrationConstraint.value,
        daysUntilSubscriptionEnd: int.tryParse(_daysUntilSubEndTextEditingController.text),
        daysUntilSubscriptionEndConstraint: daysUntilSubEndConstraint.value,
      );
    }
  }

  bool _validateFields() {
    var invalidFields = 0;

    if (_titleTextEditingController.text.isEmpty) {
      setState(() {
        _titleError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _titleError = false;
      });
    }

    if (_bodyTextEditingController.text.isEmpty) {
      setState(() {
        _bodyError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _bodyError = false;
      });
    }

    if (_codeTextEditingController.text.isEmpty) {
      setState(() {
        _codeError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _codeError = false;
      });
    }

    if (frequencyTextEditingController.text.isNotEmpty && int.tryParse(frequencyTextEditingController.text) == null) {
      setState(() {
        frequencyError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        frequencyError = false;
      });
    }

    if (_daysSinceMembershipStartTextEditingController.text.isNotEmpty &&
        int.tryParse(_daysSinceMembershipStartTextEditingController.text) == null) {
      setState(() {
        _daysSinceMembershipStartError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _daysSinceMembershipStartError = false;
      });
    }

    if (_daysSinceRegistrationTextEditingController.text.isNotEmpty &&
        int.tryParse(_daysSinceRegistrationTextEditingController.text) == null) {
      setState(() {
        _daysSinceRegistrationError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _daysSinceRegistrationError = false;
      });
    }

    if (_daysUntilSubEndTextEditingController.text.isNotEmpty &&
        int.tryParse(_daysUntilSubEndTextEditingController.text) == null) {
      setState(() {
        _daysUntilSubEndError = true;
      });
      invalidFields++;
    } else {
      setState(() {
        _daysUntilSubEndError = false;
      });
    }

    if (invalidFields == 0) {
      return true;
    }

    return false;
  }
}
