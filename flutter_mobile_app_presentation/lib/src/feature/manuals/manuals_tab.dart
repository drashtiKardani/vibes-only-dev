import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_mobile_app_presentation/flavors.dart';
import 'package:flutter_mobile_app_presentation/gen/assets.gen.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/manuals/manuals_cubit.dart';
import 'package:flutter_mobile_app_presentation/src/cubit/manuals/manuals_state.dart';
import 'package:flutter_mobile_app_presentation/src/feature/manuals/manual_details_page.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';
import 'package:vibes_common/vibes.dart';

class ManualsTab extends StatefulWidget {
  const ManualsTab({super.key});

  @override
  State<ManualsTab> createState() => _ManualsTabState();
}

class _ManualsTabState extends State<ManualsTab> {
  final ManualsCubit _cubit = ManualsCubit();

  void refreshOnServerSwap() => _cubit.getManuals();

  @override
  void initState() {
    super.initState();
    _cubit.getManuals();
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
    return Stack(
      children: [
        Positioned.fill(
          child: Assets.images.background.image(
            filterQuality: FilterQuality.high,
            package: 'flutter_mobile_app_presentation',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14)
              .copyWith(top: context.viewPadding.top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              Text(
                'Manuals',
                style: context.textTheme.displaySmall?.copyWith(
                  fontSize: 24,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  letterSpacing: 0.5,
                ),
              ),
              Expanded(
                child: BlocBuilder<ManualsCubit, ManualsState>(
                  bloc: _cubit,
                  builder: (context, state) {
                    return state.maybeWhen(
                      success: (manuals) {
                        return RefreshIndicator(
                          backgroundColor: context.colorScheme.surface,
                          elevation: 0,
                          color: Colors.white,
                          onRefresh: () async => _cubit.getManuals(),
                          child: ListView.separated(
                            itemCount: manuals.length,
                            padding: const EdgeInsets.only(
                              bottom: kBottomNavigationBarHeight + 90,
                            ),
                            physics: const ClampingScrollPhysics(),
                            separatorBuilder: (context, index) {
                              return const SizedBox(height: 12);
                            },
                            itemBuilder: (context, index) {
                              Manual manual = manuals[index];
                              return _ManualListItem(
                                manual: manual,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ManualDetailsPage(id: manual.id);
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                      orElse: (state) {
                        return const Center(child: CircularProgressIndicator());
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ManualListItem extends StatelessWidget {
  final Manual manual;
  final VoidCallback onPressed;

  const _ManualListItem({required this.manual, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: context.colorScheme.onSurface.withValues(alpha: 0.05),
          border: Border.all(
            color: context.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          spacing: 20,
          children: [
            CachedNetworkImage(
              imageUrl: manual.controllerPagePicture,
              height: 100,
              width: 100,
            ),
            Expanded(
              child: Text(
                manual.name,
                style: context.textTheme.headlineMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
