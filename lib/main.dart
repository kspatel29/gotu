import 'dart:async';


// import 'package:gotuappv1/Verify.dart';
import 'package:gotuappv1/appPages.dart';
import 'package:gotuappv1/firebase_options.dart';
// import 'package:gotuappv1/firebase_options.dart';
import 'package:gotuappv1/firestore.dart';
import 'package:gotuappv1/map.dart';
import 'package:gotuappv1/try.dart';
import 'package:gotuappv1/userName.dart';
import 'package:gotuappv1/verify.dart';
import 'package:gotuappv1/views/huddle_page/huddle_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import 'firebase_options.dart';


// // import 'package:floating_action_wheel/wheel_button.dart';


// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   GoogleSignIn.standard().signInSilently();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CircularProgressIndicator(); // Show loading indicator while waiting for auth state
//           } else {
//             if (snapshot.hasData) {
//               return MyHomePage(); // User is logged in, navigate to MyHomePage
//             } else {
//               return SignInPage(); // User is not logged in, navigate to LoginPage
//             }
//           }
//         },
//       ),
//     );
//   }
// }

Future<void> main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  final FirestoreService firestoreService = FirestoreService();

  // Initialize Google Sign-In silently
  await GoogleSignIn.standard().signInSilently();

  // Check if the user is already logged in
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    // String? userId = FirebaseAuth.instance.currentUser?.uid;
    // print(userId);
      if (user != null) {
        // bool userExists = await firestoreService.checkUserExists(user.uid);
        // if (!userExists) {
        //   // User is logging in for the first time, add user data to database
        //   // await firestoreService.addUserToDatabase(user); // Call the function to add user data
        //   print('user doesnt exist.');
        // }
        // User is logged in, navigate to 'home'
        runApp(MaterialApp(
          initialRoute: 'home',
          debugShowCheckedModeBanner: false,
          routes: {
            'phone': (context) => const phoneSign(),
            'verify': (context) => const MyVerify(),
            'username': (context) => UsernamePage(),
            'home': (context) => MyHomePage(),
          },
        ));
      } else {
        // User is not logged in, navigate to 'phone'
        runApp(MaterialApp(
          initialRoute: 'phone',
          debugShowCheckedModeBanner: false,
          routes: {
            'phone': (context) => const phoneSign(),
            'verify': (context) => const MyVerify(),
            'username': (context) => UsernamePage(),
            'home': (context) => MyHomePage(),
          },
          
        ));
      }
  });
}
//C:\Users\Kush2\Desktop\gotuappv1\lib\provider\firebase_provider.dart

// import 'package:gotuappv1/provider/firebase_provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:provider/firebase_provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'firebase_options.dart';
// import 'view/screens/auth/auth_page.dart';
// import 'view/screens/auth/verify_email_page.dart';

// Future<void> _backgroundMessageHandler(
//     RemoteMessage message) async {
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
// }

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   await FirebaseMessaging.instance.getInitialMessage();

//   FirebaseMessaging.onBackgroundMessage(
//       _backgroundMessageHandler);
//   runApp(const MyApp());
// }

// final navigatorKey = GlobalKey<NavigatorState>();

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   get mainColor => null;

//   @override
//   Widget build(BuildContext context) =>
//       ChangeNotifierProvider(
//         create: (_) => FirebaseProvider(),
//         child: MaterialApp(
//           navigatorKey: navigatorKey,
//           debugShowCheckedModeBanner: false,
//           theme: ThemeData(
//               elevatedButtonTheme: ElevatedButtonThemeData(
//                 style: ElevatedButton.styleFrom(
//                     textStyle:
//                         const TextStyle(fontSize: 20),
//                     minimumSize: const Size.fromHeight(52),
//                     backgroundColor: mainColor),
//               ),
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 titleTextStyle: TextStyle(
//                   color: Colors.black,
//                   fontSize: 35,
//                   fontWeight: FontWeight.bold,
//                 ),
//               )),
//           home: const MainPage(),
//         ),
//       );
// }

// class MainPage extends StatelessWidget {
//   const MainPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         body: StreamBuilder<User?>(
//           stream: FirebaseAuth.instance.authStateChanges(),
//           builder: (context, snapshot) {
//             if (snapshot.hasData) {
//               return const VerifyEmailPage();
//             } else {
//               return const AuthPage();
//             }
//           },
//         ),
//       );
// }


