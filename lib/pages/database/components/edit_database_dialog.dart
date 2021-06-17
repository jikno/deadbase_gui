import 'package:flutter/material.dart';
import '../../components/input.dart';
import '../../../services/deadbase.dart';
import '../../../utils.dart';

class EditDatabaseDialog extends StatefulWidget {
  final VoidCallback onClosed;
  final Deadbase deadbase;

  EditDatabaseDialog({required this.onClosed, required this.deadbase});

  @override
  _EditDatabaseDialogState createState() => _EditDatabaseDialogState();
}

class _EditDatabaseDialogState extends State<EditDatabaseDialog> {
  String? nameError;
  String? authError;
  String? newName;
  String? newAuth;

  bool authWasEdited = false;
  bool loading = false;

  void rename() async {
    setState(() {
      loading = true;
      nameError = null;
    });

    try {
      await widget.deadbase.editDatabase(newName ?? widget.deadbase.name, newAuth);

      notifyUser(context, 'Database info updated!', success: true);
      Navigator.pop(context);
      widget.onClosed();
    } on DeadbaseConnectionException catch (e) {
      if (e.statusCode == 406) {
        setState(() {
          loading = false;
          if (e.errorResponse.contains('auth'))
            authError = e.errorResponse;
          else
            nameError = e.errorResponse;
        });
      } else {
        setState(() {
          loading = false;
        });
      }

      notifyUser(context, e.errorResponse, failure: true);
    } on NetworkException {
      notifyUser(context, 'Could not connect to database', failure: true);
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
                'Edit database meta',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Input(
                label: 'Name',
                error: nameError,
                value: widget.deadbase.name,
                onChanged: (value) => setState(() => newName = value),
              ),
              SizedBox(height: 30),
              Input(
                label: 'Auth',
                error: authError,
                value: widget.deadbase.auth ?? '',
                onChanged: (value) => setState(() {
                  authWasEdited = true;

                  if (value.isEmpty)
                    newAuth = null;
                  else
                    newAuth = value;
                }),
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
                    onPressed: loading
                        ? null
                        : (newName == null || newName == widget.deadbase.name) &&
                                (!authWasEdited || newAuth == widget.deadbase.auth)
                            ? null
                            : rename,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Save'),
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
