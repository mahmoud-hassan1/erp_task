import 'package:flutter/material.dart';

class EditPermissions extends StatefulWidget {
  const EditPermissions(
      {super.key,
      required this.editEmailController,
      required this.editEmailFocusNode,
      required this.editPermissions});
  final TextEditingController editEmailController;
  final FocusNode editEmailFocusNode;
  final List<String> editPermissions;
  @override
  State<EditPermissions> createState() => _EditPermissionsState();
}

class _EditPermissionsState extends State<EditPermissions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text('Add Edit Permissions:'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.editEmailController,
                focusNode: widget.editEmailFocusNode,
                onTapOutside: (value) => widget.editEmailFocusNode.unfocus(),
                decoration: const InputDecoration(
                  hintText: 'Enter email',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addEditPermission,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...widget.editPermissions.map((email) => ListTile(

              title: Text(email),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle),
                onPressed: () => _removeEditPermission(email),
              ),
            )),
      ],
    );
  }

  void _removeEditPermission(String email) {
    setState(() {
      widget.editPermissions.remove(email);
    });
  }

  void _addEditPermission() {
    if (widget.editEmailController.text.isNotEmpty) {
      setState(() {
        widget.editPermissions.add(widget.editEmailController.text);
        widget.editEmailController.clear();
      });
    }
  }
}
