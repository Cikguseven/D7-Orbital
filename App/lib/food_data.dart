class FoodData {
  final String name;
  double carbs;
  double fats;
  double protein;
  double sugar;
  int energy; // kcal

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

  FoodData changePortionSize(double portionSize) {
    return FoodData(
        carbs: carbs *= portionSize,
        energy: (energy * portionSize).round(),
        fats: fats *= portionSize,
        name: name,
        protein: protein *= portionSize,
        sugar: sugar *= portionSize);
  }
}
