class FoodData {
  final String name;
  final double carbs;
  final double fats;
  final double protein;
  final double sugar;
  final int energy; // kcal

  FoodData({
    required this.carbs,
    required this.energy,
    required this.fats,
    required this.name,
    required this.protein,
    required this.sugar,
  });

  static final FoodData none = FoodData(
      carbs: 0.0,
      energy: 0,
      fats: 0.0,
      name: 'No food detected',
      protein: 0.0,
      sugar: 0.0);

  Map<String, dynamic> toJson() => {
        'carb': carbs,
        'energy': energy,
        'fat': fats,
        'name': name,
        'protein': protein,
        'sugar': sugar,
      };

  static FoodData? fromJson(Map<String, dynamic> data) {
    return FoodData(
        carbs: data['carb'],
        energy: data['energy'],
        fats: data['fat'],
        name: data['name'],
        protein: data['protein'],
        sugar: data['sugar']);
  }
}
