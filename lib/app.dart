import 'dart:ui';
import 'package:app_admin/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'blocs/ads_bloc.dart';
import 'blocs/settings_bloc.dart';
import 'configs/config.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsBloc>(create: (context) => SettingsBloc()),
        ChangeNotifierProvider<AdsBloc>(create: (context) => AdsBloc()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Admin Panel',
          scrollBehavior: TouchAndMouseScrollBehavior(),
          theme: ThemeData(
            primaryColor: Config.primaryColor,
            scaffoldBackgroundColor: Config.bgColor,
            canvasColor: Config.secondaryColor,
            useMaterial3: false,
            fontFamily: 'Poppins',
          ),
          home: const SplashScreen(),
      ),
    );
  }
}



class TouchAndMouseScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}