import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flavors/flavor_config.dart';
import 'package:flutter_mobile_app_presentation/flavors/server_swapper.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/manuals/manuals_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/manuals/manuals_state.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:hugeicons/hugeicons.dart';

class ManualDetailsPage extends StatefulWidget {
  final int id;

  const ManualDetailsPage({super.key, required this.id});

  @override
  State<ManualDetailsPage> createState() => _ManualDetailsPageState();
}

class _ManualDetailsPageState extends State<ManualDetailsPage> {
  final ManualsCubit _cubit = ManualsCubit();

  void refreshOnServerSwap() => _cubit.getManuals();

  @override
  void initState() {
    super.initState();
    _cubit.getManualDetails(widget.id);
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.addListener(refreshOnServerSwap);
    }
  }

  @override
  void dispose() {
    if (Flavor.isStaging()) {
      ServerSwapper.notifier.removeListener(refreshOnServerSwap);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Assets.svgs.applogoIconOnlyBlackNWhite.svg(
              height: 34,
              width: 34,
              package: 'flutter_mobile_app_presentation',
            ),
            Assets.svgs.appLogoTextOnlyWhite.svg(
              width: 100,
              package: 'flutter_mobile_app_presentation',
            ),
          ],
        ),
        leading: Transform.scale(
          scale: 0.7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft02,
                color: context.colorScheme.onSurface,
              ),
              iconSize: 30,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Assets.images.background.image(
              filterQuality: FilterQuality.high,
              package: 'flutter_mobile_app_presentation',
            ),
          ),
          Column(
            children: [
              SizedBox(height: context.viewPadding.top + kToolbarHeight),
              Expanded(
                child: BlocBuilder<ManualsCubit, ManualsState>(
                  bloc: _cubit,
                  builder: (c, state) {
                    return state.maybeWhen(
                      detailRetrieved: (details) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 14)
                              .copyWith(
                                top: 10,
                                bottom: context.viewPadding.bottom + 10,
                              ),
                          child: Column(
                            spacing: 20,
                            children: [
                              Text(
                                details.title,
                                textAlign: TextAlign.center,
                                style: context.textTheme.headlineMedium
                                    ?.copyWith(fontSize: 48),
                              ),
                              Text(
                                'Instruction Manual',
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontSize: 20,
                                  color: context.colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                              HtmlWidget(details.description),
                            ],
                          ),
                        );
                      },
                      loading: () {
                        return Center(child: CircularProgressIndicator());
                      },
                      failure: (error) {
                        return Center(
                          child: Text(
                            'No manual found for the specified device.',
                            style: context.textTheme.titleMedium,
                          ),
                        );
                      },
                      orElse: (_) {
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
