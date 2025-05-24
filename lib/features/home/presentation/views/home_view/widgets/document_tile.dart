
import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.document,  required this.currentUserEmail,  this.parentFolderId, required this.path});
  final Document document;
  final String currentUserEmail;
  final String? parentFolderId;
  final String path;  


  @override
  Widget build(BuildContext context) {
    int titleFlex= 1;
    int tagsFlex= 1;
      if(document.tags.join(', ').length-document.title.length<-10){
        titleFlex= 2;
        tagsFlex= 1;
      }
   
    return ListTile(
      leading: _getDocumentIcon(document.type),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: titleFlex,
            child: Text(
              '${document.title}.${document.type}',
              style: const TextStyle(fontSize: 16),
              softWrap: true,
              maxLines: null,
    
              overflow: TextOverflow.visible,
            ),
          ),
          const SizedBox(width: 8),
          if (document.tags.isNotEmpty)
            Expanded(
              flex: tagsFlex,
              child: Text(
                document.tags.join(', '),
                style: const TextStyle(fontSize: 12),
                softWrap: true,
                maxLines: null,
                textAlign: TextAlign.end,
                overflow: TextOverflow.visible,
              ),
            ),
        ],
      ),
      onTap: () => _openDocument(context, document),
      onLongPress: () => canEditDocument(document)
          ? GoRouter.of(context).push(AppRoutes.editDocument, extra: [
              document,
              parentFolderId,
              path,
              context.read<HomeCubit>()
            ])
          : showSnackBar(context,
              content: 'You don\'t have permission to edit this document'),
    );
  }
    Icon _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return const Icon(Icons.picture_as_pdf,color: Colors.redAccent,);
      case 'doc':
      case 'docx':
        return const Icon(Icons.description,color: Colors.blue,);
      case 'xls':
      case 'xlsx':
        return const Icon(Icons.table_chart);
      default:
        return const Icon(Icons.insert_drive_file);
    }
  }

  void _openDocument(BuildContext context, Document document) async {
    try {
      if (document.type.toLowerCase() == 'pdf') {
  
        GoRouter.of(context).push(AppRoutes.documentView, extra: [document]);
      } else if (document.type.toLowerCase() == 'doc' || 
                 document.type.toLowerCase() == 'docx' ||
                 document.type.toLowerCase() == 'xls' ||
                 document.type.toLowerCase() == 'xlsx') {

        final Uri url = Uri.parse(document.docLink);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
          showSnackBar(context, content: 'Could not open the document in web viewer');
          }
        }
      } 
    } catch (e) {
      if (context.mounted) {
        showSnackBar(context, content: 'Error opening document: $e');
      }
    }
  }

  bool canEditDocument(Document document){
    return document.createdBy == currentUserEmail || document.permissions.edit.contains(currentUserEmail);
  }

// Future<void> downloadAndOpenDoc(String url, String fileName) async {
//   try {
//     final dir = await getTemporaryDirectory();
//     final filePath = '${dir.path}/$fileName';
    
//     // Download file
//     await Dio().download(url, filePath);

//     // Open it with system default app
//     final result = await OpenFilex.open(filePath);
//     print('File opened: ${result.message}');
//   } catch (e) {
//     print('Error opening file: $e');
//   }
// }
}
