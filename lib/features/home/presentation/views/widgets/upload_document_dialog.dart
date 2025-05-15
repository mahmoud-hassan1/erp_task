import 'dart:io';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/document.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';

class UploadDocumentDialog extends StatefulWidget {
  final String? parentFolderId;
  final String currentPath;

  const UploadDocumentDialog({
    super.key,
    this.parentFolderId,
    required this.currentPath,
  });

  @override
  State<UploadDocumentDialog> createState() => _UploadDocumentDialogState();
}

class _UploadDocumentDialogState extends State<UploadDocumentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isPublic = false;
  File? _selectedFile;
  String? _fileType;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _fileType = result.files.single.extension;
          if (_titleController.text.isEmpty) {
            _titleController.text = result.files.single.name;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeLoading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
          if (state is HomeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is HomeLoaded) {
            Navigator.pop(context);
          }
        }
      },
      child: AlertDialog(
        title: const Text('Upload Document'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Document Title',
                    hintText: 'Enter document title',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a document title';
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'Enter tags (comma-separated)',
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Public Access'),
                  subtitle: const Text('Anyone can view this document'),
                  value: _isPublic,
                  onChanged: _isLoading ? null : (value) => setState(() => _isPublic = value),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_selectedFile?.path.split('/').last ?? 'Select File'),
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Selected: ${_selectedFile!.path.split('/').last}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _uploadDocument,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Upload'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadDocument() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a file')),
        );
        return;
      }

      // final document = Document(
      //   id: DateTime.now().millisecondsSinceEpoch.toString(),
      //   parentFolderId: widget.parentFolderId ?? '',
      //   title: _titleController.text,
      //   tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
      //   type: _fileType ?? '',
      //   docLink: '', // Will be set after upload
      //   createdBy: context.read<AuthCubit>().getCurrentUserEmail() ?? '',
      //   createdAt: DateTime.now(),
      //   permissions: _isPublic ? {'*': 'view'} : {},
      //   isPublic: _isPublic,
      //   comments: [],
      //   currentVersion: 1,
      // );

      // Upload file and create document
      final bytes = await _selectedFile!.readAsBytes();
      // final result = await context.read<HomeCubit>().repository.uploadFile(
      //       'documents/${document.id}',
      //       bytes,
      //       _selectedFile!.path.split('/').last,
      //     );

      // result.fold(
      //   (error) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text('Error uploading file: $error')),
      //     );
      //   },
      //   (docLink) async {
      //     final updatedDocument = Document(
      //       id: document.id,
      //       parentFolderId: document.parentFolderId,
      //       title: document.title,
      //       tags: document.tags,
      //       type: document.type,
      //       docLink: docLink,
      //       createdBy: document.createdBy,
      //       createdAt: document.createdAt,
      //       permissions: document.permissions,
      //       isPublic: document.isPublic,
      //       comments: document.comments,
      //       versionHistory: [
      //         Version(
      //           version: 1,
      //           docLink: docLink,
      //           uploadedAt: DateTime.now(),
      //         ),
      //       ],
      //       currentVersion: 1,
      //     );

      //     await context.read<HomeCubit>().createDocument(updatedDocument);
      //   },
      // );
    }
  }
} 