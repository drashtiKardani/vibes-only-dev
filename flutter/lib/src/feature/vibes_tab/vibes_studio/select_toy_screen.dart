import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart' as assets;
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:get_it/get_it.dart';
import 'package:vibes_common/vibes.dart';
import 'package:vibes_only/src/data/commodities_store.dart';
import 'package:vibes_only/src/feature/toy/toy_extension.dart';
import 'package:vibes_only/src/widget/back_button_app_bar.dart';
import 'package:vibes_only/src/widget/vibes_elevated_button.dart';

class SelectToyScreen extends StatefulWidget {
  const SelectToyScreen({super.key, required this.onToySelected});

  final void Function(Commodity value) onToySelected;

  @override
  State<SelectToyScreen> createState() => _SelectToyScreenState();
}

class _SelectToyScreenState extends State<SelectToyScreen> {
  Commodity? selected;

  @override
  Widget build(BuildContext context) {
    List<Commodity> knownToys = GetIt.I<CommoditiesStore>().knownToys;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: BackButtonAppBar(
        context,
        onPressed: () => Navigator.pop(context),
        title: 'Select your product',
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: assets.Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14).copyWith(
              top: context.mediaQuery.viewPadding.top + kToolbarHeight + 10,
              bottom: context.mediaQuery.viewPadding.bottom + 10,
            ),
            child: Column(
              spacing: 12,
              children: [
                Expanded(
                  child: GridView.builder(
                    itemCount: knownToys.length,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      mainAxisExtent: 140,
                    ),
                    itemBuilder: (context, index) {
                      Commodity toy = knownToys[index];
                      return CupertinoButton(
                        onPressed: () {
                          setState(() => selected = toy);
                        },
                        padding: EdgeInsets.zero,
                        child: AnimatedContainer(
                          duration: Durations.medium2,
                          height: double.infinity,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.05),
                            border: selected?.id == toy.id
                                ? Border.all(
                                    color: context.colorScheme.onSurface,
                                  )
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            spacing: 6,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (defaultTargetPlatform !=
                                  TargetPlatform.android)
                                SizedBox.square(
                                  dimension: 74,
                                  child: toy.toyImage,
                                ),
                              Text(
                                toy.name,
                                textAlign: TextAlign.center,
                                style: context.textTheme.titleLarge?.copyWith(
                                    color: context.colorScheme.onSurface),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                VibesElevatedButton(
                  text: 'Next',
                  onPressed: selected != null
                      ? () => widget.onToySelected(selected!)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
