import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';

@RoutePage()
class UnderConstructionPage extends StatelessWidget {
  const UnderConstructionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Under Construction'),
    );
  }
}
