import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:fpdt/fpdt.dart';
import 'package:fpdt/option.dart' as O;
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:intl/intl.dart';
import 'package:vouchervault/app/app.dart';
import 'package:vouchervault/barcode_scanner_field/barcode_scanner_field.dart';
import 'package:vouchervault/lib/barcode.dart' as barcode;
import 'package:vouchervault/lib/milliunits.dart' as millis;
import 'package:vouchervault/lib/option.dart';
import 'package:vouchervault/models/voucher.dart'
    show Voucher, VoucherCodeType, VoucherColor;
import 'package:vouchervault/models/voucher.dart' as V;

part 'voucher_form.g.dart';

@swidget
Widget voucherForm(
  BuildContext context, {
  required GlobalKey<FormBuilderState> formKey,
  required Voucher initialValue,
}) {
  final theme = Theme.of(context);
  final initialFormValue = initialValue.toFormValue();

  return FormBuilder(
    key: formKey,
    initialValue: initialFormValue,
    child: Column(
      children: [
        const SizedBox(height: 4),
        FormBuilderTextField(
          autofocus: true,
          name: 'description',
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Description',
          ),
          validator: FormBuilderValidators.required(),
        ),
        SizedBox(height: AppTheme.space3),
        FormBuilderField<String>(
          name: 'code',
          valueTransformer: optionOfString.c(O.toNullable),
          validator: FormBuilderValidators.required(),
          builder: (field) => BarcodeScannerField(
            labelText: 'Code',
            onChange: field.didChange,
            errorText: optionOfString(field.errorText),
            initialValue: field.value ?? '',
            barcodeType: O
                .fromNullable(formKey.currentState!.fields['codeType'])
                .p(O.map((f) => f.value as String))
                .p(O.alt(() => optionOfString(initialFormValue['codeType'])))
                .p(O.flatMap(barcode.fromCodeTypeJson)),
            onScan: O.some((f) => O
                .fromNullable(formKey.currentState!.fields['codeType'])
                .p(O.map((f) => f.didChange))
                .p(O.map((didChange) =>
                    didChange(barcode.codeTypeValueFromFormat(f))))),
          ),
        ),
        FormBuilderChoiceChip(
          name: 'codeType',
          alignment: WrapAlignment.spaceEvenly,
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          visualDensity: VisualDensity.compact,
          options: VoucherCodeType.values
              .map((t) => FormBuilderChipOption(
                    value: V.codeTypeToJson(t),
                    child: Text(V.codeTypeLabel(t)),
                  ))
              .toList(),
          validator: FormBuilderValidators.required(),
        ),
        SizedBox(height: AppTheme.space3),
        FormBuilderDateTimePicker(
          name: 'expires',
          inputType: InputType.date,
          format: DateFormat('d/M/y'),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
          resetIcon: null,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: 'Expires',
            suffixIcon: IconButton(
              onPressed: () =>
                  formKey.currentState!.fields['expires']?.didChange(null),
              icon: const Icon(Icons.close),
            ),
          ),
          valueTransformer: O
              .fromNullableWith<DateTime>()
              .c(O.map((d) => d.toString()))
              .c(O.toNullable),
        ),
        FormBuilderSwitch(
          name: 'removeOnceExpired',
          title: Text(
            'Remove once expired',
            style: theme.textTheme.bodyText1,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: AppTheme.space3),
        FormBuilderField<int>(
          name: 'balanceMilliunits',
          builder: (field) => TextFormField(
            initialValue: millis.toString(field.value).p(O.getOrElse(() => '')),
            onChanged: millis.fromString.c(O.toNullable).c(field.didChange),
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Balance',
            ),
          ),
        ),
        SizedBox(height: AppTheme.space3),
        FormBuilderTextField(
          name: 'notes',
          valueTransformer: optionOfString.c(O.toNullable),
          minLines: 2,
          maxLines: null,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Notes',
          ),
        ),
        SizedBox(height: AppTheme.space3),
        FormBuilderChoiceChip(
          name: 'color',
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
          alignment: WrapAlignment.spaceAround,
          options: VoucherColor.values
              .map((c) => FormBuilderChipOption(
                    value: V.colorToJson(c),
                    child: Material(
                      elevation: 2,
                      color: V.color(c),
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        height: AppTheme.rem(1.2),
                        width: AppTheme.rem(1.2),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    ),
  );
}
