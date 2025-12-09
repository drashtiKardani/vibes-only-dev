import 'package:flutter/widgets.dart';
import 'package:flutter_mobile_app_presentation/theme.dart';

class SiliconButton extends StatelessWidget {
  const SiliconButton({super.key, this.child, this.active = false});

  final bool active;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 172,
      height: 172,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: active ? [AppColors.vibesPink, AppColors.vibesPink] : [AppColors.grey19, AppColors.grey2E],
          begin: Alignment.bottomRight,
          end: Alignment.topLeft,
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 145,
        height: 145,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: active
                ? [const Color(0xfff67993), const Color(0xffe6637e), const Color(0xffc54560), const Color(0xffb0344e)]
                : [AppColors.grey11, AppColors.grey1C, AppColors.grey2B, AppColors.grey37],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: child,
      ),
    );
  }
}
