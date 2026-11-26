import 'package:flutter/material.dart';

/// "Show users from": All cities + every city of the loaded users.
class CityDropdown extends StatelessWidget {
  const CityDropdown({
    super.key,
    required this.cities,
    required this.selected,
    required this.onChanged,
  });

  final List<String> cities;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<String?>(
        initialValue: selected,
        decoration: const InputDecoration(
          labelText: 'Show users from',
          prefixIcon: Icon(Icons.location_city),
        ),
        items: [
          const DropdownMenuItem<String?>(child: Text('All cities')),
          for (final c in cities)
            DropdownMenuItem<String?>(value: c, child: Text(c)),
        ],
        onChanged: onChanged,
      ),
    );
  }
}
