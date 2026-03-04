import 'package:beariscope/components/beariscope_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libkoala/libkoala.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:qr_flutter/qr_flutter.dart';

class DeviceProvisioningPage extends ConsumerWidget {
  const DeviceProvisioningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final credentialsAsync = ref.watch(deviceCredentialsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Device Provisioning')),
      body: credentialsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.error_rounded, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Could not load device credentials',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed:
                          () => ref.invalidate(deviceCredentialsProvider),
                      icon: const Icon(Symbols.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
        data: (credentials) => _CredentialsView(credentials: credentials),
      ),
    );
  }
}

class _CredentialsView extends StatelessWidget {
  final DeviceCredentials credentials;

  const _CredentialsView({required this.credentials});

  @override
  Widget build(BuildContext context) {
    final qrPayload = credentials.toQrPayload();
    final colorScheme = Theme.of(context).colorScheme;

    return BeariscopeCardList(
      children: [
        Column(
          children: [
            Text(
              'Scan this QR code with a Pawfinder device to provision it.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'All devices share the same credentials. Keep this screen private.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 0),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withAlpha(40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: QrImageView(
            data: qrPayload,
            version: QrVersions.auto,
            size: 280,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 0),
        _CopyButton(label: 'Copy QR payload', value: qrPayload),
      ],
    );
  }
}

class _FieldTile extends StatefulWidget {
  final String label;
  final String value;
  final bool obscure;

  const _FieldTile({required this.label, required this.value});

  @override
  State<_FieldTile> createState() => _FieldTileState();
}

class _FieldTileState extends State<_FieldTile> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final display =
        widget.obscure && !_revealed ? '••••••••••••••••' : widget.value;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(widget.label),
        subtitle: Text(
          display,
          style: const TextStyle(fontFamily: 'monospace'),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.obscure)
              IconButton(
                icon: Icon(
                  _revealed
                      ? Symbols.visibility_off_rounded
                      : Symbols.visibility_rounded,
                ),
                tooltip: _revealed ? 'Hide' : 'Reveal',
                onPressed: () => setState(() => _revealed = !_revealed),
              ),
            IconButton(
              icon: const Icon(Symbols.content_copy_rounded),
              tooltip: 'Copy',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.value));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.label} copied')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String label;
  final String value;

  const _CopyButton({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: value));
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
        }
      },
      icon: const Icon(Symbols.content_copy_rounded),
      label: Text(label),
    );
  }
}
