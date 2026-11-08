import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class FloatingNavItem {
  const FloatingNavItem({
    required this.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Key key;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Floating "pill" navigation bar with an animated selection indicator
/// (the selected tab grows and shows its label) and a gradient add button.
///
/// Stateless and state-management agnostic: selection comes in, taps go out.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAdd,
    required this.addTooltip,
  });

  final List<FloatingNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAdd;
  final String addTooltip;

  static const double height = 68;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: height,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2030) : Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: isDark ? 0.25 : 0.4,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.45 : 0.08,
                      ),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // The selected tab takes half the width; the others share
                    // the rest. Widths animate, so the pill "slides" open.
                    final total = constraints.maxWidth;
                    final selectedWidth = total * 0.5;
                    final otherWidth =
                        (total - selectedWidth) / (items.length - 1);
                    // Clip instead of overflowing while widths animate
                    // (e.g. right after a rotation).
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            _NavPill(
                              item: items[i],
                              selected: i == selectedIndex,
                              width: i == selectedIndex
                                  ? selectedWidth
                                  : otherWidth,
                              onTap: () => onSelected(i),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            _AddButton(onPressed: onAdd, tooltip: addTooltip),
          ],
        ),
      ),
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.item,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final FloatingNavItem item;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  static const _duration = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onPrimary : scheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: GestureDetector(
        key: item.key,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOutCubic,
          width: width,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: selected ? AppTheme.brandGradient : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppTheme.seed.withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: _duration,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  selected ? item.selectedIcon : item.icon,
                  key: ValueKey(selected),
                  color: foreground,
                  size: 24,
                ),
              ),
              Flexible(
                child: AnimatedSize(
                  duration: _duration,
                  curve: Curves.easeOutCubic,
                  child: selected
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: foreground,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.seed.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            key: const Key('add-task'),
            borderRadius: BorderRadius.circular(24),
            onTap: onPressed,
            child: const SizedBox.square(
              dimension: FloatingNavBar.height,
              child: Icon(Icons.add_rounded, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
