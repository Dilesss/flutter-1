import 'package:flutter/material.dart';

/// "City: Almaty · 1 of 10" above the list when a filter is on.
class CityFilterRow extends StatelessWidget {
  const CityFilterRow({
    super.key,
    required this.city,
    required this.shown,
    required this.total,
  });

  final String city;
  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Icon(Icons.filter_alt, size: 18),
          const SizedBox(width: 6),
          Text('City: $city · $shown of $total'),
        ],
      ),
    );
  }
}
