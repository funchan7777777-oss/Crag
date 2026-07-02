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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: Container(
              height: 92,
              padding: const EdgeInsets.fromLTRB(12, 38, 16, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF07100F).withValues(alpha: 0.94),
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
          ),
        ],
      ),
    );
  }
}
