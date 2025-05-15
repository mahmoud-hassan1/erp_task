import 'package:erp_task/core/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';
import 'widgets/create_folder_dialog.dart';
import 'widgets/upload_document_dialog.dart';
class HomeView extends StatelessWidget {
  const HomeView({super.key, required this.path, this.parentFolderId});
  final String path;
  final String? parentFolderId;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: FittedBox(fit: BoxFit.scaleDown,child: Text(path)),
              
            leading: state is HomeLoaded && parentFolderId != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  )
                : null,
          ),
          body: _buildBody(context, state),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showCreateDialog(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    if (state is HomeLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is HomeError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              state.message,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<HomeCubit>().loadContent(parentFolderId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is HomeLoaded) {
      if (state.folders.isEmpty && state.documents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'This folder is empty',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the + button to add a folder or document',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
           context.read<HomeCubit>().loadContent(parentFolderId);
        },
        child: ListView(
          children: [
            ...state.folders.map((folder) => _buildFolderTile(context, folder)),
            ...state.documents.map((doc) => _buildDocumentTile(context, doc)),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to Document Manager',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first folder or document',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, Folder folder) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.title),
      onTap: () => context.push(AppRoutes.home, extra: [folder.id, '$path/${folder.title}']),
    );
  }

  Widget _buildDocumentTile(BuildContext context, Document document) {
    return ListTile(
      leading: Icon(_getDocumentIcon(document.type)),
      title: Text(document.title),
      subtitle: Text(document.type),
      onTap: () => _openDocument(context, document),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _openDocument(BuildContext context, Document document) {
    // TODO: Implement document viewer
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening ${document.title}')),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final homeCubit = context.read<HomeCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (bottomSheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Create New',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('New Folder'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showCreateFolderDialog(context, homeCubit);
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Upload Document'),
                onTap: () {
                  Navigator.pop(bottomSheetContext);
                  _showUploadDocumentDialog(context, homeCubit);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, HomeCubit homeCubit) {
    final currentState = homeCubit.state;
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: homeCubit,
        child: CreateFolderDialog(
          parentFolderId: parentFolderId ,
          currentPath: path,
        ),
      ),
    );
  }

  void _showUploadDocumentDialog(BuildContext context, HomeCubit homeCubit) {
    GoRouter.of(context).push(AppRoutes.addDocument, extra: [parentFolderId, path,homeCubit]);
    // final currentState = homeCubit.state;
    // showDialog(
    //   context: context,
    //   builder: (dialogContext) => BlocProvider.value(
    //     value: homeCubit,
    //     child: UploadDocumentDialog(
    //       parentFolderId: parentFolderId ,
    //       currentPath: path,
    //     ),
    //   ),
    // );
  }
}
