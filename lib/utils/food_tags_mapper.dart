import '../models/food_item.dart';

const List<String> kTasteOptions = <String>[
  'Cay 🌶',
  'Ngọt 🍰',
  'Chua 🍋',
  'Mặn 🧂',
  'Đắng ☕',
  'Thanh đạm',
];

const Map<String, String> _countryMap = <String, String>{
  'american': 'Mỹ',
  'italian': 'Ý',
  'french': 'Pháp',
  'japanese': 'Nhật Bản',
  'korean': 'Hàn Quốc',
  'chinese': 'Trung Quốc',
  'thai': 'Thái Lan',
  'vietnamese': 'Việt Nam',
  'indian': 'Ấn Độ',
  'mexican': 'Mexico',
  'turkish': 'Thổ Nhĩ Kỳ',
  'greek': 'Hy Lạp',
  'spanish': 'Tây Ban Nha',
  'lebanese': 'Li-băng',
  'pakistani': 'Pakistan',
};

String normalizeCountryLabel(String rawCuisine) {
  final cuisine = rawCuisine.trim();
  if (cuisine.isEmpty) return 'Quốc tế';
  final key = cuisine.toLowerCase();
  if (key.contains('cocktail') ||
      key.contains('smoothie') ||
      key.contains('mocktail') ||
      key.contains('juice') ||
      key == 'beverage' ||
      key == 'drink') {
    return 'Quốc tế';
  }
  if (key == 'unknown' || key == 'uncategorized') return 'Quốc tế';
  return _countryMap[key] ?? cuisine;
}

String? mapTasteTag(String rawTag) {
  final tag = rawTag.trim().toLowerCase();
  if (tag.contains('spicy') || tag.contains('hot') || tag.contains('chili')) {
    return 'Cay 🌶';
  }
  if (tag.contains('sweet') || tag.contains('dessert')) {
    return 'Ngọt 🍰';
  }
  if (tag.contains('sour') || tag.contains('tangy')) {
    return 'Chua 🍋';
  }
  if (tag.contains('salty') || tag.contains('salt')) {
    return 'Mặn 🧂';
  }
  if (tag.contains('bitter')) {
    return 'Đắng ☕';
  }
  if (tag.contains('light') || tag.contains('mild') || tag.contains('fresh')) {
    return 'Thanh đạm';
  }
  return null;
}

List<String> deriveTasteTags(FoodItem item, {int max = 2}) {
  final nameText = item.name.toLowerCase();
  final categoryText = item.category.toLowerCase();
  final tagsText = item.tags.join(' ').toLowerCase();
  final ingredientsText = item.ingredients.join(' ').toLowerCase();
  final textCorpus = '$nameText $categoryText $tagsText $ingredientsText';

  final score = <String, int>{for (final tag in kTasteOptions) tag: 0};

  void addScore(String taste, List<String> keywords, {int weight = 2}) {
    for (final keyword in keywords) {
      if (textCorpus.contains(keyword)) {
        score[taste] = (score[taste] ?? 0) + weight;
      }
    }
  }

  void addIngredientScore(
    String taste,
    List<String> keywords, {
    int weight = 3,
  }) {
    for (final keyword in keywords) {
      if (ingredientsText.contains(keyword)) {
        score[taste] = (score[taste] ?? 0) + weight;
      }
    }
  }

  addIngredientScore('Cay 🌶', [
    'spicy',
    'chili',
    'chilli',
    'red pepper flakes',
    'green chili',
    'chili powder',
    'gochujang',
    'tabasco',
    'curry paste',
  ]);
  addScore('Cay 🌶', [
    'spicy',
    'chili',
    'chilli',
    'jalapeno',
    'pepper',
    'cayenne',
    'sriracha',
    'kimchi',
    'hot sauce',
  ]);
  addIngredientScore('Ngọt 🍰', [
    'sugar',
    'honey',
    'syrup',
    'chocolate',
    'caramel',
    'vanilla',
    'jam',
    'condensed milk',
    'cream',
    'maple',
    'cinnamon sugar',
  ]);
  addScore('Ngọt 🍰', [
    'sweet',
    'dessert',
    'cake',
    'cookie',
    'brownie',
    'ice cream',
    'milkshake',
  ]);

  addIngredientScore('Chua 🍋', [
    'lemon',
    'lime',
    'vinegar',
    'tamarind',
    'pickle',
    'yogurt',
    'sauerkraut',
  ]);
  addScore('Chua 🍋', ['sour', 'citric', 'citrus']);

  addIngredientScore('Mặn 🧂', [
    'salt',
    'soy sauce',
    'fish sauce',
    'miso',
    'anchovy',
    'ham',
    'bacon',
    'parmesan',
    'olive',
    'cheese',
    'brine',
  ]);
  addScore('Mặn 🧂', ['salty', 'savory', 'umami']);

  addIngredientScore('Đắng ☕', [
    'coffee',
    'espresso',
    'cocoa',
    'dark chocolate',
    'grapefruit',
    'bitter melon',
  ]);
  addScore('Đắng ☕', ['bitter', 'americano']);

  addIngredientScore('Thanh đạm', [
    'tofu',
    'lettuce',
    'cucumber',
    'spinach',
    'broccoli',
    'zucchini',
    'cabbage',
    'mushroom',
    'vegetable broth',
  ]);
  addScore('Thanh đạm', [
    'light',
    'mild',
    'fresh',
    'salad',
    'steamed',
    'boiled',
    'greens',
    'healthy',
  ]);

  if (item.category.toLowerCase().contains('dessert')) {
    score['Ngọt 🍰'] = (score['Ngọt 🍰'] ?? 0) + 5;
  }
  if (categoryText.contains('salad') || categoryText.contains('soup')) {
    score['Thanh đạm'] = (score['Thanh đạm'] ?? 0) + 2;
  }
  if (nameText.contains('cocktail') ||
      categoryText.contains('drink') ||
      categoryText.contains('beverage')) {
    score['Ngọt 🍰'] = (score['Ngọt 🍰'] ?? 0) + 2;
    if (ingredientsText.contains('lemon') || ingredientsText.contains('lime')) {
      score['Chua 🍋'] = (score['Chua 🍋'] ?? 0) + 2;
    }
  }

  for (final mapped in item.tags.map(mapTasteTag).whereType<String>()) {
    score[mapped] = (score[mapped] ?? 0) + 1;
  }

  final ranked = score.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) {
      final byScore = b.value.compareTo(a.value);
      if (byScore != 0) return byScore;
      return kTasteOptions
          .indexOf(a.key)
          .compareTo(kTasteOptions.indexOf(b.key));
    });

  if (ranked.isEmpty) {
    return ['Thanh đạm'];
  }

  return ranked.map((e) => e.key).take(max).toList();
}

String primaryTasteTag(FoodItem item) {
  final tastes = deriveTasteTags(item, max: 1);
  if (tastes.isNotEmpty) return tastes.first;
  return 'Thanh đạm';
}
