import 'package:pocketly/core/core.dart';

class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(value, style: Theme.of(context).textTheme.bodyLarge),
            IconButton(
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
              onPressed: onEdit,
              icon: Icon(
                LucideIcons.pencil,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        context.verticalSpace(4),
        Divider(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          height: 1,
          thickness: 1,
        ),
      ],
    );
  }
}
