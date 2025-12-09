import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/feature/toy/toy_extension.dart';

class KnownToysGridView extends StatelessWidget {
  final Commodity? toy;
  final List<Commodity> knownToys;
  final void Function(Commodity value) onToySelected;

  const KnownToysGridView({
    super.key,
    required this.toy,
    required this.knownToys,
    required this.onToySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: knownToys.length,
      padding: EdgeInsets.zero,
      physics: ClampingScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      itemBuilder: (context, index) {
        Commodity toy = knownToys[index];
        return CupertinoButton(
          onPressed: () => onToySelected(toy),
          padding: EdgeInsets.zero,
          child: AnimatedContainer(
            duration: Durations.medium2,
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurface.withValues(alpha: 0.05),
              border: this.toy?.id == toy.id
                  ? Border.all(color: context.colorScheme.onSurface)
                  : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (defaultTargetPlatform != TargetPlatform.android)
                  SizedBox.square(dimension: 74, child: toy.toyImage),
                Text(
                  toy.name,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleLarge?.copyWith(
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
