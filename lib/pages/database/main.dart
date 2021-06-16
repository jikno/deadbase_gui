import 'package:context_menus/context_menus.dart';
import 'package:deadbase_gui/pages/database/components/add_collection_dialog.dart';
import 'package:deadbase_gui/pages/database/components/delete_collection_dialog.dart';
import 'package:deadbase_gui/pages/database/components/edit_database_dialog.dart';
import 'package:deadbase_gui/pages/database/components/rename_collection_dialog.dart';
import 'package:deadbase_gui/utils.dart';
import 'package:flutter/material.dart';
import '../../state.dart' as state;
import '../../services/api.dart';
import './components/collection_name.dart';

class Database extends StatefulWidget {
  @override
  _DatabaseState createState() => _DatabaseState();
}

class _DatabaseState extends State<Database> {
  bool loadingCollections = false;
  List<String> collections = state.collections;
  String? focusedCollection;

  void loadCollections() async {
    setState(() {
      loadingCollections = true;
    });

    await fetchCollections(state.host, state.databaseName, state.auth);

    setState(() {
      loadingCollections = false;
      collections = state.collections;
    });
  }

  void addCollection() {
    showDialog(context: context, builder: (context) => AddCollectionDialog(onClosed: () => loadCollections()));
  }

  void renameCollection(String collection) {
    showDialog(
        context: context,
        builder: (context) => RenameCollectionDialog(onClosed: () => loadCollections(), name: collection));
  }

  void deleteCollection(String collection) {
    showDialog(
        context: context,
        builder: (context) => DeleteCollectionDialog(onClosed: () => loadCollections(), name: collection));
  }

  void editDatabaseMeta() {
    showDialog(
        context: context, builder: (context) => EditDatabaseDialog(onClosed: () => null, name: state.databaseName));
  }

  @override
  Widget build(BuildContext context) {
    if (state.host.isEmpty)
      return Scaffold(
          body: Center(
        child: Text('Not connected to a database'),
      ));

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
                      notifyUser('Collections are up to date!', success: true);
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
                                message: state.databaseName,
                                child: Text(
                                  state.databaseName,
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
                                      notifyUser('Collections are up to date!', success: true);
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
