import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart' show kPrimary, kBg, kSurface, kTextSecondary;
import '../models/food_item.dart';
import '../screens/food_detail_page.dart';
import '../services/favorite_service.dart';
import '../services/food_api_service.dart';
import '../utils/food_tags_mapper.dart';
import '../widgets/error_state_view.dart';
import '../widgets/food_card.dart';
import '../widgets/food_list_tile.dart';

enum _SortOption { ratingDesc, ingredientCountDesc, nameAsc }

enum _MenuTab { all, favorites }

extension _SortOptionLabel on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.ratingDesc:
        return 'Đánh giá';
      case _SortOption.ingredientCountDesc:
        return 'Thành phần';
      case _SortOption.nameAsc:
        return 'Tên A → Z';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOption.ratingDesc:
        return Icons.star_rounded;
      case _SortOption.ingredientCountDesc:
        return Icons.inventory_2_rounded;
      case _SortOption.nameAsc:
        return Icons.sort_by_alpha_rounded;
    }
  }
}

class _FilterResult {
  const _FilterResult({
    required this.countries,
    required this.types,
    required this.tastes,
  });

  final Set<String> countries;
  final Set<String> types;
  final Set<String> tastes;
}

class MenuHomePage extends StatefulWidget {
  const MenuHomePage({
    super.key,
    this.studentName = 'Pham Hoang The Vinh',
    this.studentId = '2351060498',
    this.apiService = const FoodApiService(),
  });

  final String studentName;
  final String studentId;
  final FoodApiService apiService;

  @override
  State<MenuHomePage> createState() => _MenuHomePageState();
}

class _MenuHomePageState extends State<MenuHomePage> {
  List<FoodItem> _items = <FoodItem>[];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  bool _isGridView = true;
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.ratingDesc;
  _MenuTab _activeTab = _MenuTab.all;

  final Set<String> _selectedCountries = <String>{};
  final Set<String> _selectedTypes = <String>{};
  final Set<String> _selectedTastes = <String>{};

  @override
  void initState() {
    super.initState();
    FavoriteService.favoriteIds.addListener(_onFavoritesChanged);
    _loadMenu();
  }

  @override
  void dispose() {
    FavoriteService.favoriteIds.removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final result = await widget.apiService.fetchMenuItems();
      if (!mounted) return;
      setState(() {
        _items = result;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _openDetail(FoodItem item) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.03),
                end: Offset.zero,
              ).animate(curved),
              child: FoodDetailPage(item: item),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 340),
      ),
    );
  }

  List<String> _tasteLabels(FoodItem item) {
    return deriveTasteTags(item);
  }

  int get _activeFilterCount {
    return _selectedCountries.length +
        _selectedTypes.length +
        _selectedTastes.length;
  }

  bool _containsIgnoreCase(Set<String> values, String input) {
    return values.any((v) => v.toLowerCase() == input.toLowerCase());
  }

  bool _overlapIgnoreCase(Set<String> selected, Iterable<String> values) {
    return values.any((value) => _containsIgnoreCase(selected, value));
  }

  List<FoodItem> _filterItems(List<FoodItem> items) {
    final keyword = _searchQuery.trim().toLowerCase();
    return items.where((item) {
      if (_activeTab == _MenuTab.favorites &&
          !FavoriteService.isFavorite(item.id)) {
        return false;
      }

      if (_selectedCountries.isNotEmpty &&
          !_containsIgnoreCase(
            _selectedCountries,
            normalizeCountryLabel(item.cuisine),
          )) {
        return false;
      }

      if (_selectedTypes.isNotEmpty &&
          !_containsIgnoreCase(_selectedTypes, item.category)) {
        return false;
      }

      if (_selectedTastes.isNotEmpty &&
          !_overlapIgnoreCase(_selectedTastes, _tasteLabels(item))) {
        return false;
      }

      if (keyword.isEmpty) return true;
      final tagText = item.tags.join(' ').toLowerCase();
      return item.name.toLowerCase().contains(keyword) ||
          item.category.toLowerCase().contains(keyword) ||
          normalizeCountryLabel(item.cuisine).toLowerCase().contains(keyword) ||
          tagText.contains(keyword);
    }).toList();
  }

  List<FoodItem> _sortItems(List<FoodItem> items) {
    final sorted = [...items];
    switch (_sortOption) {
      case _SortOption.ratingDesc:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortOption.ingredientCountDesc:
        sorted.sort(
          (a, b) => b.ingredients.length.compareTo(a.ingredients.length),
        );
      case _SortOption.nameAsc:
        sorted.sort((a, b) => a.name.compareTo(b.name));
    }
    return sorted;
  }

  Map<String, int> _countBy(Iterable<String> values) {
    final counts = <String, int>{};
    for (final value in values) {
      final v = value.trim();
      if (v.isEmpty) continue;
      counts[v] = (counts[v] ?? 0) + 1;
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return {for (final e in sorted) e.key: e.value};
  }

  Map<String, int> _countFromFixedOptions(
    List<String> options,
    List<FoodItem> source,
    List<String> Function(FoodItem item) extractor,
  ) {
    final counts = <String, int>{for (final option in options) option: 0};
    for (final item in source) {
      for (final label in extractor(item)) {
        counts[label] = (counts[label] ?? 0) + 1;
      }
    }
    return counts;
  }

  Widget _buildFilterSection({
    required String title,
    required Map<String, int> options,
    required Set<String> selected,
    required void Function(String label, bool checked) onChanged,
  }) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                childAspectRatio: 3.3,
              ),
              itemBuilder: (_, index) {
                final entry = options.entries.elementAt(index);
                final checked = selected.any(
                  (s) => s.toLowerCase() == entry.key.toLowerCase(),
                );
                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onChanged(entry.key, !checked),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: checked
                          ? kPrimary.withValues(alpha: 0.18)
                          : const Color(0xFF26221F),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: checked
                            ? kPrimary.withValues(alpha: 0.7)
                            : kTextSecondary.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          checked
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          size: 18,
                          color: checked ? kPrimary : kTextSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${entry.value}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Future<void> _openFilterSheet() async {
    final countryCounts = _countBy(
      _items.map((item) => normalizeCountryLabel(item.cuisine)),
    );
    final typeCounts = _countBy(_items.map((item) => item.category));
    final tasteCounts = _countFromFixedOptions(
      kTasteOptions,
      _items,
      _tasteLabels,
    );

    final selected = await showModalBottomSheet<_FilterResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: kSurface,
      builder: (context) {
        final tempCountries = <String>{..._selectedCountries};
        final tempTypes = <String>{..._selectedTypes};
        final tempTastes = <String>{..._selectedTastes};

        void toggleValue(Set<String> target, String label, bool checked) {
          target.removeWhere((v) => v.toLowerCase() == label.toLowerCase());
          if (checked) target.add(label);
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: StatefulBuilder(
              builder: (context, setModal) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Bộ lọc',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        _buildFilterSection(
                          title: 'Quốc gia',
                          options: countryCounts,
                          selected: tempCountries,
                          onChanged: (label, checked) => setModal(
                            () => toggleValue(tempCountries, label, checked),
                          ),
                        ),
                        _buildFilterSection(
                          title: 'Loại món',
                          options: typeCounts,
                          selected: tempTypes,
                          onChanged: (label, checked) => setModal(
                            () => toggleValue(tempTypes, label, checked),
                          ),
                        ),
                        _buildFilterSection(
                          title: 'Khẩu vị',
                          options: tasteCounts,
                          selected: tempTastes,
                          onChanged: (label, checked) => setModal(
                            () => toggleValue(tempTastes, label, checked),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setModal(() {
                            tempCountries.clear();
                            tempTypes.clear();
                            tempTastes.clear();
                          }),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kTextSecondary,
                            side: const BorderSide(color: kTextSecondary),
                          ),
                          child: const Text('Đặt lại'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(
                            context,
                            _FilterResult(
                              countries: tempCountries,
                              types: tempTypes,
                              tastes: tempTastes,
                            ),
                          ),
                          child: const Text('Áp dụng'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedCountries
        ..clear()
        ..addAll(selected.countries);
      _selectedTypes
        ..clear()
        ..addAll(selected.types);
      _selectedTastes
        ..clear()
        ..addAll(selected.tastes);
    });
  }

  Future<void> _openSortSheet() async {
    final selected = await showModalBottomSheet<_SortOption>(
      context: context,
      showDragHandle: true,
      backgroundColor: kSurface,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sắp xếp theo',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 14),
              ..._SortOption.values.map(
                (opt) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: _sortOption == opt
                        ? kPrimary.withValues(alpha: 0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: RadioListTile<_SortOption>(
                      value: opt,
                      groupValue: _sortOption,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      activeColor: kPrimary,
                      title: Row(
                        children: [
                          Icon(
                            opt.icon,
                            size: 18,
                            color: _sortOption == opt
                                ? kPrimary
                                : kTextSecondary,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            opt.label,
                            style: TextStyle(
                              color: _sortOption == opt
                                  ? Colors.white
                                  : kTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onChanged: (v) => Navigator.pop(context, v),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    setState(() => _sortOption = selected);
  }

  void _clearAllFilters() {
    setState(() {
      _selectedCountries.clear();
      _selectedTypes.clear();
      _selectedTastes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBg,
        appBar: AppBar(
          backgroundColor: kBg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'TH3 - Phạm Hoàng Thế Vinh - 2351060498',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        body: Builder(
          builder: (context) {
            if (_isLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: kPrimary,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu món ăn...',
                      style: TextStyle(color: kTextSecondary, fontSize: 14),
                    ),
                  ],
                ),
              );
            }
            if (_errorMessage != null) {
              return ErrorStateView(
                message: _errorMessage!,
                onRetry: _loadMenu,
              );
            }
            if (_items.isEmpty) {
              return ErrorStateView(
                message: 'Không có dữ liệu món ăn.',
                onRetry: _loadMenu,
              );
            }

            final filteredItems = _sortItems(_filterItems(_items));
            return Column(
              children: [
                Container(
                  color: kBg,
                  padding: const EdgeInsets.only(
                    top: 8,
                    left: 16,
                    right: 16,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'MENU ẨM THỰC',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Khám phá & tìm hiểu các món ăn',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kTextSecondary, fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 720),
                          child: SearchBar(
                            controller: _searchController,
                            hintText: 'Tìm kiếm món ăn...',
                            leading: const Icon(
                              Icons.search_rounded,
                              color: kTextSecondary,
                              size: 20,
                            ),
                            trailing: [
                              IconButton(
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 180),
                                  transitionBuilder: (child, animation) =>
                                      ScaleTransition(
                                        scale: animation,
                                        child: child,
                                      ),
                                  child: Icon(
                                    _isGridView
                                        ? Icons.view_list_rounded
                                        : Icons.grid_view_rounded,
                                    key: ValueKey<bool>(_isGridView),
                                    size: 18,
                                    color: kTextSecondary,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _isGridView = !_isGridView);
                                },
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: kTextSecondary,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ),
                            ],
                            onChanged: (v) => setState(() => _searchQuery = v),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: SegmentedButton<_MenuTab>(
                            showSelectedIcon: false,
                            segments: const [
                              ButtonSegment<_MenuTab>(
                                value: _MenuTab.all,
                                label: Text('Tất cả'),
                              ),
                              ButtonSegment<_MenuTab>(
                                value: _MenuTab.favorites,
                                label: Text('Yêu thích'),
                              ),
                            ],
                            selected: {_activeTab},
                            onSelectionChanged: (values) {
                              HapticFeedback.selectionClick();
                              setState(() => _activeTab = values.first);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            transitionBuilder: (child, animation) =>
                                FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                            child: Text(
                              _activeTab == _MenuTab.favorites
                                  ? '${filteredItems.length} món yêu thích'
                                  : '${filteredItems.length} món ăn',
                              key: ValueKey<String>(
                                '${_activeTab.name}-${filteredItems.length}',
                              ),
                              style: const TextStyle(
                                color: kTextSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          _ActionButton(
                            icon: Icons.swap_vert_rounded,
                            label: _sortOption.label,
                            onTap: _openSortSheet,
                          ),
                          const SizedBox(width: 8),
                          _ActionButton(
                            icon: Icons.tune_rounded,
                            label: _activeFilterCount == 0
                                ? 'Bộ lọc'
                                : 'Lọc ($_activeFilterCount)',
                            isActive: _activeFilterCount > 0,
                            onTap: _openFilterSheet,
                          ),
                          if (_activeFilterCount > 0) ...[
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _clearAllFilters();
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: kTextSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    color: kPrimary,
                    backgroundColor: kSurface,
                    onRefresh: _loadMenu,
                    child: filteredItems.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 120),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      _activeTab == _MenuTab.favorites
                                          ? Icons.favorite_border_rounded
                                          : Icons.search_off_rounded,
                                      size: 56,
                                      color: kTextSecondary,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _activeTab == _MenuTab.favorites
                                          ? 'Bạn chưa có món yêu thích nào'
                                          : 'Không tìm thấy món ăn phù hợp',
                                      style: const TextStyle(
                                        color: kTextSecondary,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: _isGridView
                                ? LayoutBuilder(
                                    key: const ValueKey('grid'),
                                    builder: (context, cons) {
                                      final cols = cons.maxWidth >= 1000
                                          ? 3
                                          : cons.maxWidth >= 640
                                          ? 2
                                          : 1;
                                      return GridView.builder(
                                        padding: const EdgeInsets.fromLTRB(
                                          20,
                                          4,
                                          20,
                                          28,
                                        ),
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: cols,
                                              crossAxisSpacing: 16,
                                              mainAxisSpacing: 16,
                                              childAspectRatio: cols == 1
                                                  ? 1.18
                                                  : 0.72,
                                            ),
                                        itemCount: filteredItems.length,
                                        itemBuilder: (_, i) => FoodCard(
                                          item: filteredItems[i],
                                          onTap: () =>
                                              _openDetail(filteredItems[i]),
                                        ),
                                      );
                                    },
                                  )
                                : ListView.separated(
                                    key: const ValueKey('list'),
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      4,
                                      20,
                                      28,
                                    ),
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: filteredItems.length,
                                    separatorBuilder: (_, __) =>
                                        const SizedBox(height: 14),
                                    itemBuilder: (_, i) => FoodListTile(
                                      item: filteredItems[i],
                                      onTap: () =>
                                          _openDetail(filteredItems[i]),
                                    ),
                                  ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? kPrimary.withValues(alpha: 0.18) : kSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? kPrimary.withValues(alpha: 0.6)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isActive ? kPrimary : kTextSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? kPrimary : kTextSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
