import 'package:app_admin/configs/config.dart';
import 'package:app_admin/providers/menu_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';


const Map<int, List<dynamic>> itemList = {
  0: ['Dashboard', LineIcons.pieChart],
  1: ['Categories', CupertinoIcons.grid],
  2: ['Quizzes', LineIcons.list],
  3: ['Questions', LineIcons.lightbulb],
  4: ['Featured', LineIcons.bomb],
  5: ['Users', LineIcons.usersCog],
  6: ['Purchases', LineIcons.dollarSign],
  7: ['Notifications', LineIcons.bell],
  8: ['Ads', CupertinoIcons.money_dollar],
  9: ['Settings', CupertinoIcons.settings],
  10: ['License', LineIcons.key],
};

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0.5,
      backgroundColor: Theme.of(context).primaryColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(10),
              height: 130,
              child: Center(
                child: Text(
                  Config.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: itemList.length,
              itemBuilder: (BuildContext context, int index) {
                String title = itemList[index]![0];
                IconData icon = itemList[index]![1];
                return DrawerListTile(
                  title: title,
                  icon: icon,
                  index: index,
                  scaffoldKey: scaffoldKey,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends ConsumerWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.icon,
    required this.index,
    required this.scaffoldKey,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final int index;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuIndex = ref.watch(menuIndexProvider);
    bool selected = menuIndex == index;
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        tileColor: selected ? Colors.white : Colors.transparent,
        horizontalTitleGap: 0.0,
        onTap: () => onMenuTap(context, ref, menuIndex, index, scaffoldKey),
        leading: Icon(
          icon,
          size: 20,
          color: selected ? Theme.of(context).primaryColor : Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(color: selected ? Theme.of(context).primaryColor : Colors.white, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
