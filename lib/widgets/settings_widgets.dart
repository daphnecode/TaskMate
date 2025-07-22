import 'package:flutter/material.dart';

Widget buildSwitchTile({
  required IconData icon,
  required String label,
  required bool value,
  required void Function(bool)? onChanged,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.black), //
        ),
        trailing: IgnorePointer( // ✔️ 눌리지 않게 처리
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
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
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
