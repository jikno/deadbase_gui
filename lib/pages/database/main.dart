import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:context_menus/context_menus.dart';
import '../database/components/add_collection_dialog.dart';
import '../database/components/delete_collection_dialog.dart';
import '../database/components/edit_database_dialog.dart';
import '../database/components/rename_collection_dialog.dart';
import '../../services/deadbase.dart';
import '../../utils.dart';
import '../../state.dart';
import './components/collection_name.dart';

class Database extends StatefulWidget {
  @override
  _DatabaseState createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  bool loadingCollections = false;
  List<String> collections = [];
  String? focusedCollection;

  late Deadbase deadbase;

  void loadCollections() async {
    setState(() {
      loadingCollections = true;
    });

    try {
      final collections = await deadbase.getCollections();

      setState(() {
        loadingCollections = false;
        this.collections = collections;
      });
    } on NetworkException {
      notifyUser(context, 'Could not connect to database', failure: true);

      setState(() {
        loadingCollections = false;
      });
    }
  }

  void addCollection() {
    showDialog(
      context: context,
      builder: (context) => AddCollectionDialog(
        deadbase: deadbase,
        onClosed: () => loadCollections(),
      ),
    );
  }

  void renameCollection(String collection) {
    showDialog(
      context: context,
      builder: (context) => RenameCollectionDialog(
        deadbase: deadbase,
        onClosed: () => loadCollections(),
        name: collection,
      ),
    );
  }

  void deleteCollection(String collection) {
    showDialog(
      context: context,
      builder: (context) => DeleteCollectionDialog(
        deadbase: deadbase,
        onClosed: () => loadCollections(),
        name: collection,
      ),
    );
  }

  void editDatabaseMeta() {
    showDialog(
      context: context,
      builder: (context) => EditDatabaseDialog(
        onClosed: () => setState(() => deadbase = deadbase),
        deadbase: deadbase,
      ),
    );
  }

  var buildCalledBefore = false;

  @override
  Widget build(BuildContext context) {
    final id = Beamer.of(context).currentBeamLocation.state.pathParameters['id'];

    try {
      deadbase = getStashedDatabase(id!);
    } on InvalidDeadbaseIdException {
      return Scaffold(
        body: Center(
          child: Text('Database reference was not found'),
        ),
      );
    }

    if (!buildCalledBefore) {
      buildCalledBefore = true;
      loadCollections();
    }

    return Scaffold(
      body: ContextMenuOverlay(
        child: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ContextMenuRegion(
                contextMenu: GenericContextMenu(
                  buttonConfigs: [
                    ContextMenuButtonConfig('Edit database meta', onPressed: editDatabaseMeta),
                    ContextMenuButtonConfig('Refetch connections', onPressed: () {
                      loadCollections();
                      notifyUser(context, 'Collections are up to date!', success: true);
                    }),
                    ContextMenuButtonConfig('Add collection', onPressed: addCollection)
                  ],
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 270,
                    minWidth: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Tooltip(
                                message: deadbase.name,
                                child: Text(
                                  deadbase.name,
                                  style: Theme.of(context).textTheme.headline5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            IconButton(
                              onPressed: editDatabaseMeta,
                              icon: Icon(Icons.edit),
                              tooltip: 'Edit database meta',
                            ),
                            IconButton(
                              onPressed: loadingCollections
                                  ? null
                                  : () {
                                      loadCollections();
                                      notifyUser(context, 'Collections are up to date!', success: true);
                                    },
                              icon: Icon(Icons.sync),
                              tooltip: 'Refetch collections',
                            )
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey, thickness: 0.5, height: 0.5),
                      Expanded(
                        child: loadingCollections
                            ? Center(child: Text('Loading collections...'))
                            : collections.isEmpty
                                ? Center(
                                    child: Text('No collections'),
                                  )
                                : SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: collections
                                          .map((e) => CollectionName(
                                                name: e,
                                                onSelected: () => setState(() => focusedCollection = e),
                                                onDelete: () => deleteCollection(e),
                                                onRename: () => renameCollection(e),
                                                selected: focusedCollection == e,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                      ),
                      Divider(color: Colors.grey, thickness: 0.5, height: 0.5),
                      Row(
                        children: [
                          SizedBox(width: 16),
                          Expanded(
                            child: Text('${collections.length} collection${collections.length == 1 ? '' : 's'}'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: IconButton(
                              onPressed: addCollection,
                              icon: Icon(Icons.add),
                              tooltip: "Add a collection",
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              VerticalDivider(thickness: 0.5, color: Colors.grey, width: 0.5),
              Expanded(
                flex: 1,
                child: Container(
                  child: Center(
                    child: Text('loading document...'),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
