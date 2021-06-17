import 'package:flutter/material.dart';
import '../../components/input.dart';
import '../../../services/deadbase.dart';
import '../../../utils.dart';

class RenameCollectionDialog extends StatefulWidget {
  final VoidCallback onClosed;
  final String name;
  final Deadbase deadbase;

  RenameCollectionDialog({required this.onClosed, required this.name, required this.deadbase});

  @override
  _RenameCollectionDialogState createState() => _RenameCollectionDialogState();
}

class _RenameCollectionDialogState extends State<RenameCollectionDialog> {
  String? nameError;
  String? newName;

  bool loading = false;

  void rename() async {
    setState(() {
      loading = true;
      nameError = null;
    });

    try {
      await widget.deadbase.renameCollection(widget.name, newName!);

      notifyUser(context, 'Collection renamed', success: true);
      Navigator.pop(context);
      widget.onClosed();
    } on DeadbaseConnectionException catch (e) {
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
                'Rename collection',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Input(
                label: 'Name',
                error: nameError,
                value: widget.name,
                onChanged: (value) => setState(() => newName = value),
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
                        : newName == null
                            ? null
                            : newName == widget.name
                                ? null
                                : rename,
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
