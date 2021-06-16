import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

class CollectionName extends StatelessWidget {
  final VoidCallback onSelected;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final String name;
  final bool selected;

  CollectionName({
    required this.onSelected,
    required this.onDelete,
    required this.onRename,
    required this.name,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig('Open', onPressed: onSelected),
          ContextMenuButtonConfig('Rename', onPressed: onRename),
          ContextMenuButtonConfig('Delete', onPressed: onDelete),
        ],
      ),
      child: Container(
        color: selected ? Colors.blue : null,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              name,
              style: Theme.of(context).textTheme.button!.copyWith(color: selected ? Colors.white : null),
            ),
          ),
          onTap: onSelected,
        ),
      ),
    );
  }
}
