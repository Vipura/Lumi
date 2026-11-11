import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import '../../core/design/design_system.dart';
import '../../data/db/lumi_database.dart';
import 'attachment_service.dart';

/// Records a voice note using `record` and attaches it to [itemId].
Future<Attachment?> showVoiceRecorderSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String itemId,
}) {
  return showLumiGlassBottomSheet<Attachment>(
    context: context,
    title: 'Record Voice Note',
    builder: (ctx) => _VoiceRecorderSheetBody(itemId: itemId),
  );
}

class _VoiceRecorderSheetBody extends ConsumerStatefulWidget {
  const _VoiceRecorderSheetBody({required this.itemId});

  final String itemId;

  @override
  ConsumerState<_VoiceRecorderSheetBody> createState() =>
      _VoiceRecorderSheetBodyState();
}

class _VoiceRecorderSheetBodyState
    extends ConsumerState<_VoiceRecorderSheetBody> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _recording = false;
  bool _saving = false;
  String? _error;
  int _elapsedMs = 0;
  Timer? _timer;
  String? _recordingPath;

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _toggleRecord() async {
    if (_recording) {
      await _stopAndSave();
      return;
    }

    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        setState(() {
          _error = 'Microphone permission was denied.';
        });
        return;
      }

      final service = ref.read(attachmentServiceProvider);
      final dir = await service.ensureAttachmentsDir();
      final outPath = kIsWeb
          ? 'voice_${const Uuid().v4()}.webm'
          : p.join(dir, '${const Uuid().v4()}.m4a');

      await _recorder.start(const RecordConfig(), path: outPath);
      _recordingPath = outPath;
      _elapsedMs = 0;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) {
          setState(() => _elapsedMs += 200);
        }
      });
      setState(() {
        _recording = true;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Could not start microphone on this device ($e).';
      });
    }
  }

  Future<void> _stopAndSave() async {
    _timer?.cancel();
    setState(() {
      _recording = false;
      _saving = true;
    });
    try {
      final resultPath = await _recorder.stop() ?? _recordingPath;
      if (resultPath == null) {
        if (mounted) Navigator.of(context).pop();
        return;
      }
      final attachment = await ref
          .read(attachmentServiceProvider)
          .saveRecordedAudio(
            itemId: widget.itemId,
            sourcePath: resultPath,
            durationMs: _elapsedMs,
          );
      if (mounted) Navigator.of(context).pop(attachment);
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Failed to save recording: $e';
        });
      }
    }
  }

  String _formatDuration(int ms) {
    final totalSec = ms ~/ 1000;
    final mins = (totalSec ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSec % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final ext = context.lumiTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: LumiSpacing.sm),
        Text(
          _formatDuration(_elapsedMs),
          style: Theme.of(context).textTheme.displayMedium
              ?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
        ),
        const SizedBox(height: LumiSpacing.xs),
        Text(
          _recording
              ? 'Recording... tap stop to save'
              : 'Tap the microphone to start recording',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (_error != null) ...[
          const SizedBox(height: LumiSpacing.sm),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: LumiColors.danger),
          ),
        ],
        const SizedBox(height: LumiSpacing.lg),
        GestureDetector(
          onTap: _saving ? null : _toggleRecord,
          child: AnimatedContainer(
            duration: LumiMotion.fast,
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _recording ? LumiColors.danger : ext.accentColor,
              boxShadow: [
                BoxShadow(
                  color: (_recording ? LumiColors.danger : ext.accentColor)
                      .withValues(alpha: 0.45),
                  blurRadius: 24,
                ),
              ],
            ),
            child: _saving
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Icon(
                    _recording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
          ),
        ),
        const SizedBox(height: LumiSpacing.md),
      ],
    );
  }
}
