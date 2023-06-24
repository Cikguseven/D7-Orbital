class FoodData {
  static final FoodData none = FoodData(
      name: 'NONE',
      energy: 0,
      protein: 0.0,
      fats: 0.0,
      carbs: 0.0,
      sugar: 0.0);

  final String name;
  final int energy; // kcal
  final double protein;
  final double fats;
  final double carbs;
  final double sugar;


  FoodData({
    required this.name,
    required this.energy,
    required this.protein,
    required this.fats,
    required this.carbs,
    required this.sugar,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'energy': energy,
    'protein': protein,
    'fat': fats,
    'carb': carbs,
    'sugar': sugar,
  };

  static FoodData? fromJson(Map<String, dynamic> data) {
    return FoodData(
        name: data['name'],
        energy: data['energy'],
        protein: data['protein'],
        fats: data['fat'],
        carbs: data['carb'],
        sugar: data['sugar']);
  }

  double get energyKJ => energy * 4.184;

  // @override
  // String toString() {
  //   return "Name: $name, Energy: $energy, Protein: $protein, Fat: $fats, Carb: $carbs, Sugar: $sugar";
  // } // kcal * 4.184 = kJ
}