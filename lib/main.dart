// import 'package:scoped_model/scoped_model.dart';
// import 'core/app_model.dart';
import 'core/app_info.dart';
// import 'core/pages/splash_page.dart';
// import 'theme.dart';
import 'routes.dart' as routing;
import 'auth_service.dart' as auth;

//////////////////
//////////////////
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

import 'core/app_model.dart';
import 'listViewHeaderPage.dart';
import 'listViewPage.dart';
import 'tabbedPage.dart';
import 'theme.dart';

final GlobalKey<NavigatorState> _navKey = new GlobalKey<NavigatorState>();

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  MyApp();

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
              home: LandingPage(),
              routes: routing.buildRoutes(authService),
              onGenerateRoute: routing.buildGenerator(),
            ),
          );
        },
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  LandingPageState createState() => LandingPageState();
}

class LandingPageState extends State<LandingPage> {
  @override
  initState() {
    super.initState();

    textControlller = TextEditingController(text: 'text');
  }

  bool switchValue = false;
  double sliderValue = 0.5;

  TextEditingController textControlller;

  _switchPlatform(BuildContext context) {
    if (isMaterial) {
      PlatformProvider.of(context).changeToCupertinoPlatform();
    } else {
      PlatformProvider.of(context).changeToMaterialPlatform();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        title: Text('Flutter Platform Widgets'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'Primary concept of this package is to use the same widgets to create iOS (Cupertino) or Android (Material) looking apps rather than needing to discover what widgets to use.'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'This approach is best when both iOS and Android apps follow the same design in layout and navigation, but need to look as close to native styling as possible.'),
            ),
            Divider(),
            SectionHeader(title: '1. Change Platform'),
            PlatformButton(
              child: PlatformText('Switch Platform'),
              onPressed: () => _switchPlatform(context),
            ),
            PlatformWidget(
              android: (_) => Text('Currently showing Material'),
              ios: (_) => Text('Currently showing Cupertino'),
            ),
            Text('Scaffold: PlatformScaffold'),
            Text('AppBar: PlatformAppBar'),
            Divider(),
            SectionHeader(title: '2. Basic Widgets'),
            PlatformText(
              'PlatformText will uppercase for Material only',
              textAlign: TextAlign.center,
            ),
            PlatformButton(
              child: PlatformText('PlatformButton'),
              onPressed: () {},
            ),
            PlatformButton(
              child: PlatformText('Platform Flat Button'),
              onPressed: () {},
              androidFlat: (_) => MaterialFlatButtonData(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformIconButton(
                androidIcon: Icon(Icons.home),
                iosIcon: Icon(CupertinoIcons.home),
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformSwitch(
                value: switchValue,
                onChanged: (bool value) => setState(() => switchValue = value),
              ),
            ),
            PlatformSlider(
              value: sliderValue,
              onChanged: (double newValue) {
                setState(() {
                  sliderValue = newValue;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformTextField(
                controller: textControlller,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: PlatformCircularProgressIndicator(),
            ),
            Divider(),
            SectionHeader(title: '3. Dialogs'),
            PlatformButton(
              child: PlatformText('Show Dialog'),
              onPressed: () => _showExampleDialog(),
            ),
            Divider(),
            SectionHeader(title: '4. Navigation'),
            PlatformButton(
              child: PlatformText('Open Tabbed Page'),
              onPressed: () => _openPage((_) => new TabbedPage()),
            ),
            Divider(),
            SectionHeader(title: '5. Advanced'),
            PlatformButton(
              child: PlatformText('Page with ListView'),
              onPressed: () => _openPage((_) => new ListViewPage()),
            ),
            PlatformWidget(
              android: (_) => Container(), //this is for iOS only
              ios: (_) => PlatformButton(
                child: PlatformText('iOS Page with Colored Header'),
                onPressed: () => _openPage((_) => new ListViewHeaderPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _openPage(WidgetBuilder pageToDisplayBuilder) {
    Navigator.push(
      context,
      platformPageRoute(
        builder: pageToDisplayBuilder,
      ),
    );
  }

  _showExampleDialog() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Alert'),
        content: Text('Some content'),
        actions: <Widget>[
          PlatformDialogAction(
            android: (_) => MaterialDialogActionData(),
            ios: (_) => CupertinoDialogActionData(),
            child: PlatformText('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          PlatformDialogAction(
            child: PlatformText('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    @required this.title,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0),
      ),
    );
  }
}

class Divider extends StatelessWidget {
  const Divider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      color: new Color(0xff999999),
      margin: const EdgeInsets.symmetric(vertical: 12.0),
    );
  }
}

///////////////
//////////////////
//////////////////
//////////////////
//////////////////
//////////////////

// final GlobalKey<NavigatorState> _navKey = new GlobalKey<NavigatorState>();

// void main() {
//   //TODO fill these out for your app
//   var appInfo = new AppInfo(
//       appName: 'Flutter Auth Starter',
//       appVersion: "0.0.1",
//       appIconPath: "assets/icons/appIcon.jpg",
//       avatarDefaultAppIconPath: "assets/icons/profileIcon.png",
//       applicationLegalese: '',
//       privacyPolicyUrl: "http://yourPrivacyPolicyUrl",
//       termsOfServiceUrl: "http://yourTermsOfServiceUrl");

//   // var authService = auth.createMockedAuthService();
//   var authService = auth.createFirebaseAuthService();

//   var app = ScopedModel<AppModel>(
//       model: AppModel(appInfo: appInfo, authService: authService),
//       child: MaterialApp(
//           title: appInfo.appName,
//           navigatorKey: _navKey,
//           debugShowCheckedModeBanner: false,
//           theme: theme(),
//           home: Splash(),
//           routes: routing.buildRoutes(authService),
//           onGenerateRoute: routing.buildGenerator()));

//   //This is so that we can route to the splash screen when the user state changes and is signed out
//   //If the user has changed and is signed in route to the home page
//   authService.authUserChanged.addListener(() {
//     app.model.refreshAuthUser().then((model) {
//       if (model.hasChanged) {
//         if (model.isValidUser) {
//           _navKey.currentState.pushNamedAndRemoveUntil('/home', (_) => false);
//         } else {
//           _navKey.currentState.pushNamedAndRemoveUntil('/', (_) => false);
//         }
//       }
//     });
//   });

//   runApp(app);
// }
