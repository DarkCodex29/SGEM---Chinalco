import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/shared/modules/option.value.dart';
import 'package:sgem/shared/widgets/dropDown/generic.dropdown.controller.dart';

class CustomDropdownGlobal extends StatelessWidget {
  const CustomDropdownGlobal({
    required this.dropdownKey,
    required this.labelText,
    required this.hintText,
    required this.noDataHintText,
    this.controller,
    this.staticOptions,
    this.initialValue,
    this.onChanged,
    this.isSearchable = false,
    this.isRequired = false,
    this.isReadOnly = false,
    this.readOnly = false,
    this.textFieldKey,
    super.key,
    this.excludeOptions = null,
  });
  final String dropdownKey;
  final String labelText;
  final String hintText;
  final String noDataHintText;
  final bool isSearchable;
  final bool isRequired;
  final List<int>? excludeOptions;

  @Deprecated('Use readOnly instead to disable the dropdown')
  final bool isReadOnly;

  final bool readOnly;
  final GenericDropdownController? controller;
  final List<OptionValue>? staticOptions;
  final OptionValue? initialValue;
  final void Function(OptionValue?)? onChanged;
  final Key? textFieldKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller != null && staticOptions == null)
                  Obx(() {
                    var options = controller!.getOptions(dropdownKey);
                    if (options.length > 0 &&
                        excludeOptions != null &&
                        excludeOptions!.length > 0) {
                      options = options
                          .where((element) =>
                              !excludeOptions!.contains(element.key))
                          .toList();
                    }

                    final isLoading = controller!.isLoading(dropdownKey);

                    if (isLoading) {
                      return const Center(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return _buildDropdown(options);
                  })
                else if (staticOptions != null)
                  _buildDropdown(staticOptions!)
                else
                  const Text('Error: No controller or static options provided'),
                if (isSearchable && (!readOnly || !isReadOnly))
                  _buildSearchBar(),
              ],
            ),
          ),
          if (isRequired)
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 16),
              child: Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown(List<OptionValue> options) {
    return SizedBox(
      height: 70,
      child: DropdownButtonFormField<OptionValue>(
        key: textFieldKey,
        value: initialValue ?? controller?.getSelectedValue(dropdownKey),
        isExpanded: true,
        hint: Text(
          hintText,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
        decoration: InputDecoration(
          labelText: options.isNotEmpty &&
                  (initialValue != null ||
                      controller?.getSelectedValue(dropdownKey) != null)
              ? labelText
              : null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.alternateColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.alternateColor,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        onTap: readOnly ? null : () {},
        onChanged: (readOnly || isReadOnly) || options.isEmpty
            ? null
            : (value) {
                if (controller != null) {
                  controller!.selectValue(dropdownKey, value);
                }
                if (onChanged != null) {
                  onChanged!.call(value);
                }
              },
        items: options.map((option) {
          return DropdownMenuItem<OptionValue>(
            value: option,
            child: Text(
              option.nombre ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),
          );
        }).toList(),
        disabledHint: Text(
          initialValue?.nombre ?? hintText,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          border: OutlineInputBorder(),
        ),
        onChanged: (query) {
          final options = (staticOptions ?? controller!.getOptions(dropdownKey))
              .where(
                (option) =>
                    option.nombre
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false,
              )
              .toList();
          if (controller != null && staticOptions == null) {
            controller!.optionsMap[dropdownKey]?.assignAll(options);
          }
        },
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.options,
    required this.textFieldKey,
    required this.initialValue,
    required this.controller,
    required this.dropdownKey,
    required this.noDataHintText,
    required this.hintText,
    required this.labelText,
    required this.isReadOnly,
    required this.onChanged,
  });

  final List<OptionValue> options;
  final Key? textFieldKey;
  final OptionValue? initialValue;
  final GenericDropdownController? controller;
  final String dropdownKey;
  final String noDataHintText;
  final String hintText;
  final String labelText;
  final bool isReadOnly;
  final void Function(OptionValue? p1)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: DropdownButtonFormField<OptionValue>(
        key: textFieldKey,
        value: initialValue ?? controller?.getSelectedValue(dropdownKey),
        isExpanded: true,
        hint: Text(
          options.isEmpty ? noDataHintText : hintText,
          style: const TextStyle(
            color: AppTheme.primaryText,
            fontSize: 16,
          ),
        ),
        decoration: InputDecoration(
          labelText:
              options.isNotEmpty && initialValue != null ? labelText : null,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.alternateColor,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppTheme.alternateColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 12,
          ),
        ),
        onChanged: isReadOnly || options.isEmpty
            ? null
            : (value) {
                if (controller != null) {
                  controller!.selectValue(dropdownKey, value);
                }
                if (onChanged != null) {
                  onChanged!.call(value);
                }
              },
        items: options.map((option) {
          return DropdownMenuItem<OptionValue>(
            value: option,
            child: Text(option.nombre ?? ''),
          );
        }).toList(),
        disabledHint: Text(
          initialValue?.nombre ?? hintText,
          style: const TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

abstract class DropdownElement {
  // Definición de una interfaz implícita
  String get value;
  int? get id;

  @override
  String toString() {
    // TODO: implement toString
    return value;
  }
}

class Binding<T> {
  const Binding({required this.set, required this.get});
  final void Function(T?) set;
  final T? Function() get;
}

class CustomGenericDropdown<Element extends DropdownElement>
    extends StatefulWidget {
  const CustomGenericDropdown({
    required this.label,
    required this.options,
    required this.selectedValue,
    this.isSearchable = false,
    this.isRequired = false,
    this.isReadOnly = false,
    this.readOnly = false,
    super.key,
  });
  final String label;
  final List<Element> options;
  final bool isSearchable;
  final Binding<Element> selectedValue;
  final bool isRequired;

  @Deprecated('Use readOnly instead to disable the dropdown')
  final bool isReadOnly;

  final bool readOnly;

  @override
  CustomGenericDropdownState createState() => CustomGenericDropdownState();
}

class CustomGenericDropdownState<Element extends DropdownElement>
    extends State<CustomGenericDropdown<Element>> {
  List<Element> filteredOptions = [];

  @override
  void initState() {
    super.initState();
    filteredOptions = widget.options;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50,
                  child: DropdownButtonFormField<Element>(
                    value: widget.selectedValue.get(),
                    isExpanded: true,
                    onTap: widget.readOnly ? null : () {},
                    // hint: Text(
                    //   widget.label,
                    //   style: const TextStyle(
                    //     color: AppTheme.primaryText,
                    //     fontSize: 16,
                    //   ),
                    // ),
                    decoration: InputDecoration(
                      labelText: widget.label,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.alternateColor,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: AppTheme.alternateColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: widget.readOnly
                        ? null
                        : (Element? option) =>
                            {widget.selectedValue.set(option)},
                    items: filteredOptions.map((Element option) {
                      return DropdownMenuItem<Element>(
                        value: option,
                        child: Text(option.value),
                      );
                    }).toList(),
                    disabledHint: Text(
                      widget.selectedValue.get()?.value ?? widget.label,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                if (widget.isSearchable &&
                    (!widget.readOnly || !widget.isReadOnly))
                  _buildSearchBar(),
              ],
            ),
          ),
          if (widget.isRequired)
            const Padding(
              padding: EdgeInsets.only(left: 6, bottom: 16),
              child: Text(
                '*',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar...',
          border: OutlineInputBorder(),
        ),
        onChanged: (query) {
          setState(() {
            filteredOptions = widget.options
                .where(
                  (option) =>
                      option.value.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
          });
        },
      ),
    );
  }
}
