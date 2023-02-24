import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_elemental/flutter_elemental.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart'
    show BarcodeFormat;
import 'package:vouchervault/vouchers/index.dart';

final Map<VoucherCodeType, Barcode> _codeTypeMap = {
  VoucherCodeType.AZTEC: Barcode.aztec(minECCPercent: 5),
  VoucherCodeType.CODE128: Barcode.code128(),
  VoucherCodeType.CODE39: Barcode.code39(),
  VoucherCodeType.EAN13: Barcode.ean13(),
  VoucherCodeType.PDF417: Barcode.pdf417(),
  VoucherCodeType.QR: Barcode.qrCode(),
};
final barcodeFromCodeType = _codeTypeMap.lookup;
final barcodeFromCodeTypeJson = codeTypeFromJson.c(barcodeFromCodeType);

final Map<BarcodeFormat, VoucherCodeType> _barcodeFormatMap = {
  BarcodeFormat.aztec: VoucherCodeType.AZTEC,
  BarcodeFormat.code128: VoucherCodeType.CODE128,
  BarcodeFormat.code39: VoucherCodeType.CODE39,
  BarcodeFormat.ean13: VoucherCodeType.EAN13,
  BarcodeFormat.pdf417: VoucherCodeType.PDF417,
  BarcodeFormat.qrCode: VoucherCodeType.QR,
};
VoucherCodeType codeTypeFromFormat(BarcodeFormat format) =>
    _barcodeFormatMap.lookup(format).getOrElse(() => VoucherCodeType.CODE128);

final codeTypeValueFromFormat = codeTypeFromFormat.c(codeTypeToJson);
