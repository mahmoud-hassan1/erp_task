import 'package:erp_task/core/utils/routes.dart';

import 'package:erp_task/features/auth/domain/repositories/auth_repository.dart';
import 'package:erp_task/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erp_task/features/home/presentation/views/home_view/widgets/document_tile.dart';
import 'package:erp_task/features/home/presentation/views/home_view/widgets/folder_tile.dart';

import 'package:erp_task/features/home/presentation/views/home_view/widgets/empty_folder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../../cubit/home_cubit.dart';
import '../../cubit/home_state.dart';
import 'widgets/create_folder_dialog.dart';


class HomeView extends StatefulWidget {
  const HomeView({super.key, required this.path, this.parentFolderId});
  final String path;
  final String? parentFolderId;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  
  String? currentUserEmail;
  @override
  void initState() {
    super.initState();
    currentUserEmail = GetIt.instance<AuthRepository>().getCurrentUser().fold((l) => null, (r) => r!.email);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: FittedBox(fit: BoxFit.scaleDown, child: Text(widget.path)),
            leading: state is HomeLoaded && widget.parentFolderId != null
                ? IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                  )
                : null,
            actions: [
             widget.parentFolderId == null ? IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                  context.pushReplacement(AppRoutes.login);
                },
              ): const SizedBox(),
            ],
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
                  context.read<HomeCubit>().loadContent(widget.parentFolderId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (context.read<HomeCubit>().foldersList.isEmpty &&
        context.read<HomeCubit>().documentsList.isEmpty) {
      return const EmptyFolder();
    }

    return ModalProgressHUD(
      inAsyncCall: state is DocumentLoading || state is FolderLoading,
      child: RefreshIndicator(
        onRefresh: () async {
          context.read<HomeCubit>().loadContent(widget.parentFolderId);
        },
        child: ListView(
          children: [
            ...context
                .read<HomeCubit>()
                .foldersList
                .map((folder) => FolderTile(folder: folder, path: widget.path, currentUserEmail: currentUserEmail ?? '')),
            ...context
                .read<HomeCubit>()
                .documentsList
                .map((doc) => DocumentTile(document: doc, currentUserEmail: currentUserEmail ?? '', parentFolderId: widget.parentFolderId , path: widget.path)),
          ],
        ),
      ),
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
                  GoRouter.of(context).push(AppRoutes.addDocument,
                      extra: [widget.parentFolderId, widget.path, homeCubit]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context, HomeCubit homeCubit) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: homeCubit,
        child: CreateFolderDialog(
          parentFolderId: widget.parentFolderId,
          currentPath: widget.path,
        ),
      ),
    );
  }


}

