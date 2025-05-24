import 'package:flutter/material.dart';

class ViewPermissions extends StatefulWidget {
  const ViewPermissions({super.key,
  required this.viewEmailController,
  required this.viewEmailFocusNode,
  required this.viewPermissions,
  });
  final TextEditingController viewEmailController;
  final FocusNode viewEmailFocusNode;
  final List<String> viewPermissions;
  @override
  State<ViewPermissions> createState() => _ViewPermissionsState();
}

class _ViewPermissionsState extends State<ViewPermissions> {
  @override
  Widget build(BuildContext context) {
    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         const SizedBox(height: 16),
                        const Text('Add View Permissions:'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: widget.viewEmailController,
                                focusNode: widget.viewEmailFocusNode,
                                onTapOutside: (value) => widget.viewEmailFocusNode.unfocus(),
                                decoration: const InputDecoration(
                                  hintText: 'Enter email',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addViewPermission,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...widget.viewPermissions.map((email) => ListTile(
               
                              title: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeViewPermission(email),
                              ),
                            )),
      ],
    );
  }

   void _addViewPermission() {
    if (widget.viewEmailController.text.isNotEmpty) {
      setState(() {
        widget.viewPermissions.add(widget.viewEmailController.text);
        widget.viewEmailController.clear();
      });
    }
  }

 void _removeViewPermission(String email) {
    setState(() {
      widget.viewPermissions.remove(email);
    });
  }
}
