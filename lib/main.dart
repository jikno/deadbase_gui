import 'package:flutter/material.dart';
import 'package:flutter_router/flutter_router.dart' as app_router;
import 'pages/connect/main.dart';

void main() {
  runApp(Application());
}

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: app_router.Router({'/': (context, match) => Connect()}).get,
    );
  }
}
