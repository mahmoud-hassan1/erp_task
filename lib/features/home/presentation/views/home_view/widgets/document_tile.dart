import 'package:erp_task/core/utils/routes.dart';
import 'package:erp_task/core/utils/widgets/show_snack_bar.dart';
import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentTile extends StatelessWidget {
  const DocumentTile({super.key, required this.document,  required this.currentUserEmail, required this.parentFolderId, required this.path});
  final Document document;
  final String currentUserEmail;
  final String parentFolderId;
  final String path;  


  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(_getDocumentIcon(document.type)),
      title: Text(document.title),
      subtitle: Text(document.type),
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
      } else if (document.type.toLowerCase() == 'doc' || 
                 document.type.toLowerCase() == 'docx' ||
                 document.type.toLowerCase() == 'xls' ||
                 document.type.toLowerCase() == 'xlsx') {
        // Open Office files in web viewer
        final Uri url = Uri.parse('https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(document.docLink)}');
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
          showSnackBar(context, content: 'Could not open the document in web viewer');
          }
        }
      } else {
        // For other file types, try to open with the device's default app
        final Uri url = Uri.parse(document.docLink);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          if (context.mounted) {
            showSnackBar(context, content: 'Could not open the document');
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


}
