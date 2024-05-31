import 'package:shared_preferences/shared_preferences.dart';

/// this is a stretch goal
class Profile {
  int age;
  String gender;
  int height; //inches
  int weight; //lbs
  double bmi;
  Profile(
      {required this.age,
      required this.gender,
      required this.height,
      required this.weight,
      required this.bmi});

  void calculateBMI() {
    final heightCm = height / 100;
    final kg = 0.453592 * weight;
    this.bmi = (kg / (heightCm * heightCm));
  }
}

class ProfileManager {
  static const _ageKey = 'age';
  static const _genderKey = 'gender';
  static const _weightKey = 'weight';
  static const _heightKey = 'height';
  static const _bmiKey = 'bmi';

  static Future<Profile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    int age =
        prefs.getInt(_ageKey) ?? 21; // default it to 21 or user has stored age
    String gender = prefs.getString(_genderKey) ?? 'Female';
    int weight = prefs.getInt(_weightKey) ?? 150;
    int height = prefs.getInt(_heightKey) ?? 176;
    double bmi = prefs.getDouble(_bmiKey) ?? 0;
    Profile profile = Profile(
        age: age, gender: gender, height: height, weight: weight, bmi: bmi);
    profile
        .calculateBMI(); // Recalculate BMI in case height or weight has changed
    return profile;
  }

  static Future<void> saveProfile(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    profile.calculateBMI();
    await prefs.setInt(_ageKey, profile.age);
    await prefs.setString(_genderKey, profile.gender);
    await prefs.setInt(_weightKey, profile.weight);
    await prefs.setInt(_heightKey, profile.height);
    await prefs.setDouble(_bmiKey, profile.bmi);
  }
}
