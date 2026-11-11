import 'dart:io';

import 'package:flutter/material.dart';

Widget buildLocalOrDataImage(
  String path, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  if (path.startsWith('data:') ||
      path.startsWith('http://') ||
      path.startsWith('https://')) {
    return Image.network(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, _, _) => const Icon(Icons.broken_image_outlined),
  );
}
