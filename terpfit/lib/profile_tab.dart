import 'package:flutter/material.dart';
import 'package:terpfit/profile.dart';

/// The profile tab should contain age, sex, weight, height, maybe more
/// these are the necessary so far.

class ProfileTab extends StatefulWidget {
  const ProfileTab({Key? key}) : super(key: key);

  @override
  ProfileTabState createState() => ProfileTabState();
}

class ProfileTabState extends State<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  Profile? _profile; // Changed to nullable
  bool _isLoading = true; // Added loading flag

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    Profile profile = await ProfileManager.loadProfile();
    setState(() {
      _profile = profile;
      _isLoading = false; // Set loading to false once profile is loaded
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await ProfileManager.saveProfile(
          _profile!); // Assert _profile is not null
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile Saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: <Widget>[
                TextFormField(
                  initialValue: _profile?.age.toString(),
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => _profile?.age = int.parse(value ?? '21'),
                ),
                TextFormField(
                  initialValue: _profile?.gender,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  onSaved: (value) => _profile?.gender = value ?? 'Female',
                ),
                TextFormField(
                  initialValue: _profile?.weight.toString(),
                  decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) =>
                      _profile?.weight = int.parse(value ?? '150'),
                ),
                TextFormField(
                  initialValue: _profile?.height.toString(),
                  decoration:
                      const InputDecoration(labelText: 'Height (cm)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    _profile?.height = int.parse(value ?? '176');
                    _profile
                        ?.calculateBMI(); // Recalculate BMI when height changes
                    setState(() {}); // Trigger a rebuild to update BMI display
                  },
                ),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile'),
                ),
                SizedBox(height: 20), // Space between button and BMI display
                if (_profile != null) ...[
                  Center(
                    child: Text('BMI: ${_profile!.bmi.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 20)),
                  ),
                  Center(
                    child: Text(_getBmiCategory(_profile!.bmi),
                        style: TextStyle(fontSize: 18, color: Colors.blue)),
                  ),
                ]
              ],
            ),
          );
  }
}

String _getBmiCategory(double bmi) {
  if (bmi < 18.5) {
    return 'Underweight (<18.5)';
  } else if (bmi < 25) {
    return 'Normal weight (18.5–24.9)';
  } else if (bmi < 30) {
    return 'Overweight (25–29.9)';
  } else {
    return 'Obesity (BMI of 30 or greater)';
  }
}
