import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportFromSpreadsheetPopup extends StatefulWidget {
  const ImportFromSpreadsheetPopup({super.key});

  @override
  State<ImportFromSpreadsheetPopup> createState() =>
      _ImportFromSpreadsheetPopupState();
}

class _ImportFromSpreadsheetPopupState
    extends State<ImportFromSpreadsheetPopup> {
  PlatformFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import Spreadsheet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload an Excel Spreadsheet from your device'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Select file'),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['xlsx'],
              );

              if (result != null) {
                setState(() {
                  selectedFile = result.files.first;
                });
              }
            },
          ),
          const SizedBox(height: 8),
          if (selectedFile != null)
            Text(
              selectedFile!.name,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed:
              selectedFile != null
                  ? () {
                    // Process the file here
                    Navigator.of(context).pop(selectedFile);
                  }
                  : null,
          child: const Text('Next'),
        ),
      ],
    );
  }
}
