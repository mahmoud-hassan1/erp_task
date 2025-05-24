import 'package:flutter/material.dart';

class TagsSection extends StatefulWidget {
  const TagsSection({super.key,
  required this.tagController,
  required this.tagFocusNode,
  required this.tags,
  });
  final TextEditingController tagController;
  final FocusNode tagFocusNode;
  final List<String> tags;
  @override
  State<TagsSection> createState() => _TagsSectionState();
}

class _TagsSectionState extends State<TagsSection> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const SizedBox(height: 16),
                        const Text('Add Tags:'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: widget.tagController,
                                focusNode: widget.tagFocusNode,
                                onTapOutside: (value) => widget.tagFocusNode.unfocus(),
                                decoration: const InputDecoration(
                                  hintText: 'Enter tag',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addTag,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.tags.map((tag) => ListTile(
                              title: Text(tag),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeTag(tag),
                              ),
                            )),
      ],
    );
  }

   void _addTag() {
    if (widget.tagController.text.isNotEmpty) {
      setState(() {
        widget.tags.add(widget.tagController.text);
        widget.tagController.clear();
      });
    }
  }

 void  _removeTag(String tag) {
    setState(() {
      widget.tags.remove(tag);
    });
  }
}
