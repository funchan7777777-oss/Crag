import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyWebLedgeScreen extends StatefulWidget {
  const PolicyWebLedgeScreen({
    required this.url,
    required this.screenTitle,
    super.key,
  });

  final String url;
  final String screenTitle;

  @override
  State<PolicyWebLedgeScreen> createState() => _PolicyWebLedgeScreenState();
}

class _PolicyWebLedgeScreenState extends State<PolicyWebLedgeScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Container(
            height: topInset + 54,
            padding: EdgeInsets.fromLTRB(8, topInset, 16, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF07100F),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.24),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.screenTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
    );
  }
}
