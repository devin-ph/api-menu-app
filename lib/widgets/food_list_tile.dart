import 'package:flutter/material.dart';

import '../main.dart' show kPrimary, kAccentGold, kSurface, kTextSecondary;
import '../models/food_item.dart';
import '../utils/food_tags_mapper.dart';

class FoodListTile extends StatefulWidget {
  const FoodListTile({super.key, required this.item, required this.onTap});
  final FoodItem item;
  final VoidCallback onTap;

  @override
  State<FoodListTile> createState() => _FoodListTileState();
}

class _FoodListTileState extends State<FoodListTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tags = deriveTasteTags(widget.item).take(2).toList();

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: kSurface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          splashColor: kPrimary.withValues(alpha: 0.15),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Image
                Hero(
                  tag: 'food-image-${widget.item.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.item.thumbnailUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: const Color(0xFF2A2522),
                        child: const Center(
                          child: Icon(
                            Icons.restaurant_rounded,
                            color: kTextSecondary,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.item.category} • ${normalizeCountryLabel(widget.item.cuisine)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: kAccentGold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            widget.item.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: kAccentGold,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.inventory_2_rounded,
                            size: 14,
                            color: kTextSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${widget.item.ingredients.length} thành phần',
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      if (tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: tags
                              .map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kPrimary.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: kPrimary.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    tag,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: kTextSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
