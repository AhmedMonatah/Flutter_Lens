import 'package:flutter/material.dart';

import 'font_lens_controller.dart';
import 'strings.dart';
import 'tokens.dart';

/// Horizontal scrollable pill filter chips for font families and warnings.
///
/// Automatically adapts padding and sizing dynamically across small screens
/// to tablets and desktop.
class FilterChips extends StatelessWidget {
  const FilterChips({
    super.key,
    required this.controller,
    required this.tokens,
    required this.strings,
  });

  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  Widget build(BuildContext context) {
    final active = controller.activeFilterFamily;
    final families = controller.distinctFamilies;
    final totalGroups = controller.groups.length;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final hPadding = screenWidth < 360 ? 10.0 : 16.0;

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: hPadding),
        children: [
          // All chip
          _buildChip(
            label: '${strings.all} ($totalGroups)',
            selected: active == null,
            onTap: () => controller.setFilterFamily(null),
          ),

          // Family chips
          ...families.map((f) {
            final count = controller.groups
                .where((g) => g.displayFamily == f)
                .length;
            return _buildChip(
              label: '$f ($count)',
              selected: active == f,
              onTap: () => controller.setFilterFamily(active == f ? null : f),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool isWarning = false,
  }) {
    final bg = selected
        ? (isWarning ? tokens.warn : tokens.accent)
        : tokens.raised;
    final fg = selected ? Colors.white : tokens.ink;
    final border = selected
        ? Colors.transparent
        : (isWarning ? tokens.warn.withValues(alpha: 0.3) : tokens.hairline);

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            constraints: const BoxConstraints(minHeight: 38),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: fg,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
