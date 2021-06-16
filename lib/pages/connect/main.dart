import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import '../components/input.dart';
import '../../services/api.dart';
import '../../state.dart';
import '../../utils.dart';

class Connect extends StatefulWidget {
  @override
  _ConnectState createState() => _ConnectState();
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

      Beamer.of(scaffoldContext!).beamToNamed('/database');
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
      print(e);

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
