class FoodItem {
  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.cuisine,
    required this.ingredients,
    required this.thumbnailUrl,
    required this.instructions,
    required this.tags,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.rating,
  });

  final String id;
  final String name;
  final String category;
  final String cuisine;
  final List<String> ingredients;
  final String thumbnailUrl;
  final String instructions;
  final List<String> tags;
  final String difficulty;
  final int prepTimeMinutes;
  final double rating;

  factory FoodItem.fromJson(
    Map<String, dynamic> json, {
    String fallbackId = '',
  }) {
    final instructionList = json['instructions'] as List<dynamic>? ?? [];
    final mealTypeList = json['mealType'] as List<dynamic>? ?? [];
    final tagsList = json['tags'] as List<dynamic>? ?? [];
    final ingredientsList = json['ingredients'] as List<dynamic>? ?? [];

    return FoodItem(
      id: (json['id'] ?? fallbackId).toString(),
      name: (json['name'] ?? 'Unknown dish').toString(),
      category: mealTypeList.isNotEmpty
          ? mealTypeList.first.toString()
          : 'Uncategorized',
      cuisine: (json['cuisine'] ?? 'Unknown').toString(),
      ingredients: ingredientsList
          .map((ingredient) => ingredient.toString())
          .toList(),
      thumbnailUrl: (json['image'] ?? '').toString(),
      instructions: instructionList.map((step) => step.toString()).join(' '),
      tags: tagsList.map((tag) => tag.toString()).toList(),
      difficulty: (json['difficulty'] ?? 'Normal').toString(),
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
    );
  }
}
