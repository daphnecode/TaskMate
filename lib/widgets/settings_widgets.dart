import 'package:flutter/material.dart';

Widget buildSwitchTile({
  required IconData icon,
  required String label,
  required bool value,
  required void Function(bool)? onChanged,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).iconTheme.color),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),  //
        ),
        trailing: IgnorePointer(
          ignoring: onChanged == null,
          child: Switch(
            value: value,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

Widget buildListTile({
  required IconData icon,
  required String label,
  required String value,
  required void Function()? onTap,
  required BuildContext context,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: const TextStyle(color: Colors.grey)),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    ),
  );
}
