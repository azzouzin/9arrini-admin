import 'package:app_admin/tabs/dashboard/dashboard_card.dart';
import 'package:app_admin/providers/dashboard_providers.dart';
import 'package:app_admin/services/app_service.dart';
import 'package:app_admin/tabs/dashboard/dashboard_purchases.dart';
import 'package:app_admin/tabs/dashboard/dashboard_latest_users.dart';
import 'package:app_admin/tabs/dashboard/dashboard_top_users.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import '../../components/responsive.dart';
import 'purchase_bar_chart.dart';
import 'user_bar_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(30),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                crossAxisCount: AppService.getCrossAxisCount(context),
                childAspectRatio: 2.5,
              ),
              children: [
                DashboardCard(info: 'Total Users', count: ref.watch(usersCountProvider).value ?? 0, icon: LineIcons.userCheck),
                DashboardCard(info: 'Total Categories', count: ref.watch(categoriessCountProvider).value ?? 0, icon: CupertinoIcons.grid),
                DashboardCard(info: 'Total Quizzes', count: ref.watch(quizzesCountProvider).value ?? 0, icon: LineIcons.list),
                DashboardCard(info: 'Total Questions', count: ref.watch(questionsCountProvider).value ?? 0, icon: LineIcons.lightbulb),
                DashboardCard(info: 'Total Purchases', count: ref.watch(purchasesCountProvider).value ?? 0, icon: LineIcons.dollarSign),
                DashboardCard(info: 'Total Notifications', count: ref.watch(notificationsCountProvider).value ?? 0, icon: LineIcons.bell),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: OtherDashboardTabs(),
            ),
          ],
        ),
      ),
    );
  }
}

class OtherDashboardTabs extends StatelessWidget {
  const OtherDashboardTabs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Responsive.isDesktop(context)) {
      return const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(flex: 1, child: Column(children: [UserBarChart(), SizedBox(height: 20), DashboardPurchases()])),
          SizedBox(width: 20),
          Flexible(
            flex: 1,
            child: Column(
              children: [PurchaseBarChart(), SizedBox(height: 20), DashboardLatestUsers()],
            ),
          ),
          SizedBox(width: 20),
          Flexible(flex: 1, child: DashboardTopUsers())
        ],
      );
    } else {
      return const Column(
        children: [
          UserBarChart(),
          SizedBox(height: 20),
          PurchaseBarChart(),
          SizedBox(height: 20),
          DashboardTopUsers(),
          SizedBox(height: 20),
          DashboardPurchases(),
          SizedBox(height: 20),
          DashboardLatestUsers(),
        ],
      );
    }
  }
}
