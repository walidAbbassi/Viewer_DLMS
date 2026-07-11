import 'package:flutter/material.dart';

class CustomSelect<T> extends StatefulWidget {
  final List<T> options;
  final String Function(T) labelBuilder;
  final void Function(T)? onSelected;
  final String hintText;

  const CustomSelect({
    super.key,
    required this.options,
    required this.labelBuilder,
    this.onSelected,
    this.hintText = "Select an option",
  });

  @override
  State<CustomSelect<T>> createState() => _CustomSelectState<T>();
}

class _CustomSelectState<T> extends State<CustomSelect<T>> {
  T? _selected;

  void _showDialog() async {
    final searchCtrl = TextEditingController();
    List<T> filtered = widget.options;

    final chosen = await showDialog<T>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            void _applyFilter(String query) {
              setDialogState(() {
                filtered = widget.options
                    .where((e) => widget
                        .labelBuilder(e)
                        .toLowerCase()
                        .contains(query.toLowerCase()))
                    .toList();
              });
            }

            return AlertDialog(
              title: Text(widget.hintText),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      key: const Key('custom_select_search_field'),
                      controller: searchCtrl,
                      onChanged: _applyFilter, // live filtering
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: "Search...",
                      ),
                      autofocus: true,
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(child: Text("No results"))
                          : ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (ctx, i) {
                                final item = filtered[i];
                                return ListTile(
                                  title: Text(widget.labelBuilder(item)),
                                  onTap: () => Navigator.pop(ctx, item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (chosen != null) {
      setState(() => _selected = chosen);
      if (widget.onSelected != null) widget.onSelected!(chosen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widget.key,
      onTap: _showDialog,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          _selected != null ? widget.labelBuilder(_selected as T) : widget.hintText,
          style: TextStyle(
            color: _selected != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
