import 'package:app_admin/components/responsive.dart';
import 'package:app_admin/models/purchases.dart';
import 'package:app_admin/tabs/purchases/sort_purchases.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../components/card_wrapper.dart';
import '../../configs/constants.dart';
import 'purchases_data_source.dart';

final purchasesQueryProvider = StateProvider<Query>((ref) {
  final query = FirebaseFirestore.instance.collection('purchases').orderBy('purchase_at', descending: true);
  return query;
});

final sortByPurchasesTextProvider = StateProvider<String>((ref) => Constants.sortByPurchases.entries.first.value);

final List<String> _columns = [
  'User',
  'Product',
  'Price',
  'Platform',
  'Purchased At',
];

const int _itemsPerPage = 10;

class Purchases extends ConsumerWidget {
  const Purchases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CardWrapper(
      child: FirestoreQueryBuilder(
        pageSize: _itemsPerPage,
        query: ref.watch(purchasesQueryProvider),
        builder: (context, snapshot, _) {
          // if (snapshot.isFetching) return const LoadingAnimation();

          List<PurchaseModel> purchases = [];
          purchases = snapshot.docs.map((e) => PurchaseModel.fromFirestore(e)).toList();
          DataTableSource source = PurchasesDataSource(context, purchases);

          return PaginatedDataTable2(
            header: Text('Purchase History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            empty: const Center(child: Text('No History Found')),
            renderEmptyRowsInTheEnd: false,
            rowsPerPage: _itemsPerPage - 1,
            source: source,
            minWidth: 1200,
            wrapInCard: false,
            horizontalMargin: 20,
            columnSpacing: 20,
            fit: FlexFit.tight,
            lmRatio: 2,
            dataRowHeight: Responsive.isMobile(context) ? 90 : 70,
            onPageChanged: (_) => snapshot.fetchMore(),
            columns: _columns.map((e) => DataColumn(label: Text(e))).toList(),
            actions: [
              SortPurchasesButton(ref: ref),
            ],
          );
        },
      ),
    );
  }
}
