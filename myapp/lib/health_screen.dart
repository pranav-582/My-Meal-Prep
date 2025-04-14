import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _gender;
  String? _activityLevel;
  String? _fitnessGoal;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ageController.text = prefs.getString('age') ?? '';
      _gender = prefs.getString('gender');
      _weightController.text = prefs.getString('weight') ?? '';
      _heightController.text = prefs.getString('height') ?? '';
      _activityLevel = prefs.getString('activityLevel');
      _fitnessGoal = prefs.getString('fitnessGoal');
    });
  }

  Future<void> _saveHealthData() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('age', _ageController.text);
    await prefs.setString('gender', _gender ?? '');
    await prefs.setString('weight', _weightController.text);
    await prefs.setString('height', _heightController.text);
    await prefs.setString('activityLevel', _activityLevel ?? '');
    await prefs.setString('fitnessGoal', _fitnessGoal ?? '');

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Health data saved successfully!')),
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Profile'),
        actions: [
          if (!_isEditing && _ageController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child:
            _isEditing || _ageController.text.isEmpty
                ? Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        controller: _ageController,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Gender'),
                        items:
                            ['Male', 'Female', 'Other']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                        value: _gender,
                        onChanged: (value) => setState(() => _gender = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                        ),
                        keyboardType: TextInputType.number,
                        controller: _weightController,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                        ),
                        controller: _heightController,
                        keyboardType: TextInputType.number,
                        validator:
                            (value) =>
                                value?.isEmpty ?? true ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Activity Level',
                        ),
                        items:
                            ['Sedentary', 'Moderate', 'Active']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                        value: _activityLevel,
                        onChanged:
                            (value) => setState(() => _activityLevel = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Fitness Goal',
                        ),
                        items:
                            ['Gain', 'Lose', 'Maintain']
                                .map(
                                  (value) => DropdownMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                                )
                                .toList(),
                        value: _fitnessGoal,
                        onChanged:
                            (value) => setState(() => _fitnessGoal = value),
                        validator: (value) => value == null ? 'Required' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _saveHealthData,
                        child: const Text('Save Profile'),
                      ),
                    ],
                  ),
                )
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileItem('Age', _ageController.text),
                    _buildProfileItem('Gender', _gender ?? 'Not set'),
                    _buildProfileItem('Weight', '${_weightController.text} kg'),
                    _buildProfileItem('Height', '${_heightController.text} cm'),
                    _buildProfileItem(
                      'Activity Level',
                      _activityLevel ?? 'Not set',
                    ),
                    _buildProfileItem(
                      'Fitness Goal',
                      _fitnessGoal ?? 'Not set',
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _isEditing = true),
                        child: const Text('Edit Profile'),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
            ),
          ),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
