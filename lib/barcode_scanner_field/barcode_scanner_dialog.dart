import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:functional_widget_annotation/functional_widget_annotation.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:vouchervault/app/app.dart';

part 'barcode_scanner_dialog.g.dart';

final _key = GlobalKey(debugLabel: "QR");

ValueNotifier<Option<QRViewController>> _useController(bool isIos) {
  final controller = useState<Option<QRViewController>>(none());

  useEffect(() {
    return controller.value.fold(
      () => () {},
      (c) => () => c.dispose(),
    );
  }, [controller.value]);

  useReassemble(() {
    if (isIos) {
      controller.value.map((c) => c.resumeCamera());
    } else {
      controller.value.map((c) => c.pauseCamera());
    }
  });

  return controller;
}

@hwidget
Widget barcodeScannerDialog(
  BuildContext context, {
  required void Function(BarcodeFormat, String) onScan,
}) {
  final theme = Theme.of(context);
  final controller = _useController(theme.platform == TargetPlatform.iOS);

  useEffect(() {
    return controller.value.fold(() => () {}, (c) {
      final sub = c.scannedDataStream
          .where((d) => d.code != null)
          .first
          .asStream()
          .listen((data) => onScan(data.format, data.code!));
      return () => sub.cancel();
    });
  }, [controller.value]);

  return AnnotatedRegion(
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Expanded(
            child: QRView(
              key: _key,
              onQRViewCreated: (c) => controller.value = some(c),
              // formatsAllowed: BarcodeFormat.values,
            ),
          ),
          Material(
            color: Colors.grey.shade800,
            child: Padding(
              padding: EdgeInsets.all(AppTheme.space3),
              child: Row(
                children: [
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      controller.value.map((c) => c.toggleFlash());
                    },
                    child: Text('Toggle flash'),
                  ),
                  SizedBox(width: AppTheme.space3),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: theme.canvasColor,
                      onPrimary: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
