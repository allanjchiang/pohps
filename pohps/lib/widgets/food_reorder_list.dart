import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// One row in [FoodReorderList].
class FoodReorderEntry {
  final String id;
  final String emoji;
  final String title;
  final String? subtitle;

  const FoodReorderEntry({
    required this.id,
    required this.emoji,
    required this.title,
    this.subtitle,
  });
}

/// Large, accessible list for reordering foods with arrows and drag handles.
class FoodReorderList extends StatelessWidget {
  final List<FoodReorderEntry> entries;
  final void Function(int from, int to) onReorder;

  const FoodReorderList({
    super.key,
    required this.entries,
    required this.onReorder,
  });

  void _moveBy(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= entries.length) return;
    onReorder(index, target);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Material(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 22,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.reorderHint,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          itemCount: entries.length,
          onReorder: (oldIndex, newIndex) {
            var target = newIndex;
            if (target > oldIndex) target -= 1;
            onReorder(oldIndex, target);
          },
          itemBuilder: (context, index) {
            final entry = entries[index];
            final isFirst = index == 0;
            final isLast = index == entries.length - 1;

            return Card(
              key: ValueKey(entry.id),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    ReorderableDragStartListener(
                      index: index,
                      child: Semantics(
                        label: l10n.dragToReorder,
                        button: true,
                        child: SizedBox(
                          width: 52,
                          height: 56,
                          child: Icon(
                            Icons.drag_handle,
                            size: 30,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Text(entry.emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.title,
                            style: theme.textTheme.titleMedium,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (entry.subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.subtitle!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton.filledTonal(
                          onPressed: isFirst ? null : () => _moveBy(index, -1),
                          icon: const Icon(Icons.arrow_upward, size: 26),
                          tooltip: l10n.moveUp,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                        const SizedBox(height: 4),
                        IconButton.filledTonal(
                          onPressed: isLast ? null : () => _moveBy(index, 1),
                          icon: const Icon(Icons.arrow_downward, size: 26),
                          tooltip: l10n.moveDown,
                          style: IconButton.styleFrom(
                            minimumSize: const Size(48, 48),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
