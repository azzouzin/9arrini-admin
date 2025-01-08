import 'package:app_admin/components/custom_dialogs.dart';
import 'package:app_admin/configs/config.dart';
import 'package:app_admin/models/user.dart';
import 'package:app_admin/pages/change_password.dart';
import 'package:app_admin/pages/sign_in.dart';
import 'package:app_admin/providers/categories_provider.dart';
import 'package:app_admin/providers/user_data_provider.dart';
import 'package:app_admin/providers/user_role_provider.dart';
import 'package:app_admin/tabs/ad_settings.dart';
import 'package:app_admin/tabs/categories/categories.dart';
import 'package:app_admin/tabs/license_tab.dart';
import 'package:app_admin/tabs/purchases/purchases.dart';
import 'package:app_admin/tabs/questions.dart';
import 'package:app_admin/tabs/settings.dart';
import 'package:app_admin/tabs/users.dart';
import 'package:app_admin/utils/next_screen.dart';
import 'package:app_admin/utils/user_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import '../blocs/ads_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../components/responsive.dart';
import '../components/side_menu.dart';
import '../providers/menu_provider.dart';
import '../services/auth_service.dart';
import '../tabs/dashboard/dashboard.dart';
import '../tabs/featured_categories.dart';
import '../tabs/notifications/notifications.dart';
import '../tabs/quizzes.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _list = <Widget>[
    const DashboardScreen(),
    const Categories(),
    const Quizzes(),
    const Questions(),
    const FeaturedCategories(),
    const Users(),
    const Purchases(),
    const Notifications(),
    const AdSettings(),
    const Settings(),
    const LicenseTab(),
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero).then((value) {
      ref.read(categoriesProvider.notifier).getCategories();
      if(!mounted) return;
      context.read<SettingsBloc>().getSettingsData();
      context.read<AdsBloc>().getAdsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageController = ref.watch(pageControllerProvider);
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideMenu(
        scaffoldKey: _scaffoldKey,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //it takes 1/6 part of the screen
          Visibility(
            visible: Responsive.isDesktop(context),
            child: Expanded(
                child: SideMenu(
              scaffoldKey: _scaffoldKey,
            )),
          ),
          Expanded(
            // It takes 5/6 part of the screen
            flex: 5,
            child: Column(
              children: [
                _AppBar(scaffoldKey: _scaffoldKey),
                Expanded(
                  child: PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: pageController,
                    children: _list,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends ConsumerWidget {
  const _AppBar({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserModel? user = ref.watch(userDataProvider);
    final UserRoles userRole = ref.watch(userRoleProvider);
    final String userRoleText = userRole == UserRoles.admin
        ? 'Admin'
        : userRole == UserRoles.editor
            ? 'Editor'
            : 'Tester';

    final double leadingWidth = Responsive.isDesktop(context) ? 20.0 : 50.0;

    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      centerTitle: false,
      titleSpacing: 0,
      toolbarHeight: 65,
      leadingWidth: leadingWidth,
      actionsIconTheme: IconThemeData(color: Colors.grey.shade900),
      toolbarTextStyle: TextStyle(color: Colors.grey.shade900, fontSize: 16),
      title: Text(
        '${Config.appName} - Admin Panel ',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      leading: _buildMenuButton(context),
      actions: [
        PopupMenuButton(
          iconColor: Colors.blue,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GetUserAvatar(
                imageUrl: user?.imageurl,
                assetString: user?.avatarString,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    user != null ? user.name.toString() : "John Doe",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    userRoleText,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              const SizedBox(width: 5),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
          itemBuilder: (context) {
            return <PopupMenuItem>[
              PopupMenuItem(
                enabled: user != null,
                value: 'password',
                child: const Text('Change Password'),
              ),
              PopupMenuItem(
                enabled: user != null,
                value: 'logout',
                child: const Text('Logout'),
              )
            ];
          },
          onSelected: (value) async {
            if (value == 'password') {
              CustomDialogs.openResponsiveDialog(context, widget: const ChangePassword());
            } else if (value == 'logout') {
              await AuthService().adminLogout();
              ref.invalidate(userDataProvider);
              ref.invalidate(userRoleProvider);
              if (!context.mounted) return;
              NextScreen().nextScreenReplace(context, const SignInPage());
            }
          },
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  Visibility _buildMenuButton(context) {
    return Visibility(
      visible: Responsive.isMobile(context) || Responsive.isTablet(context),
      child: IconButton(
        onPressed: () {
          if (!scaffoldKey.currentState!.isDrawerOpen) {
            scaffoldKey.currentState!.openDrawer();
          }
        },
        icon: Icon(Icons.menu, color: Colors.grey.shade900,),
      ),
    );
  }
}
