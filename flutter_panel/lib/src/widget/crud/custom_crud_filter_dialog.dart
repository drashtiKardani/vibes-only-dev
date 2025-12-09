import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_panel/src/di/di.dart';

class CustomCrudFilterDialog extends StatelessWidget {
  final List<Map<String, dynamic>> options;
  final Function(Map<String, dynamic> option) onItemClick;
  final String? title;
  const CustomCrudFilterDialog({super.key, required this.options, required this.onItemClick, this.title});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: 38 * (options.length + 1),
        width: MediaQuery.of(context).size.width * 0.3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                title ?? strings.orderBy,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const Divider(
              height: 0,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) => _buildItem(context, options[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onItemClick.call(item);
          AutoRouter.of(context).maybePop();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
          child: Text(item['display']),
        ),
      ),
    );
  }
}
