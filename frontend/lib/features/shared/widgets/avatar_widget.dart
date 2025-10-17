import 'package:pocketly/core/core.dart';
import 'package:pocketly/features/features.dart';

class UserAvatarWidget extends ConsumerWidget {
  const UserAvatarWidget({
    super.key,
    this.textPadding = const EdgeInsets.all(20),
    this.iconPadding = const EdgeInsets.all(14),
    this.textSize = 20,
    this.iconSize = 26,
  });

  final EdgeInsets textPadding, iconPadding;
  final double textSize, iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(authProvider).user?.name ?? '';

    return Container(
      padding: name.isEmpty ? iconPadding : textPadding,
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
    );
  }
}
