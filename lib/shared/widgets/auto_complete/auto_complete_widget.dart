import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sgem/shared/widgets/auto_complete/custom_autocomplete.dart';

class CustomAutocompleteWidget<T extends Object> extends StatelessWidget {
  const CustomAutocompleteWidget({
    Key? key,
    required this.width,
    required this.labelText,
    required this.hintText,
    required this.displayStringForOption,
    required this.isRequired,
    required this.onChangedSelect,
    required this.optionsBuilder,
    this.optionsViewBuilder,
    this.onChanged,
  }) : super(key: key);

  final double width;
  final String labelText;
  final String hintText;
  final bool isRequired;
  final void Function(T) onChangedSelect;
  final String Function(T) displayStringForOption;
  final FutureOr<Iterable<T>> Function(TextEditingValue) optionsBuilder;
  final Widget Function(BuildContext, void Function(T), Iterable<T>)?
      optionsViewBuilder;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return CustomAutocomplete<T>(
      width: width,
      optionsBuilder: optionsBuilder,
      displayStringForOption: displayStringForOption,
      onSelected: (value) => onChangedSelect(value),
      optionsViewBuilder: optionsViewBuilder,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return SizedBox(
          width: width,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: onChanged,
                  onSubmitted: (value) => onChangedSelect,
                  decoration: InputDecoration(
                    labelText: labelText,
                    hintText: hintText,
                    labelStyle: TextStyle(color: Colors.grey.shade400),
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    suffixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  ),
                  controller: textEditingController,
                  focusNode: focusNode,
                ),
              ),
              if (isRequired)
                const Padding(
                  padding: EdgeInsets.only(left: 6, bottom: 16),
                  child: Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                )
              else
                const SizedBox(width: 12),
            ],
          ),
        );
      },
    );
  }
}
