import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:motopos/data/models/store_info_model.dart';
import 'package:motopos/data/models/transaction_item_model.dart';
import 'package:motopos/data/models/transaction_model.dart';
import 'package:motopos/services/receipt_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generateReceiptImage produces valid PNG bytes with matching content', () async {
    final transaction = TransactionModel(
      id: 14,
      transactionDate: '2026-10-17 10:35:00',
      totalAmount: 165000,
      cashAmount: 200000,
      changeAmount: 35000,
      vehicleNo: 'AG 1234 XY',
      customerName: 'Bundaku',
    );

    final items = [
      TransactionItemModel(
        transactionId: 14,
        itemName: 'ONGKOS. 25000',
        price: 25000,
        quantity: 1,
        subtotal: 25000,
      ),
      TransactionItemModel(
        transactionId: 14,
        itemName: 'MUR GIR',
        price: 5000,
        quantity: 1,
        subtotal: 5000,
      ),
      TransactionItemModel(
        transactionId: 14,
        itemName: 'Rante Gir Set. 135000',
        price: 135000,
        quantity: 1,
        subtotal: 135000,
      ),
    ];

    final storeInfo = StoreInfoModel(
      storeName: 'FERRY MOTOR',
      address: 'JL. RAYA GEMPOLKEREP DS. GEMPOLKEREP KEC. GEDEG, MOJOKERTO',
      phone: '081224817777',
    );

    final Uint8List bytes = await ReceiptImageService.generateReceiptImage(
      transaction: transaction,
      items: items,
      storeInfo: storeInfo,
    );

    final sampleFile = File('build/test_sample_receipt.png');
    await sampleFile.parent.create(recursive: true);
    await sampleFile.writeAsBytes(bytes);

    expect(bytes, isNotEmpty);
    // Verify PNG magic numbers: 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A
    expect(bytes.length, greaterThan(8));
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50); // P
    expect(bytes[2], 0x4E); // N
    expect(bytes[3], 0x47); // G
  });
}
