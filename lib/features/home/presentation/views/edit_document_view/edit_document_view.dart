import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
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
import 'package:get_it/get_it.dart';

import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class EditDocumentView extends StatefulWidget {
  const EditDocumentView({
    super.key, 
    required this.document,
    required this.parentFolderId, 
    required this.path
  });
  
  final Document document;
  final String? parentFolderId;
  final String path;

  @override
  State<EditDocumentView> createState() => _EditDocumentViewState();
}

class _EditDocumentViewState extends State<EditDocumentView> {
  late bool _isPublic;
  late final List<String> _editPermissions;
  late final List<String> _viewPermissions;
  final TextEditingController _viewEmailController = TextEditingController();
  final TextEditingController _editEmailController = TextEditingController();
  final FocusNode _viewEmailFocusNode = FocusNode();
  final FocusNode _editEmailFocusNode = FocusNode();
  String? _errorMessage;
  String? _currentUserEmail;
  List<String> _tags = [];
  final FocusNode _tagFocusNode = FocusNode();
  final TextEditingController _tagController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _isPublic = widget.document.isPublic;
    _editPermissions = List.from(widget.document.permissions.edit);
    _viewPermissions = List.from(widget.document.permissions.view);
    _currentUserEmail = GetIt.instance<AuthRepository>().getCurrentUser().fold((l) => null, (r) => r!.email);
    _tags = List.from(widget.document.tags);  
  }

  bool canDelete(){
    return widget.document.createdBy == _currentUserEmail;
  }
  bool canUpdate(){
   final bool owner= widget.document.createdBy == _currentUserEmail;
   final permissions= widget.document.permissions.edit.contains(_currentUserEmail) ;
   return owner || permissions;
  }
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if(state is DocumentError){
          showSnackBar(context, content: state.message);
        }
        else if(state is DocumentLoaded){
          showSnackBar(context, content: state.message,color: Colors.green);
          context.pop();
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state is DocumentLoading,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Edit Document'),
            ),
            body: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomFilePicker(
                        errorMessage: _errorMessage,
                        document: widget.document,
                      ),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
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
                      const SizedBox(height: 16),
                      TagsSection(
                        tagController: _tagController,
                        tagFocusNode: _tagFocusNode,
                        tags: _tags,
                      ),
                      const SizedBox(height: 24),
                      if(canDelete())
                      ElevatedButton(
                        onPressed: () {
                          context.read<HomeCubit>().deleteDocument(widget.document);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Delete Document'),
                      ),
                      const SizedBox(height: 32),
                      if(canUpdate())
                      ElevatedButton(
                        onPressed: () {
                          final Document updatedDocument = Document(
                            id: widget.document.id,
                            parentFolderId: widget.document.parentFolderId,
                            title: context.read<HomeCubit>().selectedDocFile?.path.split('/').last ?? widget.document.title,
                            tags: _tags,
                            type: context.read<HomeCubit>().selectedDocFile?.path.split('.').last ?? widget.document.type,
                            docLink: widget.document.docLink,
                            createdBy: widget.document.createdBy,
                            createdAt: widget.document.createdAt,
                            currentVersion: widget.document.currentVersion + 1,
                            isPublic: _isPublic,
                            permissions: Permissions(
                              view: _isPublic ? [] : _viewPermissions,
                              edit: _editPermissions,
                            ),
                            comments: widget.document.comments,
                          );
                          
                          context.read<HomeCubit>().updateDocument(updatedDocument, widget.path, context.read<HomeCubit>().selectedDocFile);
                        },
                        child: const Text('Update Document'),
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
