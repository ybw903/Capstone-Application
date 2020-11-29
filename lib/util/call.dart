import 'package:url_launcher/url_launcher.dart';

class CallHelper {
  launchURL(String callNumber) async {
    final url = 'tel:' + callNumber;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}