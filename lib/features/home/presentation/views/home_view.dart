import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erp_task/features/home/presentation/views/widgets/edit_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/document.dart';
import 'widgets/create_folder_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

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
            title: FittedBox(fit: BoxFit.scaleDown, child: Text(path)),
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
              onPressed: () =>
                  context.read<HomeCubit>().loadContent(parentFolderId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (context.read<HomeCubit>().foldersList.isEmpty &&
        context.read<HomeCubit>().documentsList.isEmpty) {
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
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.6),
                  ),
            ),
          ],
        ),
      );
    }

    return ModalProgressHUD(
      inAsyncCall: state is DocumentLoading || state is FolderLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeCubit>().loadContent(parentFolderId);
        },
        child: ListView(
          children: [
            ...context
                .read<HomeCubit>()
                .foldersList
                .map((folder) => _buildFolderTile(context, folder)),
            ...context
                .read<HomeCubit>()
                .documentsList
                .map((doc) => _buildDocumentTile(context, doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildFolderTile(BuildContext context, Folder folder) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.title),
      onTap: () => context
          .push(AppRoutes.home, extra: [folder.id, '$path/${folder.title}']),
      onLongPress: () =>
          folder.createdBy == context.read<AuthCubit>().getCurrentUserEmail()
              ? _showEditFolderDialog(context, folder)
              : showSnackBar(context,
                  content: 'Only the folder owner can edit the folder'),
    );
  }

  Widget _buildDocumentTile(BuildContext context, Document document) {
    return ListTile(
      leading: Icon(_getDocumentIcon(document.type)),
      title: Text(document.title),
      subtitle: Text(document.type),
      onTap: () => _openDocument(context, document),
      onLongPress: () => document.createdBy ==
                  context.read<AuthCubit>().getCurrentUserEmail() ||
              document.permissions.edit
                  .contains(context.read<AuthCubit>().getCurrentUserEmail())
          ? GoRouter.of(context).push(AppRoutes.editDocument, extra: [
              document,
              parentFolderId,
              path,
              context.read<HomeCubit>()
            ])
          : showSnackBar(context,
              content: 'Only the document owner can edit the document'),
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

  void _openDocument(BuildContext context, Document document) async {
    try {
      if (document.type.toLowerCase() == 'pdf') {
        // Open PDF in the app using SfPdfViewer
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(
                title: Text(document.title),
              ),
              body: SfPdfViewer.network(document.docLink),
            ),
          ),
        );
      } else {
        // For other file types, try to open with the device's default app
        final Uri url = Uri.parse(document.docLink);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          // If URL launch fails, try opening as a file
          final result = await OpenFile.open(document.docLink);
          if (result.type != ResultType.done) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Could not open the document: ${result.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                  GoRouter.of(context).push(AppRoutes.addDocument,
                      extra: [parentFolderId, path, homeCubit]);
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
          parentFolderId: parentFolderId,
          currentPath: path,
        ),
      ),
    );
  }

  void _showEditFolderDialog(BuildContext context, Folder folder) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: EditFolderDialog(
          parentFolderId: parentFolderId,
          currentPath: path,
          folder: folder,
        ),
      ),
    );
  }
}
