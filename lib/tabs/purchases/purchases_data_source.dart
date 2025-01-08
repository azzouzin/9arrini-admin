import 'package:app_admin/models/purchases.dart';
import 'package:flutter/material.dart';
import '../../services/app_service.dart';

class PurchasesDataSource extends DataTableSource {
  final List<PurchaseModel> purchases;
  final BuildContext context;
  PurchasesDataSource(this.context, this.purchases);

  @override
  DataRow getRow(int index) {
    final PurchaseModel purchase = purchases[index];

    return DataRow.byIndex(index: index, cells: [
      DataCell(_userInfo(purchase)),
      DataCell(_plan(purchase)),
      DataCell(_price(purchase)),
      DataCell(_platform(purchase)),
      DataCell(_purchaseDate(purchase)),
    ]);
  }

  static Text _platform(PurchaseModel purchase) => Text(purchase.platform);

  static Text _purchaseDate(PurchaseModel purchase) {
    final String date = AppService.getDateTime(purchase.purchaseAt);
    return Text(date);
  }

  ListTile _userInfo(PurchaseModel purchase) {
    return ListTile(
      horizontalTitleGap: 10,
      contentPadding: const EdgeInsets.all(0),
      title: Text(purchase.userName),
      // leading: getUserImageByUrl(imageUrl: purchase.userImageUrl),
      subtitle: Text(purchase.userEmail),
    );
  }

  Text _plan(PurchaseModel purchase) {
    return Text(
      purchase.productTitle,
    );
  }

  static Text _price(PurchaseModel purchase) {
    return Text(purchase.price);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => purchases.length;

  @override
  int get selectedRowCount => 0;
}
