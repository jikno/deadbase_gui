import 'package:deadbase_gui/pages/connect/components/input.dart';
import 'package:flutter/material.dart';
import '../../services/list_connections.dart';

class Connect extends StatefulWidget {
  @override
  _ConnectState createState() => _ConnectState();
}

late BuildContext scaffoldContext;

void notifyUser(String message, {bool success = false, bool failure = false}) {
  final snackbar = SnackBar(
    content: Row(
      children: [
        success
            ? Icon(
                Icons.check,
                color: Colors.green,
              )
            : failure
                ? Icon(
                    Icons.close,
                    color: Colors.red,
                  )
                : Icon(Icons.info, color: Colors.blue),
        SizedBox(
          width: 10,
        ),
        Text(message)
      ],
    ),
  );

  ScaffoldMessenger.of(scaffoldContext).showSnackBar(snackbar);
}

class _ConnectState extends State<Connect> {
  String host = '';
  String name = '';
  String auth = '';

  String? hostError;
  String? nameError;
  String? authError;

  bool loading = false;

  void connect() async {
    if (host.isEmpty || name.isEmpty)
      return setState(() {
        hostError = host.isEmpty ? 'Host must be specified' : null;
        nameError = name.isEmpty ? 'Name must be specified' : null;
        authError = null;
      });

    setState(() {
      loading = true;
      hostError = null;
      nameError = null;
      authError = null;
    });

    try {
      await fetchCollections(host, name, auth);

      notifyUser('Connected to database!', success: true);
      setState(() {
        loading = false;
      });
    } on DatabaseConnectionException catch (e) {
      if (e.statusCode == 500) {
        notifyUser(e.errorResponse, failure: true);
        setState(() {
          loading = false;
        });
      } else if (e.statusCode == 403) {
        notifyUser(e.errorResponse, failure: true);
        setState(() {
          loading = false;
          setState(() {
            authError = 'Invalid auth token';
          });
        });
      } else if (e.statusCode == 406) {
        notifyUser(e.errorResponse, failure: true);
        setState(() {
          loading = false;
          nameError = 'Could not find a database with this name';
        });
      } else {
        notifyUser(e.errorResponse, failure: true);
        setState(() {
          loading = false;
        });
      }
    } on NetworkException {
      notifyUser('Could not connect to host', failure: true);
      setState(() {
        loading = false;
        hostError = 'Could not connect';
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) {
          scaffoldContext = context;

          return SingleChildScrollView(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: 500),
                child: Column(
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      'Connect to a database',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Input(
                      autocorrect: false,
                      label: 'Host',
                      onChanged: (value) => host = value,
                      error: hostError,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Input(
                      label: 'Name',
                      onChanged: (value) => name = value,
                      error: nameError,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Input(
                      autocorrect: false,
                      label: 'Authentication',
                      obscureText: true,
                      onChanged: (value) => auth = value,
                      error: authError,
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(),
                        ),
                        ElevatedButton(
                          onPressed: loading ? null : connect,
                          child: Container(
                            child: Text('Connect'),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
