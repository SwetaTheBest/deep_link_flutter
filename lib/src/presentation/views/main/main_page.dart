import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

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
    initDynamicLink();
  }

  Future<void> initDynamicLink() async {
    dynamicLinks.onLink.listen((dynamicLinkData) {
      final Uri uri = dynamicLinkData.link;
      final queryParams = uri.queryParameters;
      if (queryParams.isNotEmpty) {
        String? productId = queryParams['id'];
        Navigator.pushNamed(context, dynamicLinkData.link.path,
            arguments: {"productId": int.parse(productId!)});
      } else {
        Navigator.pushNamed(context, dynamicLinkData.link.path);
      }
    }).onError((error) {
      print(error);
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
                          onPressed: () {}, child: const Text("Get Long Link")),
                      ElevatedButton(
                          onPressed: () {},
                          child: const Text("Get Short Link")),
                    ],
                  )
                ],
              ),
            );
          },
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
