// Web download helper - this file is used on web platform
import 'dart:html' as html show Blob, Url, AnchorElement;

/// Downloads a file on web platform using blob URL
Future<void> downloadFileWeb(List<int> bytes, String fileName) async {
  // Create a blob from the bytes
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  
  // Create a temporary anchor element and trigger download
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  
  // Clean up the object URL
  html.Url.revokeObjectUrl(url);
}
