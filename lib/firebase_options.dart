import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBpWa1RhoK6oo3VX47GO0Eqayc6Zf3ykAU',
    appId: '1:159688433113:android:80849d975f085704bf0dc8',
    messagingSenderId: '159688433113',
    projectId: 'testing-4b090',
    storageBucket: 'testing-4b090.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDipwbUiQ71oPNWATWFHG33PJTOnLqKuw',
    appId: '1:159688433113:ios:20d10c679db0f1b8bf0dc8',
    messagingSenderId: '159688433113',
    projectId: 'testing-4b090',
    storageBucket: 'testing-4b090.firebasestorage.app',
    androidClientId: '159688433113-15a9eem5g7lvemrjk463ojec26cpish9.apps.googleusercontent.com',
    iosClientId: '159688433113-ccs2ajp2lafh8adpodarcabemvfujk88.apps.googleusercontent.com',
    iosBundleId: 'com.itfuturz.homezyVendor',
  );
}
