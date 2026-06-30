import 'package:flutter/material.dart';

import '../field_notes/presentation/screens/crag_overview_screen.dart';
import '../foundation/theme/ledge_palette.dart';

class CragAppShell extends StatelessWidget {
  const CragAppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crag',
      theme: buildCragTheme(),
      home: const CragOverviewScreen(),
    );
  }
}
