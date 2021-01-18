import 'package:url_launcher/url_launcher.dart';

launcherPremium() async {
  const _url = "https://note.com/na8/n/nc01d7cbb1d92";

  if(await canLaunch(_url)) {
    await launch(_url);
  } else {
    throw "Could not launch $_url";
  }
}
