import 'package:share_plus/share_plus.dart';

Future<ShareResult> sharePdf(List<XFile> listXFile) async {
  ShareResult shareResult = await Share.shareXFiles([...listXFile]);
  return shareResult;
}
