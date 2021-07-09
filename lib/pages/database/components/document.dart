import 'package:deadbase_gui/pages/components/json-editor/main.dart';
import 'package:flutter/material.dart';
import '../../../services/deadbase.dart';

class Document extends StatefulWidget {
  final Deadbase deadbase;
  final String collection;
  final String document;

  Document({
    required this.deadbase,
    required this.collection,
    required this.document,
  });

  @override
  _DocumentState createState() => _DocumentState();
}

class _DocumentState extends State<Document> {
  bool loading = true;
  bool savingDocument = false;
  Map<String, dynamic> data = {};
  Map<String, dynamic> oldData = {};
  bool unsavedChanges = false;

  Future<void> loadDocument() async {
    setState(() {
      loading = true;
    });

    final data = await widget.deadbase.getDocument(widget.collection, widget.document);

    setState(() {
      loading = false;
      this.data = data;
      oldData = data;
      unsavedChanges = false;
    });
  }

  Future<void> saveDocument() async {
    setState(() {
      savingDocument = true;
    });

    widget.deadbase.setDocument(widget.collection, data);

    setState(() {
      savingDocument = false;
      unsavedChanges = false;
      oldData = data;
    });
  }

  void discardChanges() {
    setState(() {
      data = oldData;
      unsavedChanges = false;
    });
  }

  String? lastSelectedDocument;

  @override
  Widget build(BuildContext context) {
    if (lastSelectedDocument == null || lastSelectedDocument != widget.document) {
      lastSelectedDocument = widget.document;
      loadDocument();
    }

    if (loading)
      return Center(
        child: Text('Loading document...'),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: JsonEditor(
                  data: data,
                  onDataChanged: (newData) {
                    setState(() {
                      data = newData;
                      unsavedChanges = true;
                    });
                  },
                ),
              ),
            ),
          ),
        ),
        if (unsavedChanges) ...[
          Divider(
            height: 0.5,
            thickness: 0.5,
            color: Colors.grey,
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 19),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 10),
                  Text('You have unsaved changes'),
                  Spacer(),
                  TextButton(
                    onPressed: discardChanges,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Discard'),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: savingDocument ? null : saveDocument,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text('Save'),
                    ),
                  )
                ],
              ),
            ),
          )
        ]
      ],
    );
  }
}
