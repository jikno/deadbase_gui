import 'package:flutter/material.dart';
import '../../../services/deadbase.dart';
import '../../../utils.dart';

class DeleteDocumentDialog extends StatefulWidget {
  final VoidCallback onClosed;
  final String id;
  final String collection;
  final Deadbase deadbase;

  DeleteDocumentDialog({
    required this.onClosed,
    required this.id,
    required this.deadbase,
    required this.collection,
  });

  @override
  _DeleteDocumentDialogState createState() => _DeleteDocumentDialogState();
}

class _DeleteDocumentDialogState extends State<DeleteDocumentDialog> {
  bool loading = false;

  void delete() async {
    setState(() {
      loading = true;
    });

    try {
      await widget.deadbase.deleteDocument(widget.collection, widget.id);

      notifyUser(context, 'Document deleted.', success: true);
      Navigator.pop(context);
      widget.onClosed();
    } on DeadbaseConnectionException catch (e) {
      if (e.statusCode == 406) {
        setState(() {
          loading = false;
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
                'Delete document',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 30),
              Text(
                  'Are you sure you want to delete document "${widget.id}"?  This action is permanent and cannont me undone.'),
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
                    onPressed: loading ? null : delete,
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
