import 'package:app_admin/models/purchases.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../providers/menu_provider.dart';
import '../../services/firebase_service.dart';

final dashboardPurchasesProvider = FutureProvider<List<PurchaseModel>>((ref) async {
  final List<PurchaseModel> purchases = await FirebaseService().getLatestPurchases(5);
  return purchases;
});

class DashboardPurchases extends ConsumerWidget {
  const DashboardPurchases({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final purchases = ref.watch(dashboardPurchasesProvider);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.grey.shade300,
        )
      ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Purchases',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                  onPressed: () {
                    ref.read(menuIndexProvider.notifier).update((state) => 6);
                    ref.read(pageControllerProvider.notifier).state.jumpToPage(6);
                  },
                  child: const Text('View All'))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: purchases.when(
              skipError: true,
              data: (data) {
                return Column(
                  children: data.map((purchase) {
                    return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 5),
                        title: Text(purchase.productTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: Text(purchase.price, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),),
                        subtitle: Wrap(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.grey.shade300,
                              child: const Icon(LineIcons.user, size: 12,),
                            ),
                            const SizedBox(width: 10,),
                            Text(purchase.userName),
                            const SizedBox(width: 10,),
                            Text('(${purchase.platform})', style: const TextStyle(color: Colors.blueAccent),)
                          ],
                        ),);
                  }).toList(),
                );
              },
              error: (a, b) => Container(),
              loading: () => Container(),
            ),
          )
        ],
      ),
    );
  }
}