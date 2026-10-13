import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'filter_chips.dart';
import 'font_lens_controller.dart';
import 'group_row.dart';
import 'panel_header.dart';
import 'strings.dart';
import 'tokens.dart';
import 'warning_strip.dart';

/// Non-modal draggable inspector panel with fluid responsive snap heights.
///
/// Adapts dynamically to mobile, tablets, desktop, portrait and landscape
/// screen orientations without hardcoded static dimensions.
class PanelSheet extends StatefulWidget {
  const PanelSheet({
    super.key,
    required this.controller,
    required this.tokens,
    required this.strings,
  });

  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  State<PanelSheet> createState() => _PanelSheetState();
}

class _PanelSheetState extends State<PanelSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _heightAnim;
  double _currentFraction = PanelSnap.half.fraction;

  @override
  void initState() {
    super.initState();
    _currentFraction = widget.controller.snap.fraction;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _heightAnim = Tween<double>(
      begin: _currentFraction,
      end: _currentFraction,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    )..addListener(() {
        setState(() {
          _currentFraction = _heightAnim.value;
        });
      });

    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _animController.dispose();
    super.dispose();
  }

  void _onControllerChange() {
    final target = widget.controller.snap.fraction;
    if ((target - _currentFraction).abs() > 0.01) {
      _animateTo(target);
    }
  }

  void _animateTo(double target) {
    final disableAnim = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnim) {
      setState(() => _currentFraction = target);
      return;
    }
    _heightAnim = Tween<double>(
      begin: _currentFraction,
      end: target,
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0.0);
  }

  void _handleDragUpdate(DragUpdateDetails details, double totalHeight) {
    final deltaFraction = -details.primaryDelta! / totalHeight;
    setState(() {
      _currentFraction = (_currentFraction + deltaFraction).clamp(0.08, 0.94);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;
    PanelSnap target;
    if (velocity < -300) {
      // Swiped up
      target = _currentFraction < 0.35 ? PanelSnap.half : PanelSnap.full;
    } else if (velocity > 300) {
      // Swiped down
      target = _currentFraction > 0.6 ? PanelSnap.half : PanelSnap.collapsed;
    } else {
      // Snap to nearest
      if (_currentFraction < 0.24) {
        target = PanelSnap.collapsed;
      } else if (_currentFraction < 0.64) {
        target = PanelSnap.half;
      } else {
        target = PanelSnap.full;
      }
    }
    widget.controller.setSnap(target);
    _animateTo(target.fraction);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.isVisible) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final totalHeight = screenSize.height;

    // Responsive panel width: 100% on phones, capped and centered on tablets/desktop
    final isTabletOrDesktop = screenSize.width > 600;
    final panelWidth = isTabletOrDesktop
        ? (screenSize.width * 0.88).clamp(380.0, 620.0)
        : screenSize.width;

    // Minimum header height ensuring the top bar is never cut off on landscape/small screens
    final minHeaderHeight = 56.0 + viewPadding.bottom;
    final panelHeight = (totalHeight * _currentFraction).clamp(
      minHeaderHeight,
      (totalHeight - viewPadding.top).clamp(minHeaderHeight, double.infinity),
    );

    // Filter groups
    final activeFilter = widget.controller.activeFilterFamily;
    final groups = widget.controller.groups.where((g) {
      if (activeFilter == null) return true;
      if (activeFilter == '__warnings__') return g.hasWarnings;
      return g.displayFamily == activeFilter;
    }).toList();

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: panelWidth,
        height: panelHeight,
        child: Material(
          elevation: 16,
          shadowColor: Colors.black.withValues(alpha: 0.25),
          color: widget.tokens.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              color: widget.tokens.surface,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                top: BorderSide(color: widget.tokens.hairline, width: 1.2),
                left: BorderSide(color: widget.tokens.hairline, width: 1.2),
                right: BorderSide(color: widget.tokens.hairline, width: 1.2),
              ),
            ),
            child: Column(
              children: [
                // Drag handle and header area
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: (d) =>
                      _handleDragUpdate(d, totalHeight),
                  onVerticalDragEnd: _handleDragEnd,
                  child: PanelHeader(
                    controller: widget.controller,
                    tokens: widget.tokens,
                    strings: widget.strings,
                  ),
                ),

                // Content area (visible in Half and Full states when sufficient height exists)
                if ((panelHeight - minHeaderHeight) >= 130.0)
                  Expanded(
                    child: widget.controller.isSettingsOpen
                        ? _PanelSettingsView(
                            controller: widget.controller,
                            tokens: widget.tokens,
                            strings: widget.strings,
                          )
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              if (constraints.maxHeight < 110.0) {
                                return const SizedBox.shrink();
                              }
                              return Column(
                                children: [
                                  // Warning strip (if any warnings)
                                  WarningStrip(
                                    controller: widget.controller,
                                    tokens: widget.tokens,
                                    strings: widget.strings,
                                  ),

                                  const SizedBox(height: 4),

                                  // Filter chips
                                  FilterChips(
                                    controller: widget.controller,
                                    tokens: widget.tokens,
                                    strings: widget.strings,
                                  ),

                                  const SizedBox(height: 8),

                                  // Scrollable group rows or empty state
                                  Expanded(
                                    child: groups.isEmpty
                                        ? Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(24.0),
                                              child: Text(
                                                widget.strings.emptyState,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: widget.tokens.inkMuted,
                                                ),
                                              ),
                                            ),
                                          )
                                        : ListView.builder(
                                            padding: EdgeInsets.only(
                                              bottom: viewPadding.bottom + 12,
                                            ),
                                            itemCount: groups.length,
                                            itemBuilder: (ctx, i) {
                                              final group = groups[i];
                                              final isSelected = widget
                                                      .controller
                                                      .selectedGroupKey ==
                                                  group.key;
                                              return GroupRow(
                                                group: group,
                                                isSelected: isSelected,
                                                onTap: () => widget.controller
                                                    .selectGroup(group.key),
                                                tokens: widget.tokens,
                                                strings: widget.strings,
                                              );
                                            },
                                          ),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// In-panel responsive settings view (zero external dependencies).
class _PanelSettingsView extends StatelessWidget {
  const _PanelSettingsView({
    required this.controller,
    required this.tokens,
    required this.strings,
  });

  final FontLensController controller;
  final FontLensTokens tokens;
  final FontLensStrings strings;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.viewPaddingOf(context);

    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, viewPadding.bottom + 16),
      children: [
        // Section Header: Theme
        Text(
          strings.theme,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: tokens.inkMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChoiceChip(
              label: strings.themeDevice,
              icon: Icons.smartphone_rounded,
              selected: controller.themeMode == FontLensThemeMode.device,
              onTap: () => controller.setThemeMode(FontLensThemeMode.device),
            ),
            _buildChoiceChip(
              label: strings.themeLight,
              icon: Icons.light_mode_rounded,
              selected: controller.themeMode == FontLensThemeMode.light,
              onTap: () => controller.setThemeMode(FontLensThemeMode.light),
            ),
            _buildChoiceChip(
              label: strings.themeDark,
              icon: Icons.dark_mode_rounded,
              selected: controller.themeMode == FontLensThemeMode.dark,
              onTap: () => controller.setThemeMode(FontLensThemeMode.dark),
            ),
            _buildChoiceChip(
              label: strings.themeApp,
              icon: Icons.palette_outlined,
              selected: controller.themeMode == FontLensThemeMode.app,
              onTap: () => controller.setThemeMode(FontLensThemeMode.app),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Section Header: Language
        Text(
          strings.language,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: tokens.inkMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildChoiceChip(
              label: strings.langDevice,
              icon: Icons.language_rounded,
              selected: controller.locale == null,
              onTap: () => controller.setLocale(null),
            ),
            _buildChoiceChip(
              label: strings.langEn,
              icon: Icons.translate_rounded,
              selected: controller.locale?.languageCode == 'en',
              onTap: () => controller.setLocale(const Locale('en')),
            ),
            _buildChoiceChip(
              label: strings.langAr,
              icon: Icons.translate_rounded,
              selected: controller.locale?.languageCode == 'ar',
              onTap: () => controller.setLocale(const Locale('ar')),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Action: Copy JSON
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(strings.copyJson),
            style: OutlinedButton.styleFrom(
              foregroundColor: tokens.accent,
              side: BorderSide(color: tokens.hairline),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              final json = controller.scanResult != null
                  ? const JsonEncoder.withIndent('  ')
                      .convert(controller.scanResult!.toJson())
                  : '{}';
              Clipboard.setData(ClipboardData(text: json));
              ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                SnackBar(
                  content: Text(strings.copied),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),


        const SizedBox(height: 8),

        // Action: Done / Back
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: tokens.accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: controller.closeSettings,
            child: Text(strings.ok, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? tokens.accent.withValues(alpha: 0.12)
              : tokens.raised,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? tokens.accent : tokens.hairline,
            width: selected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? tokens.accent : tokens.inkMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? tokens.accent : tokens.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
