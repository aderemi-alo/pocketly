import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class UserAvatarWidget extends ConsumerWidget {
  const UserAvatarWidget({super.key, this.isSmall = false});

  final bool isSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authProvider).user?.name ?? '';
    final double size = isSmall ? 30 : 60;
    final double iconSize = isSmall ? 14 : 26;
    final double textSize = isSmall ? 16 : 24;

    return SizedBox(
      width: size,
      height: size,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AvatarColorGenerator.generate(name),
        ),
        child: name.isEmpty
            ? Icon(LucideIcons.user, color: AppColors.surface, size: iconSize)
            : Center(
                child: Text(
                  name[0].toUpperCase(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: AppColors.surface,
                    fontSize: textSize,
                  ),
                ),
              ),
      ),
    );
  }
}
