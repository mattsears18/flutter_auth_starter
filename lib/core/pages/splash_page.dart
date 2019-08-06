import 'dart:async';

import 'package:async_loader/async_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_base/flutter_auth_base.dart';
import 'package:flutter_auth_starter/src/pages/home_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../common/dialog.dart';
import '../widgets/tablet_aware_scaffold.dart';
import '../widgets/screen_logo.dart';
import '../widgets/progress_actionable_state.dart';

import '../auth/handlers/email/sign_in_button.dart' as email;
import '../auth/handlers/email/sign_up_button.dart' as email;
import '../auth/handlers/google/sign_in_button.dart' as google;

import '../app_model.dart';
import '../app_info.dart';

import '../auth/handlers/user/termsAcceptance/terms_accept_modal.dart';

enum LoginState {
  LoginSuccessful,
  LoginRequired,
}

class SplashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SplashPageState();
}

class SplashPageState extends ProgressActionableState<SplashPage> {
  @override
  void initState() {
    super.initState();

    _loader = _buildLoader();
  }

  Widget _loader;
  Widget _loginLoader;

  final GlobalKey<AsyncLoaderState> _loaderKey = GlobalKey<AsyncLoaderState>();

  AuthProvider _getPasswordProvider(AuthService authService) {
    return authService.authProviders.firstWhere(
        (prov) => prov.providerName == 'password',
        orElse: () => null);
  }

  AuthProvider _getGoogleProvider(AuthService authService) {
    return authService.authProviders.firstWhere(
        (prov) => prov.providerName == 'google',
        orElse: () => null);
  }

  Future<LoginState> _initAppState(AppModel model) async {
    await model.refreshAuthUser();
    if (model.user != null && model.user.isValid) {
      return LoginState.LoginSuccessful;
    } else {
      return LoginState.LoginRequired;
    }
  }

  Widget _handleCompleted(
      AppInfo appInfo, AuthService authService, LoginState state) {
    if (state == LoginState.LoginRequired) {
      return _buttons(appInfo, authService);
    } else if (state == LoginState.LoginSuccessful) {
      // _navigateToHome();
    }
    return Container();
  }

  Widget _handleError(AppInfo appInfo, AuthService authService, Object error) {
    return _buttons(appInfo, authService, errorMessage: error.toString());
  }

  Widget _progressIndicator() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: PlatformCircularProgressIndicator(
        android: (_) => MaterialProgressIndicatorData(
          valueColor: AlwaysStoppedAnimation(Colors.black45),
        ),
      ),
    );
  }

  Widget _handleSnapshot(AppModel model, BuildContext context,
      AsyncSnapshot<LoginState> snapshot) {
    if (snapshot.hasData) {
      return _handleCompleted(model.appInfo, model.authService, snapshot.data);
    } else if (snapshot.hasError) {
      return _handleError(model.appInfo, model.authService, snapshot.error);
    } else {
      return _progressIndicator();
    }
  }

  Widget _buildLoader() {
    return Consumer<AppModel>(builder: (_, appModel, child) {
      if (_loginLoader == null) {
        _loginLoader = FutureBuilder<LoginState>(
            key: _loaderKey,
            future: _initAppState(appModel),
            builder: (_, AsyncSnapshot<LoginState> snapshot) =>
                _handleSnapshot(appModel, _, snapshot));
      }
      return _loginLoader;
    });
  }

  Widget _buttons(AppInfo appInfo, AuthService authService,
      {String errorMessage}) {
    var passwordProvider = _getPasswordProvider(authService);
    var googleProvider = _getGoogleProvider(authService);

    List<Widget> widgets = new List<Widget>();
    if (passwordProvider != null) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: email.SignInButton(),
        ),
      );
    }
    if (googleProvider != null) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: google.SignInButton(action: (_) async {
            await performAction((BuildContext context) async {
              try {
                await googleProvider.signIn({}, termsAccepted: false);
              } on UserAcceptanceRequiredException catch (error) {
                bool accepted = await _handleAcceptanceRequired();

                if (accepted)
                  await googleProvider.signIn(error.data, termsAccepted: true);
              }
            });
          }),
        ),
      );
    }

    widgets.add(Padding(padding: EdgeInsets.only(top: 16.0)));
    if (passwordProvider != null) {
      widgets.add(
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: email.SignUpButton(),
        ),
      );
    }

    return Column(children: widgets);
  }

  Future<bool> _handleAcceptanceRequired() async {
    var accepted = await openDialog<bool>(
      context: context,
      builder: (_) => TermsAcceptModal(),
    );
    return accepted;
  }

  Widget _withProgress(Widget child) {
    return super.showProgress ? _progressIndicator() : child;
  }

  Widget _buildMobileView(
      AppInfo appInfo, Widget loader, Color splashForegroundColor) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ScreenLogo(imagePath: appInfo.appIconPath),
        Text(appInfo.appName,
            style: TextStyle(
                color: splashForegroundColor,
                fontSize: 18.0,
                fontWeight: FontWeight.bold)),
        Column(children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: _withProgress(loader),
          )
        ])
      ],
    ));
  }

  Widget _buildTabletView(AppInfo appInfo, Widget loader,
      Color splashBackgroundColor, Color splashForegroundColor) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 1,
            child: Container(
                color: splashBackgroundColor,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ScreenLogo(imagePath: appInfo.appIconPath),
                    Text(appInfo.appName,
                        style: TextStyle(
                            color: splashForegroundColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold)),
                  ],
                ))),
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 36.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: _withProgress(loader),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppModel>(
      builder: (_, appModel, child) {
        if (appModel.user != null && appModel.user.isValid) {
          print('valid user');
        } else {
          print('invalid user');
        }
        //var theme = Theme.of(context);
        Color bgColor = Colors.white;
        Color fgColor = Colors.black87;

        return TabletAwareScaffold(
            mobileView: (_) =>
                _buildMobileView(appModel.appInfo, _loader, fgColor),
            tabletView: (_) =>
                _buildTabletView(appModel.appInfo, _loader, bgColor, fgColor),
            backgroundColor: bgColor);
      },
    );
  }
}

///////////////////
///////////////////
///////////////////

// class LandingPage extends StatefulWidget {
//   @override
//   LandingPageState createState() => LandingPageState();
// }

// class LandingPageState extends State<LandingPage> {
//   @override
//   initState() {
//     super.initState();

//     textControlller = TextEditingController(text: 'text');
//   }

//   bool switchValue = false;
//   double sliderValue = 0.5;

//   TextEditingController textControlller;

//   _switchPlatform(BuildContext context) {
//     if (isMaterial) {
//       PlatformProvider.of(context).changeToCupertinoPlatform();
//     } else {
//       PlatformProvider.of(context).changeToMaterialPlatform();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PlatformScaffold(
//       iosContentPadding: true,
//       appBar: PlatformAppBar(
//         title: Text('Flutter Platform Widgets'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                   'Primary concept of this package is to use the same widgets to create iOS (Cupertino) or Android (Material) looking apps rather than needing to discover what widgets to use.'),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Text(
//                   'This approach is best when both iOS and Android apps follow the same design in layout and navigation, but need to look as close to native styling as possible.'),
//             ),
//             Divider(),
//             SectionHeader(title: '1. Change Platform'),
//             PlatformButton(
//               child: PlatformText('Switch Platform'),
//               onPressed: () => _switchPlatform(context),
//             ),
//             PlatformWidget(
//               android: (_) => Text('Currently showing Material'),
//               ios: (_) => Text('Currently showing Cupertino'),
//             ),
//             Text('Scaffold: PlatformScaffold'),
//             Text('AppBar: PlatformAppBar'),
//             Divider(),
//             SectionHeader(title: '2. Basic Widgets'),
//             PlatformText(
//               'PlatformText will uppercase for Material only',
//               textAlign: TextAlign.center,
//             ),
//             PlatformButton(
//               child: PlatformText('PlatformButton'),
//               onPressed: () {},
//             ),
//             PlatformButton(
//               child: PlatformText('Platform Flat Button'),
//               onPressed: () {},
//               androidFlat: (_) => MaterialFlatButtonData(),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: PlatformIconButton(
//                 androidIcon: Icon(Icons.home),
//                 // iosIcon: Icon(CupertinoIcons.home),
//                 onPressed: () {},
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: PlatformSwitch(
//                 value: switchValue,
//                 onChanged: (bool value) => setState(() => switchValue = value),
//               ),
//             ),
//             PlatformSlider(
//               value: sliderValue,
//               onChanged: (double newValue) {
//                 setState(() {
//                   sliderValue = newValue;
//                 });
//               },
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: PlatformTextField(
//                 controller: textControlller,
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: PlatformCircularProgressIndicator(),
//             ),
//             Divider(),
//             SectionHeader(title: '3. Dialogs'),
//             PlatformButton(
//               child: PlatformText('Show Dialog'),
//               onPressed: () => _showExampleDialog(),
//             ),
//             Divider(),
//             SectionHeader(title: '4. Navigation'),
//             PlatformButton(
//               child: PlatformText('Open Tabbed Page'),
//               // onPressed: () => _openPage((_) => new TabbedPage()),
//             ),
//             Divider(),
//             SectionHeader(title: '5. Advanced'),
//             PlatformButton(
//               child: PlatformText('Page with ListView'),
//               // onPressed: () => _openPage((_) => new ListViewPage()),
//             ),
//             PlatformWidget(
//               android: (_) => Container(), //this is for iOS only
//               ios: (_) => PlatformButton(
//                 child: PlatformText('iOS Page with Colored Header'),
//                 // onPressed: () => _openPage((_) => new ListViewHeaderPage()),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   _openPage(WidgetBuilder pageToDisplayBuilder) {
//     Navigator.push(
//       context,
//       platformPageRoute(
//         builder: pageToDisplayBuilder,
//       ),
//     );
//   }

//   _showExampleDialog() {
//     showPlatformDialog(
//       context: context,
//       builder: (_) => PlatformAlertDialog(
//         title: Text('Alert'),
//         content: Text('Some content'),
//         actions: <Widget>[
//           PlatformDialogAction(
//             android: (_) => MaterialDialogActionData(),
//             ios: (_) => CupertinoDialogActionData(),
//             child: PlatformText('Cancel'),
//             onPressed: () => Navigator.pop(context),
//           ),
//           PlatformDialogAction(
//             child: PlatformText('OK'),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class SectionHeader extends StatelessWidget {
//   final String title;

//   const SectionHeader({
//     @required this.title,
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4.0),
//       child: Text(
//         title,
//         style: TextStyle(fontSize: 18.0),
//       ),
//     );
//   }
// }

// class Divider extends StatelessWidget {
//   const Divider({
//     Key key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 1.0,
//       color: new Color(0xff999999),
//       margin: const EdgeInsets.symmetric(vertical: 12.0),
//     );
//   }
// }
