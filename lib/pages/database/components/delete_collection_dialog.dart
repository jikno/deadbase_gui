import 'package:deadbase_gui/pages/components/input.dart';
import 'package:deadbase_gui/services/api.dart';
import 'package:deadbase_gui/utils.dart';
import 'package:flutter/material.dart';
import '../../../state.dart' as state;

class DeleteCollectionDialog extends StatefulWidget {
  final VoidCallback onClosed;
  final String name;

  DeleteCollectionDialog({required this.onClosed, required this.name});

  @override
  _DeleteCollectionDialogState createState() => _DeleteCollectionDialogState();
}

class _DeleteCollectionDialogState extends State<DeleteCollectionDialog> {
  String? nameError;
  String? verifiedName;

  bool loading = false;

  void delete() async {
    setState(() {
      loading = true;
      nameError = null;
    });

    try {
      await deleteCollection(state.host, state.databaseName, state.auth, widget.name);

      notifyUser('Collection deleted', success: true);
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
                'Delete collection',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Text(
                  'Are you sure you want to delete collection "${widget.name}" and all it\'s documents?  This action is permanent and cannont me undone.'),
              SizedBox(height: 20),
              Text('Type "${widget.name}" below to confirm.'),
              SizedBox(height: 30),
              Input(
                label: 'Name',
                error: nameError,
                onChanged: (value) => setState(() => verifiedName = value),
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
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                    onPressed: loading
                        ? null
                        : verifiedName == null
                            ? null
                            : verifiedName != widget.name
                                ? null
                                : delete,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Delete forever'),
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
