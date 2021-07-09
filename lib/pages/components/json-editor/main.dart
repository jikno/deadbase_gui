import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class JsonMapView extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(dynamic) onDataChanged;

  JsonMapView({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VerticalDivider(
          width: 0.5,
          thickness: 0.5,
          color: Colors.grey,
          indent: 10,
          endIndent: 10,
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries
              .map((entry) => Row(
                    children: [
                      JsonInput(
                          value: entry.key,
                          onChanged: (newKey) {
                            onDataChanged(data.map((key, value) {
                              if (key == entry.key) return MapEntry(newKey, value);

                              return MapEntry(key, value);
                            }));
                          },
                          color: Colors.red),
                      // SizedBox(width: 20),
                      JsonEditorItem(
                        data: entry.value,
                        onDataChanged: (newValue) {
                          onDataChanged(data.map((key, value) {
                            if (key == entry.key) return MapEntry(key, newValue);

                            return MapEntry(key, value);
                          }));
                        },
                        onDelete: () {
                          final Map<String, dynamic> newData = {};

                          data.forEach((key, value) {
                            if (entry.key != key) newData[key] = value;
                          });

                          onDataChanged(newData);
                        },
                      ),
                    ],
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class JsonListView extends StatelessWidget {
  final List<dynamic> data;
  final Function(dynamic) onDataChanged;

  JsonListView({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class JsonStringView extends StatelessWidget {
  final String data;
  final Function(dynamic) onDataChanged;

  JsonStringView({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return JsonInput(
      color: Colors.green,
      value: data,
      onChanged: (value) {},
    );
  }
}

class JsonBooleanView extends StatelessWidget {
  final bool data;
  final Function(dynamic) onDataChanged;

  JsonBooleanView({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(value: data, onChanged: onDataChanged);
  }
}

class JsonNumberValue extends StatelessWidget {
  final dynamic data;
  final Function(dynamic) onDataChanged;

  JsonNumberValue({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return JsonInput(
      value: '$data',
      color: Colors.amber,
      onChanged: (value) {},
      isNumber: true,
    );
  }
}

class JsonNullValue extends StatelessWidget {
  JsonNullValue();

  @override
  Widget build(BuildContext context) {
    return Text(
      'null',
      style: GoogleFonts.inconsolata(color: Colors.amber, fontSize: 16),
    );
  }
}

class JsonEditorItem extends StatefulWidget {
  final dynamic data;
  final Function(dynamic) onDataChanged;
  final VoidCallback onDelete;
  final bool isRoot;

  JsonEditorItem({
    required this.data,
    required this.onDataChanged,
    required this.onDelete,
    this.isRoot = false,
  });

  @override
  _JsonEditorItemState createState() => _JsonEditorItemState();
}

class _JsonEditorItemState extends State<JsonEditorItem> {
  bool collapsed = true;

  @override
  Widget build(BuildContext context) {
    if (widget.isRoot) collapsed = false;
    final data = widget.data;

    Widget child() {
      if (widget.data is Map<String, dynamic>) {
        if (collapsed) return Text('...');

        return JsonMapView(
          data: widget.data,
          onDataChanged: widget.onDataChanged,
        );
      }
      if (widget.data is List<dynamic>) {
        if (collapsed) return Text('...');

        return JsonListView(
          data: widget.data,
          onDataChanged: widget.onDataChanged,
        );
      }
      if (widget.data is String)
        return JsonStringView(
          data: widget.data,
          onDataChanged: widget.onDataChanged,
        );
      if (widget.data is int || widget.data is double)
        return JsonNumberValue(
          data: widget.data,
          onDataChanged: widget.onDataChanged,
        );
      if (widget.data is bool)
        return JsonBooleanView(
          data: widget.data,
          onDataChanged: widget.onDataChanged,
        );

      return JsonNullValue();
    }

    final Widget contextMenu = GenericContextMenu(
      buttonConfigs: [
        if (data is Map<String, dynamic> || data is List<dynamic>) ...[
          if (!widget.isRoot)
            if (collapsed)
              ContextMenuButtonConfig('Expand', onPressed: () => setState(() => collapsed = false))
            else
              ContextMenuButtonConfig('Collapse', onPressed: () => setState(() => collapsed = true)),
          ContextMenuButtonConfig('Add child', onPressed: () {
            if (data is List<dynamic>) data.add('new-value');
            if (data is Map<String, dynamic>) {
              if (!data.containsKey('new-key'))
                data['new-key'] = 'new-value';
              else {
                var i = 1;
                while (data.containsKey('new-key-$i')) i++;
                data['new-key-$i'] = 'new-value';
              }
            }

            widget.onDataChanged(data);
          })
        ],
        if (data != null)
          ContextMenuButtonConfig(
            'Convert to null',
            onPressed: () => widget.onDataChanged(null),
          ),
        if (!(data is String))
          ContextMenuButtonConfig(
            'Convert to string',
            onPressed: () => widget.onDataChanged('string'),
          ),
        if (!(data is bool))
          ContextMenuButtonConfig(
            'Convert to boolean',
            onPressed: () => widget.onDataChanged(false),
          ),
        if (!(data is int || data is double))
          ContextMenuButtonConfig(
            'Convert to number',
            onPressed: () => widget.onDataChanged(100),
          ),
        if (!(data is Map<String, dynamic>))
          ContextMenuButtonConfig(
            'Convert to object',
            onPressed: () => widget.onDataChanged({'foo': 'bar', 'baz': true}),
          ),
        if (!(data is List<dynamic>))
          ContextMenuButtonConfig(
            'Convert to array',
            onPressed: () => widget.onDataChanged(['foo', 'bar']),
          ),
        if (!widget.isRoot) ContextMenuButtonConfig('Delete', onPressed: widget.onDelete),
      ],
    );

    return ContextMenuRegion(
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        IconButton(
          onPressed: () {
            ContextMenuOverlay.of(context).show(contextMenu);
          },
          icon: Icon(
            Icons.arrow_forward,
            color: Colors.grey,
            size: 16,
          ),
          splashRadius: 20,
        ),
        child()
      ]),
      contextMenu: contextMenu,
    );
  }
}

class JsonEditor extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(dynamic) onDataChanged;

  JsonEditor({required this.data, required this.onDataChanged});

  @override
  Widget build(BuildContext context) {
    return JsonEditorItem(
      data: data,
      onDataChanged: onDataChanged,
      onDelete: () {},
      isRoot: true,
    );
  }
}

class JsonInput extends StatefulWidget {
  final String value;
  final Function(String) onChanged;
  final Color color;
  final bool isNumber;

  JsonInput({
    required this.value,
    required this.color,
    required this.onChanged,
    this.isNumber = false,
  });

  @override
  _JsonInputState createState() => _JsonInputState();
}

double sizeMultiplier = 8.28;

class _JsonInputState extends State<JsonInput> {
  double? width;

  @override
  Widget build(BuildContext context) {
    double calculateWidth(String value) {
      if (value.isEmpty) return 50;

      return value.length * sizeMultiplier;
    }

    return SizedBox(
      width: width ?? calculateWidth(widget.value),
      child: TextFormField(
        decoration: InputDecoration(border: InputBorder.none, hintText: 'value'),
        initialValue: widget.value,
        style: GoogleFonts.inconsolata(color: widget.color, fontSize: 16),
        keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
        onChanged: (value) {
          setState(() {
            width = calculateWidth(value);
          });
          widget.onChanged(value);
        },
      ),
    );
  }
}
