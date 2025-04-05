import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logging/logging.dart';
import 'package:sgem/config/theme/app_theme.dart';
import 'package:sgem/shared/controller/maestro_controller.dart';
import 'package:sgem/shared/modules/option.value.dart';

class MaestraAppDropdown<E extends OptionValue> extends StatelessWidget {
  const MaestraAppDropdown({
    required this.label,
    required this.options,
    required this.controller,
    this.isRequired = false,
    this.readOnly = false,
    this.hint,
    this.disabledHint,
    this.hasAllOption = false,
    this.filterOptions,
    super.key,
  });

  final RxList<OptionValue> Function(MaestraController ctr) options;
  final bool hasAllOption;

  final void Function(List<OptionValue>)? filterOptions;

  final bool isRequired;
  final String? hint;
  final String label;
  final String? disabledHint;
  final bool readOnly;
  // final RxnInt? value;

  final DropdownController<E> controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _Dropdown(
              options: options,
              // value: value,
              controller: controller,
              label: label,
              readOnly: readOnly,
              hint: hint,
              disabledHint: disabledHint,
              filterOptions: filterOptions,
              hasAllOption: hasAllOption,
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
  }
}

class DropdownController<E extends OptionValue> extends ValueNotifier<int?> {
  DropdownController([int? value = null]) : super(value);

  List<E>? _options;
  set options(List<E>? value) {
    _options = value;
  }

  E? get selectedOption {
    if (_options == null || value == null) {
      return null;
    }

    return _options!.firstWhere((e) => e.key == value);
  }

  void clear() {
    value = null;
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.options,
    // required this.value,
    required this.controller,
    required this.label,
    this.readOnly = false,
    this.hint,
    this.disabledHint,
    this.hasAllOption = false,
    this.filterOptions,
  });

  final List<OptionValue> Function(MaestraController ctr) options;

  final bool hasAllOption;
  final void Function(List<OptionValue>)? filterOptions;

  final DropdownController controller;

  final String? hint;
  final String label;
  final String? disabledHint;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final decoration = InputDecoration(
      labelText: label,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );

    final hintText = hint != null
        ? Text(
            hint!,
            style: const TextStyle(
              color: AppTheme.primaryText,
              fontSize: 16,
            ),
          )
        : null;

    final disabledHint = this.disabledHint != null
        ? Text(
            this.disabledHint!,
            style: const TextStyle(color: Colors.grey),
          )
        : null;

    final controller = Get.find<MaestraController>();

    return Obx(
      () {
        if (controller.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final options = [...this.options(controller)];
        Logger('Dropdown').info('[$label] Options: ${options.length}');

        if (hasAllOption) {
          options.insert(
            0,
            const OptionValue(
              key: -1,
              nombre: 'Todos',
            ),
          );
        }

        if (filterOptions != null && !readOnly) {
          filterOptions!(options);
        }

        this.controller.options = options;

        final onChanged = readOnly
            ? null
            : hasAllOption
                ? (int? value) {
                    this.controller.value = value == -1 ? null : value;
                  }
                : (int? value) {
                    this.controller.value = value;
                    // this
                    //     .onChanged
                    //     ?.call(options.firstWhere((e) => e.key == value));
                  };

        final menus = options
            .map(
              (option) => DropdownMenuItem(
                value: option.key,
                child: Text(option.nombre ?? 'N/A'),
              ),
            )
            .toList();

        return ValueListenableBuilder(
          valueListenable: this.controller,
          builder: (context, value, child) {
            if (value != null && !options.map((e) => e.key).contains(value)) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return DropdownButtonFormField<int>(
              value: value ?? (hasAllOption ? -1 : null),
              isExpanded: true,
              hint: hintText,
              decoration: decoration,
              onChanged: onChanged,
              items: menus,
              disabledHint: disabledHint,
            );
          },
        );
      },
    );
  }
}
