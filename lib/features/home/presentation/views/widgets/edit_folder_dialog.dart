import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/folder.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';

class EditFolderDialog extends StatefulWidget {
  final String? parentFolderId;
  final String currentPath;
  final Folder folder;

  const EditFolderDialog({
    super.key,
    this.parentFolderId,
    required this.currentPath,
    required this.folder,
  });

  @override
  State<EditFolderDialog> createState() => _EditFolderDialogState();
}

class _EditFolderDialogState extends State<EditFolderDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  bool _isPublic = false;

 @override
  void initState() {
    _titleController.text = widget.folder.title;
    _isPublic = widget.folder.isPublic;
    super.initState();
  }
  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is FolderLoading) {
        } 
        else if (state is FolderError) {
          showSnackBar(context, content: state.message);
        } 
        else if (state is FolderLoaded) {
          Navigator.pop(context);
        }
      
      },
      builder: (context, state) {
        return AlertDialog(
          title: const Text('Create New Folder'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Folder Name',
                  hintText: 'Enter folder name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a folder name';
                  }
                  return null;
                },
                enabled: state is FolderLoading ? false : true,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public Access'),
                subtitle: const Text('Anyone can view this folder'),
                value: _isPublic,
                onChanged: state is FolderLoading ? null : (value) => setState(() => _isPublic = value),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: state is FolderLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: state is FolderLoading ? null : _updateFolder,
            child: const Text('Save'),
          ),
        ],
      );
  }
    );}


  void  _updateFolder() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.folder.title = _titleController.text;
      widget.folder.isPublic = _isPublic;
      context.read<HomeCubit>().updateFolder(widget.folder);
    }
  }
} 