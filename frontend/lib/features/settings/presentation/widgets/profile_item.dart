import 'package:pocketly/core/core.dart';

class ProfileItem extends StatelessWidget {
  const ProfileItem({
    super.key,
    required this.label,
    required this.value,
    this.isEmailVerified = true,
    this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback? onEdit;
  final bool isEmailVerified;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Padding(
        padding: context.symmetric(horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            context.horizontalSpace(20),
            Text(
              value,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (!isEmailVerified)
              IconButton(
                onPressed: () =>
                    context.push('/email-verification', extra: value),
                icon: const Icon(
                  LucideIcons.triangleAlert,
                  size: 16,
                  color: AppColors.warning,
                ),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
          ],
        ),
      ),
    );
  }
}
