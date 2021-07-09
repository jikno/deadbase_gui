import 'package:context_menus/context_menus.dart';
import 'package:deadbase_gui/pages/database/components/document.dart';
import 'package:flutter/material.dart';
import './delete_document_dialog.dart';
import './document_snapshot.dart';
import '../../../services/deadbase.dart';
import '../../../utils.dart';

class Documents extends StatefulWidget {
  final Deadbase deadbase;
  final String? selectedCollection;

  Documents({required this.deadbase, required this.selectedCollection});

  @override
  _DocumentsState createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  bool loadingDocuments = false;
  List<String> documents = [];
  String? selectedDocumentId;

  Future<void> loadDocuments() async {
    setState(() {
      loadingDocuments = true;
    });

    final documents = await widget.deadbase.getDocuments(widget.selectedCollection!);

    setState(() {
      loadingDocuments = false;
      this.documents = documents;
    });
  }

  void reloadDocuments() async {
    await loadDocuments();
    notifyUser(context, 'Documents are up to date!', success: true);
  }

  void addDocument() async {
    if (widget.selectedCollection == null) return;

    final id = await widget.deadbase.setDocument(widget.selectedCollection!, {});
    notifyUser(context, 'Created an empty document.', success: true);

    await loadDocuments();

    setState(() {
      selectedDocumentId = id;
    });
  }

  void deleteDocument(String id) async {
    if (widget.selectedCollection == null) return;

    showDialog(
      context: context,
      builder: (context) => DeleteDocumentDialog(
        collection: widget.selectedCollection!,
        deadbase: widget.deadbase,
        id: id,
        onClosed: loadDocuments,
      ),
    );
  }

  String? lastSelectedCollection;

  @override
  Widget build(BuildContext context) {
    if (widget.selectedCollection == null) return Center(child: Text('No collection selected'));

    if (lastSelectedCollection != widget.selectedCollection) {
      lastSelectedCollection = widget.selectedCollection;
      selectedDocumentId = null;
      loadDocuments();
    }

    return Row(
      children: [
        ContextMenuRegion(
          contextMenu: GenericContextMenu(
            buttonConfigs: [
              ContextMenuButtonConfig('Add document', onPressed: addDocument),
              ContextMenuButtonConfig('Refetch documents', onPressed: reloadDocuments),
            ],
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 270, minWidth: 0),
            child: Column(
              children: [
                Expanded(
                  child: loadingDocuments
                      ? Center(
                          child: Text('Loading documents...'),
                        )
                      : documents.isEmpty
                          ? Center(child: Text('No documents'))
                          : Column(
                              children: documents
                                  .map((id) => DocumentSnapshot(
                                        id: id,
                                        onDelete: () => deleteDocument(id),
                                        onSelected: () => setState(() => selectedDocumentId = id),
                                        selected: selectedDocumentId == id,
                                      ))
                                  .toList(),
                            ),
                ),
                Divider(height: 0.5, thickness: 0.5, color: Colors.grey),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(child: Text('${documents.length} document${documents.length == 1 ? '' : 's'}')),
                      IconButton(onPressed: addDocument, icon: Icon(Icons.add)),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        VerticalDivider(
          width: 0.5,
          thickness: 0.5,
          color: Colors.grey,
        ),
        Expanded(
            child: selectedDocumentId == null
                ? Center(
                    child: Text('No document selected'),
                  )
                : Document(
                    deadbase: widget.deadbase,
                    collection: widget.selectedCollection!,
                    document: selectedDocumentId!,
                  ))
      ],
    );
  }
}
