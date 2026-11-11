import 'dart:convert';

/// Utilities for Quill Delta JSON parsing, plain-text extraction,
/// auto-titling, word counting, and Markdown conversion.
abstract final class DeltaUtils {
  /// Returns an empty Quill Delta document JSON string.
  static String emptyDeltaJson() => jsonEncode([
    {'insert': '\n'},
  ]);

  /// Builds a Quill Delta JSON document from plain text.
  static String deltaJsonFromPlainText(String text) {
    final normalized = text.endsWith('\n') ? text : '$text\n';
    return jsonEncode([
      {'insert': normalized},
    ]);
  }

  /// Extracts readable plain text from a Quill Delta JSON string.
  static String plainTextFromDeltaJson(String? rawJson) {
    if (rawJson == null || rawJson.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(rawJson);
      final List<dynamic> ops;
      if (decoded is List) {
        ops = decoded;
      } else if (decoded is Map && decoded['ops'] is List) {
        ops = decoded['ops'] as List<dynamic>;
      } else {
        return rawJson;
      }

      final buffer = StringBuffer();
      for (final op in ops) {
        if (op is Map && op['insert'] is String) {
          buffer.write(op['insert'] as String);
        } else if (op is Map && op['insert'] is Map) {
          buffer.write(' ');
        }
      }
      return buffer.toString().trimRight();
    } catch (_) {
      return rawJson;
    }
  }

  /// Derives a crisp note title from explicit title or the first non-empty line.
  static String deriveTitle({
    required String explicitTitle,
    required String plainText,
    String fallback = 'Untitled note',
  }) {
    final trimmed = explicitTitle.trim();
    if (trimmed.isNotEmpty) return trimmed;
    for (final line in plainText.split('\n')) {
      final candidate = line.trim();
      if (candidate.isNotEmpty) {
        return candidate.length > 64
            ? '${candidate.substring(0, 61)}...'
            : candidate;
      }
    }
    return fallback;
  }

  /// Counts words in plain text.
  static int wordCount(String plainText) {
    final trimmed = plainText.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  /// Converts Quill Delta JSON into clean Markdown for export.
  static String markdownFromDeltaJson(String? rawJson, {String? title}) {
    final buffer = StringBuffer();
    if (title != null && title.trim().isNotEmpty) {
      buffer.writeln('# ${title.trim()}');
      buffer.writeln();
    }
    if (rawJson == null || rawJson.trim().isEmpty) {
      return buffer.toString();
    }
    try {
      final decoded = jsonDecode(rawJson);
      final ops = decoded is List
          ? decoded
          : (decoded is Map && decoded['ops'] is List)
          ? decoded['ops'] as List<dynamic>
          : const <dynamic>[];

      final lines = <String>[];
      var currentLine = StringBuffer();

      for (final op in ops) {
        if (op is! Map) continue;
        final insert = op['insert'];
        if (insert is! String) continue;
        final attrs =
            (op['attributes'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

        final parts = insert.split('\n');
        for (var i = 0; i < parts.length; i++) {
          var segment = parts[i];
          if (segment.isNotEmpty) {
            if (attrs['code'] == true) {
              segment = '`$segment`';
            } else {
              if (attrs['bold'] == true) segment = '**$segment**';
              if (attrs['italic'] == true) segment = '*$segment*';
              if (attrs['strike'] == true) segment = '~~$segment~~';
              if (attrs['link'] is String) {
                segment = '[$segment](${attrs['link']})';
              }
            }
            currentLine.write(segment);
          }

          if (i < parts.length - 1) {
            var lineText = currentLine.toString();
            final header = attrs['header'];
            final listAttr = attrs['list'];
            if (header is int) {
              lineText = '${'#' * header.clamp(1, 6)} $lineText';
            } else if (attrs['blockquote'] == true) {
              lineText = '> $lineText';
            } else if (attrs['code-block'] == true) {
              lineText = '    $lineText';
            } else if (listAttr == 'ordered') {
              lineText = '1. $lineText';
            } else if (listAttr == 'bullet') {
              lineText = '- $lineText';
            } else if (listAttr == 'checked') {
              lineText = '- [x] $lineText';
            } else if (listAttr == 'unchecked') {
              lineText = '- [ ] $lineText';
            }
            lines.add(lineText);
            currentLine = StringBuffer();
          }
        }
      }

      if (currentLine.isNotEmpty) {
        lines.add(currentLine.toString());
      }

      buffer.write(lines.join('\n'));
      return buffer.toString().trimRight();
    } catch (_) {
      buffer.write(plainTextFromDeltaJson(rawJson));
      return buffer.toString();
    }
  }

  /// Generates a deterministic positive 31-bit integer notification ID from UUID.
  static int deterministicNotificationId(String uuid) {
    var hash = 0x811c9dc5;
    for (final unit in uuid.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
