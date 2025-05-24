import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/domain/entities/permissions.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:erp_task/features/home/presentation/cubit/home_state.dart';
import 'package:erp_task/features/home/presentation/views/add_document_view/widgets/custom_file_picker.dart';
import 'package:erp_task/features/home/presentation/views/add_document_view/widgets/edit_permissions.dart';
import 'package:erp_task/features/home/presentation/views/add_document_view/widgets/tags.dart';

import 'package:erp_task/features/home/presentation/views/add_document_view/widgets/view_permissions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddDocumentView extends StatefulWidget {
  const AddDocumentView(
      {super.key, required this.parentFolderId, required this.path});
  final String? parentFolderId;
  final String path;

  @override
  State<AddDocumentView> createState() => _AddDocumentViewState();
}

class _AddDocumentViewState extends State<AddDocumentView> {

  // ignore: prefer_final_fields
  bool _isPublic = false;
  final List<String> _editPermissions = [];
  final List<String> _viewPermissions = [];
  final TextEditingController _viewEmailController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final FocusNode _viewEmailFocusNode = FocusNode();
  final FocusNode _editEmailFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  String? _errorMessage;
  final TextEditingController _titleController = TextEditingController();
  final List<String> _tags = [];
  final FocusNode _tagFocusNode = FocusNode();
  final TextEditingController _tagController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is DocumentError) {
          showSnackBar(context, content: state.message);
        } else if (state is DocumentLoaded) {
          showSnackBar(context, content: state.message, color: Colors.green);
          context.pop();
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is DocumentLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Add Document'),
            ),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        onTapOutside: (value) => _titleFocusNode.unfocus(),
                        decoration: const InputDecoration(
                          hintText: 'Enter title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CustomFilePicker(
                        errorMessage: _errorMessage,
                      ),
                      const SizedBox(height: 16),
                       SwitchListTile(
                        title: const Text('Public Document'),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                      ),
                      EditPermissions(
                        editEmailController: _editEmailController,
                        editEmailFocusNode: _editEmailFocusNode,
                        editPermissions: _editPermissions,
                      ),
                      if (!_isPublic)
                        ViewPermissions(
                          viewEmailController: _viewEmailController,
                          viewEmailFocusNode: _viewEmailFocusNode,
                          viewPermissions: _viewPermissions,
                        ),
                      const SizedBox(height: 8),
                      TagsSection(
                        tagController: _tagController,
                        tagFocusNode: _tagFocusNode,
                        tags: _tags,
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
      onPressed: () {

        if (context.read<HomeCubit>().selectedDocFile == null) {
          showSnackBar(context, content: 'Please select a file');
          return;
        }
        if (_titleController.text.isEmpty) {
          showSnackBar(context, content: 'Please enter a title');
          return;
        }
        final Document document = Document(
          id: '',
          parentFolderId: widget.parentFolderId,
          title: _titleController.text,
          tags: _tags,
          type: context.read<HomeCubit>().selectedDocFile?.path.split('.').last ?? '',
          docLink: '',
          createdBy: '',
          createdAt: DateTime.now(),
          currentVersion: 0,
          isPublic: _isPublic,
          permissions: Permissions(
            view: _isPublic ? [] : _viewPermissions,
            edit: _editPermissions,
          ),
          comments: [],
        );
        context
            .read<HomeCubit>()
            .createDocument(document, widget.path, context.read<HomeCubit>().selectedDocFile!);
      },
      child: const Text('Create Document'),
    )
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }


  @override
  void dispose() {
    _editEmailController.dispose();
    _editEmailFocusNode.dispose();
    _viewEmailController.dispose();
    _viewEmailFocusNode.dispose();
    _titleFocusNode.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
