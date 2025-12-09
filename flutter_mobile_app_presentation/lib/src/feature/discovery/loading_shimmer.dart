import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vibes_common/vibes.dart';

class DiscoveryLoadingShimmer extends StatelessWidget {
  const DiscoveryLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    var prop = Style.showcaseTall;
    return Shimmer.fromColors(
      period: const Duration(milliseconds: 2000),
      baseColor: Colors.grey.withValues(alpha: 0.15),
      highlightColor: Colors.grey.withValues(alpha: 0.1),
      child: ListView.builder(
        itemCount: 4,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const ClampingScrollPhysics(),
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 6),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: _RoundContainer(
                  width: 110,
                  height: 22,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  height: prop.height,
                  child: ListView.separated(
                    separatorBuilder: (BuildContext context, int index) =>
                        SizedBox(
                      width: prop.spacing,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: 3,
                    itemBuilder: (BuildContext context, int index) =>
                        _RowItem(),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundContainer extends StatelessWidget {
  const _RoundContainer({
    required this.width,
    required this.height,
    this.radius = 2,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      width: width,
      height: height,
    );
  }
}

class _RowItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RoundContainer(
            width: 180,
            height: 220,
            radius: 10,
          ),
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: _RoundContainer(width: 124, height: 8),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6),
            child: _RoundContainer(width: 96, height: 8),
          ),
        ],
      ),
    );
  }
}
