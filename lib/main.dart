import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:needlinc/needlinc/shared-pages/auth-pages/welcome.dart';
import 'firebase_options.dart';
import 'needlinc/business-pages/business-main.dart';
import 'needlinc/client-pages/client-main.dart';
import 'needlinc/needlinc-variables/constants.dart';
import 'needlinc/shared-pages/auth-pages/sign-in.dart';
import 'needlinc/shared-pages/user-type.dart';
import 'needlinc/controller/dependenct_injection.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure that Flutter is initialized
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  DependencyInjection.init();
  runApp(const Home());
 
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize GoogleSignIn with the client ID
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: Constant.googleSignUpApiKey,
    );
    return GetMaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const RootPage(),
        '//': (context) => const SignupPage(),
        'client': (context) => ClientMainPages(currentPage: 0),
        'business': (context) => BusinessMainPages(currentPage: 0),
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({Key? key}) : super(key: key);

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const UserType();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('${snapshot.error}'),
            );
          }
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return WelcomePage();
      },
    );
  }
}
