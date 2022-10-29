import 'package:deep_link_flutter/src/utils/constants.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? _linkMessage;
  bool _isCreatingLink = false;

  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  @override
  void initState() {
    super.initState();
    // initDynamicLink();
  }

  Future<void> initDynamicLink() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        String? productId = queryParams['id'];
        Navigator.restorablePushNamed(context, dynamicLinkData.link.path,
            arguments: {"productId": int.parse(productId!)});
        print('...........');
        print(dynamicLinkData.link.path);
      } else {
        Navigator.restorablePushNamed(context, dynamicLinkData.link.path);
        print('...........');

        print(dynamicLinkData.link.path);
      }
    }).onError((error) {
      if (kDebugMode) {
        print('...........');

        print(
            '...........init dynamic link error.............................');
        print('...........');

        print(error);
      }
    });
  }

  Future<void> _createDynamicLink(bool short, String link) async {
    setState(() {
      _isCreatingLink = true;
    });

    final DynamicLinkParameters dynamicLinkParameters = DynamicLinkParameters(
        link: Uri.parse(kUriPrefix + link),
        uriPrefix: kUriPrefix,
        androidParameters:
            const AndroidParameters(packageName: kPackage, minimumVersion: 0));

    Uri url;
    if (short) {
      final ShortDynamicLink shortDynamicLink =
          await dynamicLinks.buildShortLink(dynamicLinkParameters);
      url = shortDynamicLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(dynamicLinkParameters);
    }
    setState(() {
      _isCreatingLink = false;
      _linkMessage = url.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Deep Link'),
        ),
        body: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ButtonBar(
                    alignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: !_isCreatingLink
                              ? () => _createDynamicLink(false, kHomepageLink)
                              : null,
                          child: const Text("Get Long Link")),
                      ElevatedButton(
                          onPressed: !_isCreatingLink
                              ? () => _createDynamicLink(true, kHomepageLink)
                              : null,
                          child: const Text("Get Short Link")),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      if (_linkMessage != null) {
                        await launch(_linkMessage!);
                      }
                    },
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: _linkMessage));
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Link Copied")));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.all(Radius.elliptical(40, 80)),
                            color: Colors.yellowAccent.shade100),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            _linkMessage ?? "",
                            style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.indigo,
                                fontStyle: FontStyle.italic),
                          ),
                        ),
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => _onShare(context),
                      child: const Text("Share Link")),
                ],
              ),
            );
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  void _onShare(BuildContext context) async {
    // A builder is used to retrieve the context immediately
    // surrounding the ElevatedButton.
    //
    // The context's `findRenderObject` returns the first
    // RenderObject in its descendent tree when it's not
    // a RenderObjectWidget. The ElevatedButton's RenderObject
    // has its position and size after it's built.
    final box = context.findRenderObject() as RenderBox?;
    if (_linkMessage != null) {
      await Share.share(_linkMessage!,
          subject: 'Welcome home',
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      // deep link generated from the console with text message and image
      await Share.share("https://swetajain.page.link/home");
    }
  }
}
