import 'package:flutter_auth_base/flutter_auth_base.dart';
import 'package:flutter_auth_firebase/flutter_auth_firebase.dart';
import 'core/auth/mock/mock_service.dart';

import 'core/imageProviders/combined_image_provider.dart';
import 'core/imageProviders/gravatar_provider.dart';
import 'core/imageProviders/user_photo_url_provider.dart';

AuthService createMockedAuthService() {
  print(">>>>> AUTHENTICATION in MOCKED MODE <<<<<");
  var authService = new MockService();
  authService.preAuthPhotoProvider = new GravatarProvider();
  authService.postAuthPhotoProvider = new CombinedPhotoProvider()
    ..add(new AuthUserImageProvider(service: authService))
    ..add(new GravatarProvider(missingImageType: ImageType.MysteryMan));

  return authService;
}

AuthService createFirebaseAuthService() {
  var authService = new FirebaseAuthService();
  authService.authProviders.addAll([
    new FirebaseEmailProvider(service: authService),
    new FirebaseGoogleProvider(service: authService)
  ]);
  authService.linkProviders.addAll([
    new FirebaseEmailProvider(service: authService),
    new FirebaseGoogleProvider(service: authService)
  ]);

  return authService;
}
