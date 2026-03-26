import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myfarm/pages/feed_use_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await GetStorage.init();
    await Firebase.initializeApp();
    runApp(const MyApp());
  } catch (e) {
    debugPrint("FIREBASE INIT ERROR: $e");

    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Firebase Error - Check Console")),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Farm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: FeedUseView(),
    );
  }
}
