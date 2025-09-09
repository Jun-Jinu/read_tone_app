import 'package:flutter/material.dart';

class SettingsMenuItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showTrailingIcon;
  final Widget? trailing;

  const SettingsMenuItem({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.showTrailingIcon = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: showTrailingIcon
          ? const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.grey,
            )
          : trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
      minVerticalPadding: 0,
    );
  }
}
