import 'dart:io';

import 'package:erp_task/features/home/domain/entities/document.dart';
import 'package:erp_task/features/home/presentation/cubit/home_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ignore: must_be_immutable
class CustomFilePicker extends StatefulWidget {
  CustomFilePicker({
    super.key,
    this.document,
    required this.errorMessage,
  });

  String? errorMessage;
  Document? document;

  @override
  State<CustomFilePicker> createState() => _CustomFilePickerState();
}

class _CustomFilePickerState extends State<CustomFilePicker> {

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  context.read<HomeCubit>().selectedDocFile?.path.split('/').last ?? 
                  (widget.document != null ? "${widget.document!.title}.${widget.document!.type}" : 'Select File'),
                ),
              ),
            ),
          ],
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.errorMessage!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

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
      const maxSize = 20 * 1024 * 1024;

      if (!_isValidFileType(fileName)) {
        setState(() {
          widget.errorMessage =
              'Please select a valid file type (PDF, Word, or Excel)';
       
          context.read<HomeCubit>().selectedDocFile = null;
        });
        return;
      }

      if (fileSize > maxSize) {
        setState(() {
          widget.errorMessage = 'File size must be less than 20MB';
       
          context.read<HomeCubit>().selectedDocFile = null;
        });
        return;
      }

      setState(() {
        context.read<HomeCubit>().selectedDocFile = File(result.files.single.path!);
        widget.errorMessage = null;
      });
    }
  }
}
