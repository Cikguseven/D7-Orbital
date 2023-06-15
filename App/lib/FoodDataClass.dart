class FoodData {
  static final FoodData NONE = FoodData(
      name: 'NONE',
      energy: 0,
      protein: 0.0,
      fat: 0.0,
      carb: 0.0,
      sugar: 0.0);

  final String name;
  final int energy; // kcal
  final double protein;
  final double fat;
  final double carb;
  final double sugar;


  FoodData({
    required this.name,
    required this.energy,
    required this.protein,
    required this.fat,
    required this.carb,
    required this.sugar,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'energy': energy,
    'protein': protein,
    'fat': fat,
    'carb': carb,
    'sugar': sugar,
  };

  static FoodData? fromJson(Map<String, dynamic> data) {
    return FoodData(
        name: data['name'],
        energy: data['energy'],
        protein: data['protein'],
        fat: data['fat'],
        carb: data['carb'],
        sugar: data['sugar']);
  }

  double get energyKJ => energy * 4.184;

  @override
  String toString() {
    return "Name: $name, Energy: $energy, Protein: $protein, Fat: $fat, Carb: $carb, Sugar: $sugar";
  } // kcal * 4.184 = kJ


}