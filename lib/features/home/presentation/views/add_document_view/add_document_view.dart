import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/domain/entities/permissions.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:erp_task/features/home/presentation/cubit/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

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
  File? _selectedFile;
  bool _isPublic = false;
  final List<String> _editPermissions = [];
  final List<String> _viewPermissions = [];
  final TextEditingController _viewEmailController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final FocusNode _viewEmailFocusNode = FocusNode();
  final FocusNode _editEmailFocusNode = FocusNode();
  String? _errorMessage;

  bool _isValidFileType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx'].contains(extension);
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      withData: true,
    );
    
    if (result != null) {
      final fileName = result.files.single.name;
      final fileSize = result.files.single.size;
      const maxSize = 100 * 1024 * 1024; // 100MB in bytes

      if (!_isValidFileType(fileName)) {
        setState(() {
          _errorMessage = 'Please select a valid file type (PDF, Word, or Excel)';
          _selectedFile = null;
        });
        return;
      }

      if (fileSize > maxSize) {
        setState(() {
          _errorMessage = 'File size must be less than 100MB';
          _selectedFile = null;
        });
        return;
      }

      setState(() {
        _selectedFile = File(result.files.single.path!);
        _errorMessage = null;
      });
    }
  }

  void _addEditPermission() {
    if (_editEmailController.text.isNotEmpty) {
      setState(() {
        _editPermissions.add(_editEmailController.text);
        _editEmailController.clear();
      });
    }
  }
  void _addViewPermission() {
    if (_viewEmailController.text.isNotEmpty) {
      setState(() {
        _viewPermissions.add(_viewEmailController.text);
        _viewEmailController.clear();
      });
    }
  }
  void _removeEditPermission(String email) {
    setState(() {
      _editPermissions.remove(email);
    });
  }
 void _removeViewPermission(String email) {
    setState(() {
      _viewPermissions.remove(email);
    });
  }
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
          if(state is DocumentError){
            showSnackBar(context, content: state.message);
          }
          else if(state is DocumentLoaded){
            showSnackBar(context, content: state.message);
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                            _selectedFile?.path.split('/').last ?? 'Select File'),
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('Public Document'),
                        value: _isPublic,
                        onChanged: (value) => setState(() => _isPublic = value),
                      ),
                    
                       const SizedBox(height: 16),
                        const Text('Add Edit Permissions:'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _editEmailController,
                                focusNode: _editEmailFocusNode,
                                onTapOutside: (value) => _editEmailFocusNode.unfocus(),
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
                        ..._editPermissions.map((email) => ListTile(
                              title: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeEditPermission(email),
                              ),
                            )),
                              if (!_isPublic) ...[
                        const SizedBox(height: 16),
                        const Text('Add View Permissions:'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _viewEmailController,
                                focusNode: _viewEmailFocusNode,
                                onTapOutside: (value) => _viewEmailFocusNode.unfocus(),
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
                        ..._viewPermissions.map((email) => ListTile(
                              title: Text(email),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () => _removeViewPermission(email),
                              ),
                            )),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _selectedFile == null
                            ? null
                            : () {
                              final Document document = Document(
                                id: '',
                                parentFolderId: widget.parentFolderId,
                                title: _selectedFile?.path.split('/').last ?? '',
                                tags: [],
                                type: _selectedFile?.path.split('.').last ?? '',
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
                              context.read<HomeCubit>().createDocument(document, widget.path, _selectedFile!);
                              },
                        child: const Text('Create Document'),
                      ),
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
    super.dispose();
  }
}
