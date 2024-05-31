class Exercise {
  String name;
  String type; // Can be 'Cardio' or 'Weight'
  String? weight; // For weight training
  String? reps; // For weight training
  String? sets; // For weight training
  String? calories; // For cardio
  String? time; // Duration in minutes, for cardio

  Exercise({
    required this.name,
    required this.type,
    this.weight,
    this.reps,
    this.sets,
    this.calories,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'weight': weight,
      'reps': reps,
      'sets': sets,
      'calories': calories,
      'time': time,
    };
  }
  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      type: json['type'],
      weight: json['weight'],
      reps: json['reps'],
      sets: json['sets'],
      calories: json['calories'],
      time: json['time'],
    );
  }
}
