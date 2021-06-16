import 'package:deadbase_gui/pages/components/input.dart';
import 'package:deadbase_gui/services/api.dart';
import 'package:deadbase_gui/utils.dart';
import 'package:flutter/material.dart';
import '../../../state.dart' as state;

class AddCollectionDialog extends StatefulWidget {
  final VoidCallback onClosed;

  AddCollectionDialog({required this.onClosed});

  @override
  _AddCollectionDialogState createState() => _AddCollectionDialogState();
}

class _AddCollectionDialogState extends State<AddCollectionDialog> {
  String? nameError;
  String name = '';

  bool loading = false;

  void add() async {
    setState(() {
      loading = true;
      nameError = null;
    });

    try {
      await addCollection(state.host, state.databaseName, state.auth, name);

      notifyUser('Collection added', success: true);
      Navigator.pop(context);
      widget.onClosed();
    } on DatabaseConnectionException catch (e) {
      if (e.statusCode == 406) {
        setState(() {
          loading = false;
          nameError = e.errorResponse;
        });
      } else {
        setState(() {
          loading = false;
        });
      }

      notifyUser(e.errorResponse, failure: true);
    } on NetworkException {
      notifyUser('Could not connect to database', failure: true);
      setState(() {
        loading = false;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add a new collection',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Input(
                label: 'Name',
                error: nameError,
                onChanged: (value) => name = value,
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: loading ? null : add,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Add'),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
