import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ImportFromJsonPopup extends StatefulWidget {
  const ImportFromJsonPopup({super.key});

  @override
  State<ImportFromJsonPopup> createState() => _ImportFromJsonPopupState();
}

class _ImportFromJsonPopupState extends State<ImportFromJsonPopup> {
  PlatformFile? selectedFile;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Import JSON'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Upload a JSON file from your device'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file),
            label: const Text('Select file'),
            onPressed: () async {
              await FilePicker.platform
                  .pickFiles(type: FileType.custom, allowedExtensions: ['json'])
                  .then(
                    (value) => {
                      if (value != null)
                        {
                          setState(() {
                            selectedFile = value.files.first;
                          }),
                        },
                    },
                  );
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
