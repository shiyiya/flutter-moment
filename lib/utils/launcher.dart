import 'package:moment/utils/toast.dart';
import 'package:url_launcher/url_launcher.dart';

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    showShortToast('未安装应用商店');
  }
}
