import '../models/food_item.dart';

List<String> extractFilterTags(FoodItem item) {
  final rawTags = <String>[
    item.category,
    item.cuisine,
    ...item.tags.take(3),
  ];

  final cleaned = <String>[];
  for (final tag in rawTags) {
    final value = tag.trim();
    if (value.isEmpty) {
      continue;
    }
    if (cleaned.any((existing) => existing.toLowerCase() == value.toLowerCase())) {
      continue;
    }
    cleaned.add(value);
  }

  return cleaned;
}

List<String> buildMeaningfulTags(FoodItem item, {int max = 3}) {
  final cleaned = extractFilterTags(item).toList();

  return cleaned.take(max).toList();
}
