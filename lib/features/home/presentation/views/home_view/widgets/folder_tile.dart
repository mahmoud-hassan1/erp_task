import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/home/domain/entities/folder.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:erp_task/features/home/presentation/views/home_view/widgets/edit_folder_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({super.key, required this.folder, required this.path, required this.currentUserEmail});
  final Folder folder;
  final String path;
  final String currentUserEmail;

  @override
  Widget build(BuildContext context) {
   return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(folder.title),
      onTap: () => context
          .push(AppRoutes.home, extra: [folder.id, 'path/${folder.title}']),
      onLongPress: () =>
         canEditFolder(folder)
              ? _showEditFolderDialog(context, folder)
              : showSnackBar(context,
                  content: 'Only the folder owner can edit the folder'),
    );
  }
    bool canEditFolder(Folder folder){
    return folder.createdBy == currentUserEmail;
  }
    void _showEditFolderDialog(BuildContext context, Folder folder) {
    if(canEditFolder(folder)){
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HomeCubit>(),
        child: EditFolderDialog(
          parentFolderId: folder.id,
          currentPath: path,
          folder: folder,
        ),
      ),
    );
    }
    else{
      showSnackBar(context, content: 'You don\'t have permission to edit this folder');
    }
  }

}