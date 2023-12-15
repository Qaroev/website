// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4dNWeqX1S3L0jDwGBrA5M-utdfxjHndA',
    appId: '1:1064636904002:android:88e02a6fc2dee8579cf3db',
    messagingSenderId: '1064636904002',
    projectId: 'ecoplantagro',
    storageBucket: 'ecoplantagro.appspot.com',
    authDomain: "ecoplantagro.firebaseapp.com",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAqcDokfbCbIqfPP0xFFCoNnq2o7-8xao4',
    appId: '1:373860489948:android:52b3c3f6e4fd7166a87219',
    messagingSenderId: '373860489948',
    projectId: 'doctorchat-push',
    storageBucket: 'doctorchat-push.appspot.com',
    iosClientId:
        '151465342526-uj30l7265j56b964uctmpdvq04aabfie.apps.googleusercontent.com',
    iosBundleId: 'ecoplantagro',
  );
}
