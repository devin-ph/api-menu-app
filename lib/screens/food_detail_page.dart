import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart'
    show kPrimary, kAccentGold, kBg, kSurface, kTextSecondary, kDivider;
import '../models/food_item.dart';
import '../services/favorite_service.dart';
import '../utils/food_tags_mapper.dart';

class FoodDetailPage extends StatefulWidget {
  const FoodDetailPage({super.key, required this.item});
  final FoodItem item;

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  String _buildDishDescription(FoodItem item) {
    final country = normalizeCountryLabel(item.cuisine);
    final topIngredients = item.ingredients.take(4).join(', ');
    final ingredientText = topIngredients.isEmpty
        ? 'nhiều nguyên liệu đặc trưng'
        : topIngredients;
    final tags = item.tags.take(3).toList();
    final tasteText = tags.isEmpty
        ? 'hương vị hài hòa'
        : tags.join(', ').toLowerCase();

    return '${item.name} là món ăn thuộc nhóm ${item.category.toLowerCase()} trong nền ẩm thực $country. '
        'Món này thường gây ấn tượng nhờ sự kết hợp của $ingredientText. '
        'Theo đánh giá cộng đồng, món đạt ${item.rating.toStringAsFixed(1)}/5.0 và được yêu thích bởi phong cách vị $tasteText. '
        'Đây là lựa chọn phù hợp để khám phá văn hóa ẩm thực $country theo xu hướng trải nghiệm món ăn hiện đại.';
  }

  void _showFavoriteSnackBar({required bool beforeFavorite}) {
    final item = widget.item;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(
          beforeFavorite
              ? 'Đã bỏ "${item.name}" khỏi danh sách yêu thích.'
              : 'Đã lưu "${item.name}" vào danh sách yêu thích.',
          style: const TextStyle(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'Hoàn tác',
          textColor: kPrimary,
          onPressed: () {
            if (beforeFavorite) {
              FavoriteService.add(item.id);
            } else {
              FavoriteService.remove(item.id);
            }
            if (mounted) setState(() {});
          },
        ),
      ),
    );
  }

  void _toggleFavorite() {
    final item = widget.item;
    final beforeFavorite = FavoriteService.isFavorite(item.id);
    if (beforeFavorite) {
      FavoriteService.remove(item.id);
    } else {
      FavoriteService.add(item.id);
    }
    setState(() {});
    _showFavoriteSnackBar(beforeFavorite: beforeFavorite);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final country = normalizeCountryLabel(item.cuisine);
    final isFavorite = FavoriteService.isFavorite(item.id);
    final bottom = MediaQuery.of(context).padding.bottom;
    final screenH = MediaQuery.of(context).size.height;
    final imageH = screenH * 0.45;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBg,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: imageH,
              width: double.infinity,
              child: Hero(
                tag: 'food-image-${item.id}',
                child: Image.network(
                  item.thumbnailUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: kSurface,
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        color: kTextSecondary,
                        size: 64,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: imageH - 80,
              left: 0,
              right: 0,
              height: 80,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, kBg],
                  ),
                ),
              ),
            ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: imageH - 20)),
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: kBg,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(top: 12, bottom: 20),
                            decoration: BoxDecoration(
                              color: kDivider,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: kPrimary.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: kPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 11,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                  height: 1.15,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  ...List.generate(5, (i) {
                                    final full = i < item.rating.floor();
                                    return Icon(
                                      full
                                          ? Icons.star_rounded
                                          : (i < item.rating
                                                ? Icons.star_half_rounded
                                                : Icons.star_outline_rounded),
                                      color: kAccentGold,
                                      size: 20,
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: kAccentGold,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoPill(
                                    icon: Icons.public_rounded,
                                    label: country,
                                  ),
                                  _InfoPill(
                                    icon: Icons.restaurant_menu_rounded,
                                    label: item.category,
                                  ),
                                  _InfoPill(
                                    icon: Icons.inventory_2_rounded,
                                    label:
                                        '${item.ingredients.length} thành phần',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                        if (item.ingredients.isNotEmpty) ...[
                          _SectionHeader(
                            title: 'Thành phần (${item.ingredients.length})',
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.ingredients.take(20).map((ing) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: kSurface,
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: kDivider),
                                  ),
                                  child: Text(
                                    ing,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        _SectionHeader(title: 'Thông tin chi tiết'),
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: kSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: kDivider),
                            ),
                            child: Column(
                              children: [
                                _FactRow(
                                  icon: Icons.public_rounded,
                                  label: 'Quốc gia',
                                  value: country,
                                ),
                                const _FactDivider(),
                                _FactRow(
                                  icon: Icons.restaurant_menu_rounded,
                                  label: 'Loại món',
                                  value: item.category,
                                ),
                                const _FactDivider(),
                                _FactRow(
                                  icon: Icons.star_rounded,
                                  label: 'Đánh giá cộng đồng',
                                  value:
                                      '${item.rating.toStringAsFixed(1)} / 5.0',
                                ),
                                const _FactDivider(),
                                _FactRow(
                                  icon: Icons.inventory_2_rounded,
                                  label: 'Số thành phần',
                                  value: '${item.ingredients.length}',
                                ),
                                if (item.tags.isNotEmpty) ...[
                                  const _FactDivider(),
                                  _FactRow(
                                    icon: Icons.local_offer_rounded,
                                    label: 'Khẩu vị',
                                    value: deriveTasteTags(item).join(' • '),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        _SectionHeader(title: 'Về món ăn này'),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _buildDishDescription(item),
                            style: const TextStyle(
                              color: kTextSecondary,
                              fontSize: 15,
                              height: 1.75,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 8, 20, bottom + 24),
                          child: SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: _toggleFavorite,
                              icon: Icon(
                                isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 20,
                              ),
                              label: Text(
                                isFavorite
                                    ? 'Đã lưu yêu thích'
                                    : 'Lưu vào yêu thích',
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: kPrimary,
                                foregroundColor: Colors.white,
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? kTextSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: c),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: c,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: kPrimary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final leftWidth = (constraints.maxWidth * 0.46).clamp(150.0, 210.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: leftWidth,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 17, color: kPrimary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: kTextSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: valueColor ?? Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FactDivider extends StatelessWidget {
  const _FactDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: kDivider),
    );
  }
}
