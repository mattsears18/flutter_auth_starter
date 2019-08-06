import 'routes.dart' as routing;
import 'auth_service.dart' as auth;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'core/app_info.dart';
import 'core/app_model.dart';
import 'theme.dart';
import 'core/pages/splash_page.dart';

final GlobalKey<NavigatorState> _navKey = new GlobalKey<NavigatorState>();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final appInfo = new AppInfo(
      appName: 'Flutter Auth Starter',
      appVersion: "0.0.1",
      appIconPath: "assets/icons/appIcon.jpg",
      avatarDefaultAppIconPath: "assets/icons/profileIcon.png",
      applicationLegalese: '',
      privacyPolicyUrl: "http://yourPrivacyPolicyUrl",
      termsOfServiceUrl: "http://yourTermsOfServiceUrl");

  final authService = auth.createFirebaseAuthService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          builder: (_) => AppModel(appInfo: appInfo, authService: authService),
        ),
      ],
      child: Consumer<AppModel>(
        builder: (context, appModel, _) {
          print('change!');

          return PlatformProvider(
            builder: (BuildContext context) => PlatformApp(
              title: appInfo.appName,
              navigatorKey: _navKey,
              debugShowCheckedModeBanner: false,
              android: (_) => new MaterialAppData(theme: MainTheme.material()),
              ios: (_) => new CupertinoAppData(theme: MainTheme.cupertino()),
              supportedLocales: const [Locale('en')],
              localizationsDelegates: [
                DefaultMaterialLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              home: SplashPage(),
              routes: routing.buildRoutes(authService),
              onGenerateRoute: routing.buildGenerator(),
            ),
          );
        },
      ),
    );
  }
}
