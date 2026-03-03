import 'package:flutter/material.dart';

import '../main.dart' show kPrimary, kAccentGold, kSurface, kTextSecondary;
import '../models/food_item.dart';
import '../utils/food_tags_mapper.dart';

class FoodCard extends StatefulWidget {
  const FoodCard({super.key, required this.item, required this.onTap});

  final FoodItem item;
  final VoidCallback onTap;

  @override
  State<FoodCard> createState() => _FoodCardState();
}

class _FoodCardState extends State<FoodCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tasteTag = primaryTasteTag(widget.item);

    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          splashColor: kPrimary.withValues(alpha: 0.18),
          highlightColor: kPrimary.withValues(alpha: 0.08),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Hero image fills the entire card
              Hero(
                tag: 'food-image-${widget.item.id}',
                child: Image.network(
                  widget.item.thumbnailUrl,
                  fit: BoxFit.cover,
                  semanticLabel: 'Anh mon ${widget.item.name}',
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      color: kSurface,
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: kPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    color: kSurface,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: kTextSecondary,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.42, 0.75, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.0),
                        Colors.black.withValues(alpha: 0.60),
                        Colors.black.withValues(alpha: 0.92),
                      ],
                    ),
                  ),
                ),
              ),

              // Rating badge top right
              Positioned(
                top: 10,
                right: 10,
                child: _Badge(
                  color: kAccentGold,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 13,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.item.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Taste badge top left
              Positioned(
                top: 10,
                left: 10,
                child: _Badge(
                  color: Colors.black.withValues(alpha: 0.55),
                  child: Text(
                    tasteTag,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),

              // Bottom content overlay
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Food name
                    Text(
                      widget.item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        height: 1.2,
                        letterSpacing: -0.3,
                        shadows: [
                          Shadow(blurRadius: 12, color: Colors.black87),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Meta row
                    Row(
                      children: [
                        const Icon(
                          Icons.public_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          normalizeCountryLabel(widget.item.cuisine),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${widget.item.ingredients.length} thành phần',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Shared badge widget
class _Badge extends StatelessWidget {
  const _Badge({required this.color, required this.child});
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
