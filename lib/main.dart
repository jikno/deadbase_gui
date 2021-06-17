import 'dart:io';
import 'package:flutter/material.dart';
import 'pages/connect/main.dart';
import 'pages/database/main.dart';
import 'package:beamer/beamer.dart';
import 'package:window_size/window_size.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    setWindowTitle('App title');
    setWindowMinSize(const Size(270 * 3 + 1, 500));
    setWindowMaxSize(Size.infinite);
  }

  runApp(Application());
}

class Application extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: SimpleLocationBuilder(
      routes: {
        '/': (context, state) => Connect(),
        '/database/:id': (context, state) => Database(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
      theme: ThemeData(primarySwatch: Colors.blue),
    );

    // return ContextMenuOverlay(
    //   child: MaterialApp(
    //     home: Scaffold(
    //       body: Center(
    //         child: Column(
    //           children: [
    //             Text('hi'),
    //             ContextMenuRegion(
    //               child: Container(width: 300, height: 200, color: Colors.red),
    //               contextMenu: LinkContextMenu(
    //                 url: 'https://flutter.dev',
    //               ),
    //             )
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
