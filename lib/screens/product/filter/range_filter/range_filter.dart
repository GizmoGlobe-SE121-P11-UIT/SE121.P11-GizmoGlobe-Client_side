import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';

class RangeFilter extends StatelessWidget {
  final String name;
  final TextEditingController fromController;
  final TextEditingController toController;
  final Function(String) onFromValueChanged;
  final Function(String) onToValueChanged;
  final String fromValue;
  final String toValue;
  final String? fromHint;
  final String? toHint;

  const RangeFilter({
    super.key,
    required this.name,
    required this.fromController,
    required this.toController,
    required this.onFromValueChanged,
    required this.onToValueChanged,
    required this.fromValue,
    required this.toValue,
    this.fromHint,
    this.toHint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 20.0,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).from,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16.0,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  FieldWithIcon(
                    controller: fromController,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: fromHint ?? S.of(context).min,
                    onChanged: onFromValueChanged,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).to,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  FieldWithIcon(
                    controller: toController,
                    fillColor: Theme.of(context).colorScheme.surface,
                    hintText: toHint ?? S.of(context).max,
                    onChanged: onToValueChanged,
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
