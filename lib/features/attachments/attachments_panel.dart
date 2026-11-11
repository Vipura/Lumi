import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/design_system.dart';
import '../../core/utils/file_image_widget.dart';
import '../../data/db/lumi_database.dart';
import '../../data/repositories/lumi_models.dart';
import '../../data/repositories/providers.dart';
import 'attachment_service.dart';
import 'voice_recorder_sheet.dart';

/// Displays image thumbnails, PDFs/files, inline voice note players,
/// and link preview cards for a note, plus an Add Attachment picker.
class AttachmentsPanel extends ConsumerWidget {
  const AttachmentsPanel({super.key, required this.itemId});

  final String itemId;

  Future<void> _showAddAttachmentSheet(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showLumiGlassBottomSheet<void>(
      context: context,
      title: 'Add Attachment',
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttachmentOptionTile(
            icon: Icons.photo_library_rounded,
            label: 'Photo from Gallery',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(attachmentServiceProvider)
                  .pickAndAttachImage(
                    itemId: itemId,
                    source: ImageSource.gallery,
                  );
            },
          ),
          _AttachmentOptionTile(
            icon: Icons.camera_alt_rounded,
            label: 'Take Photo',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(attachmentServiceProvider)
                  .pickAndAttachImage(
                    itemId: itemId,
                    source: ImageSource.camera,
                  );
            },
          ),
          _AttachmentOptionTile(
            icon: Icons.mic_rounded,
            label: 'Record Voice Note',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              if (!context.mounted) return;
              await showVoiceRecorderSheet(
                context: context,
                ref: ref,
                itemId: itemId,
              );
            },
          ),
          _AttachmentOptionTile(
            icon: Icons.attach_file_rounded,
            label: 'File or PDF',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              await ref
                  .read(attachmentServiceProvider)
                  .pickAndAttachFile(itemId: itemId);
            },
          ),
          _AttachmentOptionTile(
            icon: Icons.link_rounded,
            label: 'Web Link Preview',
            onTap: () async {
              Navigator.of(sheetCtx).pop();
              if (!context.mounted) return;
              await _promptForLink(context, ref);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _promptForLink(BuildContext context, WidgetRef ref) async {
    final url = await showLumiTextPromptDialog(
      context: context,
      title: 'Attach Link',
      hintText: 'https://example.com',
      confirmLabel: 'Add Link',
      keyboardType: TextInputType.url,
    );
    if (url != null && url.trim().isNotEmpty) {
      await ref
          .read(attachmentServiceProvider)
          .attachLink(itemId: itemId, rawUrl: url);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attachments =
        ref.watch(itemAttachmentsStreamProvider(itemId)).value ?? const [];
    final ext = context.lumiTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments (${attachments.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            LumiGlassChip(
              label: 'Attach',
              icon: Icons.attach_file_rounded,
              onTap: () => _showAddAttachmentSheet(context, ref),
            ),
          ],
        ),
        if (attachments.isNotEmpty) ...[
          const SizedBox(height: LumiSpacing.sm),
          ...attachments.map((att) {
            final kind = LumiAttachmentKind.fromDb(att.kind);
            return Padding(
              padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
              child: switch (kind) {
                LumiAttachmentKind.image => _ImageAttachmentCard(
                  attachment: att,
                  onDelete: () => ref
                      .read(attachmentsRepositoryProvider)
                      .deleteAttachment(att.id),
                ),
                LumiAttachmentKind.audio => _AudioAttachmentCard(
                  attachment: att,
                  onDelete: () => ref
                      .read(attachmentsRepositoryProvider)
                      .deleteAttachment(att.id),
                ),
                LumiAttachmentKind.link => _LinkAttachmentCard(
                  attachment: att,
                  ext: ext,
                  onDelete: () => ref
                      .read(attachmentsRepositoryProvider)
                      .deleteAttachment(att.id),
                ),
                LumiAttachmentKind.pdf ||
                LumiAttachmentKind.file => _FileAttachmentCard(
                  attachment: att,
                  isPdf: kind == LumiAttachmentKind.pdf,
                  onDelete: () => ref
                      .read(attachmentsRepositoryProvider)
                      .deleteAttachment(att.id),
                ),
              },
            );
          }),
        ],
      ],
    );
  }
}

class _AttachmentOptionTile extends StatelessWidget {
  const _AttachmentOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.xs),
      child: LumiGlass.card(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(
          horizontal: LumiSpacing.md,
          vertical: LumiSpacing.sm,
        ),
        child: Row(
          children: [
            Icon(icon, color: ext.accentColor),
            const SizedBox(width: LumiSpacing.sm),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageAttachmentCard extends StatelessWidget {
  const _ImageAttachmentCard({
    required this.attachment,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onDelete;

  String _resolvePreviewPath() {
    if (attachment.metadataJson != null) {
      try {
        final meta =
            jsonDecode(attachment.metadataJson!) as Map<String, dynamic>;
        final thumb =
            meta['thumbPath'] as String? ?? meta['thumbDataUrl'] as String?;
        if (thumb != null && thumb.isNotEmpty) return thumb;
      } catch (_) {}
    }
    return attachment.path;
  }

  @override
  Widget build(BuildContext context) {
    return LumiGlass.card(
      padding: const EdgeInsets.all(LumiSpacing.xs),
      onTap: () {
        showDialog<void>(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.black87,
            child: Stack(
              children: [
                InteractiveViewer(
                  child: Center(
                    child: buildLocalOrDataImage(
                      attachment.path,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(LumiRadius.sm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: buildLocalOrDataImage(
                _resolvePreviewPath(),
                width: 56,
                height: 56,
              ),
            ),
          ),
          const SizedBox(width: LumiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${(attachment.sizeBytes / 1024).toStringAsFixed(0)} KB • Tap to view',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _AudioAttachmentCard extends StatefulWidget {
  const _AudioAttachmentCard({
    required this.attachment,
    required this.onDelete,
  });

  final Attachment attachment;
  final VoidCallback onDelete;

  @override
  State<_AudioAttachmentCard> createState() => _AudioAttachmentCardState();
}

class _AudioAttachmentCardState extends State<_AudioAttachmentCard> {
  final AudioPlayer _player = AudioPlayer();
  bool _loaded = false;
  bool _playing = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _duration = Duration(milliseconds: widget.attachment.durationMs ?? 0);
    _player.playerStateStream.listen((state) {
      if (!mounted) return;
      final completed = state.processingState == ProcessingState.completed;
      setState(() {
        _playing = state.playing && !completed;
      });
      if (completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
    _player.positionStream.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _player.durationStream.listen((dur) {
      if (dur != null && mounted) setState(() => _duration = dur);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (!_loaded) {
        if (kIsWeb ||
            widget.attachment.path.startsWith('http') ||
            widget.attachment.path.startsWith('blob:')) {
          await _player.setUrl(widget.attachment.path);
        } else {
          await _player.setFilePath(widget.attachment.path);
        }
        _loaded = true;
      }
      if (_playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Unable to play audio: $e')));
      }
    }
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;
    final totalMs = _duration.inMilliseconds.clamp(1, 3600000);
    final ratio = (_position.inMilliseconds / totalMs).clamp(0.0, 1.0);

    return LumiGlass.card(
      padding: const EdgeInsets.symmetric(
        horizontal: LumiSpacing.sm,
        vertical: LumiSpacing.xs,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _togglePlay,
            icon: Icon(
              _playing
                  ? Icons.pause_circle_filled_rounded
                  : Icons.play_circle_filled_rounded,
              color: ext.accentColor,
              size: 36,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: ratio,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(LumiRadius.pill),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(_position)} / ${_fmt(_duration)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }
}

class _LinkAttachmentCard extends StatelessWidget {
  const _LinkAttachmentCard({
    required this.attachment,
    required this.ext,
    required this.onDelete,
  });

  final Attachment attachment;
  final LumiThemeExtension ext;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    String subtitle = attachment.path;
    if (attachment.metadataJson != null) {
      try {
        final meta =
            jsonDecode(attachment.metadataJson!) as Map<String, dynamic>;
        final desc = meta['description'] as String?;
        final host = meta['host'] as String?;
        if (desc != null && desc.isNotEmpty) {
          subtitle = desc;
        } else if (host != null && host.isNotEmpty) {
          subtitle = host;
        }
      } catch (_) {}
    }

    return LumiGlass.card(
      onTap: () async {
        final uri = Uri.tryParse(attachment.path);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      padding: const EdgeInsets.all(LumiSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LumiColors.info.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(LumiRadius.sm),
            ),
            child: const Icon(Icons.public_rounded, color: LumiColors.info),
          ),
          const SizedBox(width: LumiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: ext.inkMuted),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _FileAttachmentCard extends StatelessWidget {
  const _FileAttachmentCard({
    required this.attachment,
    required this.isPdf,
    required this.onDelete,
  });

  final Attachment attachment;
  final bool isPdf;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return LumiGlass.card(
      onTap: () async {
        if (!kIsWeb) {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(attachment.path)], text: attachment.name),
          );
        }
      },
      padding: const EdgeInsets.all(LumiSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (isPdf ? LumiColors.danger : LumiColors.warning)
                  .withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(LumiRadius.sm),
            ),
            child: Icon(
              isPdf
                  ? Icons.picture_as_pdf_rounded
                  : Icons.insert_drive_file_rounded,
              color: isPdf ? LumiColors.danger : LumiColors.warning,
            ),
          ),
          const SizedBox(width: LumiSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  '${(attachment.sizeBytes / 1024).toStringAsFixed(0)} KB',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
