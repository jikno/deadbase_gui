import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';

class DocumentSnapshot extends StatelessWidget {
  final String id;
  final bool selected;
  final VoidCallback onSelected;
  final VoidCallback onDelete;

  DocumentSnapshot({
    required this.id,
    required this.selected,
    required this.onSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ContextMenuRegion(
      contextMenu: GenericContextMenu(
        buttonConfigs: [
          ContextMenuButtonConfig('Open', onPressed: onSelected),
          ContextMenuButtonConfig('Delete', onPressed: onDelete),
        ],
      ),
      child: Container(
        color: selected ? Colors.blue : null,
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              id,
              style: Theme.of(context).textTheme.button!.copyWith(color: selected ? Colors.white : null),
            ),
          ),
          onTap: onSelected,
        ),
      ),
    );
  }
}
