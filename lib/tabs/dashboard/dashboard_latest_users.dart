import 'package:app_admin/utils/user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:line_icons/line_icons.dart';

import '../../models/user.dart';
import '../../providers/menu_provider.dart';
import '../../providers/user_role_provider.dart';
import '../../services/firebase_service.dart';
import '../../utils/user_info_dialog.dart';

final dashboardUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final List<UserModel> users = await FirebaseService().getLatestUsers(5);
  return users;
});

class DashboardLatestUsers extends ConsumerWidget {
  const DashboardLatestUsers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(dashboardUsersProvider);
    return Container(
      padding: const EdgeInsets.all(25),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey.shade300)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Latest Users',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                  onPressed: () {
                    ref.read(menuIndexProvider.notifier).update((state) => 5);
                    ref.read(pageControllerProvider.notifier).state.jumpToPage(5);
                  },
                  child: const Text('View All'))
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15, bottom: 15),
            child: users.when(
              data: (data) {
                return Column(
                  children: data.map((user) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5),
                      leading: GetUserAvatar(imageUrl: user.imageurl, assetString: user.avatarString),
                      title: Text(user.name.toString()),
                      subtitle: Text('Points: ${user.points}'),
                      trailing: CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.grey.shade300,
                        child: IconButton(
                          icon: const Icon(LineIcons.eyeAlt),
                          alignment: Alignment.center,
                          iconSize: 16,
                          onPressed: () => showDialog(context: context, builder: (context) => userInfoDialog(context, user, hasAccess(ref))),
                        ),
                      ),
                    );
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
