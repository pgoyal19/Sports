import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/athlete_provider.dart';

class AthleteAvatarScreen extends StatefulWidget {
  const AthleteAvatarScreen({super.key});

  @override
  State<AthleteAvatarScreen> createState() => _AthleteAvatarScreenState();
}

class _AthleteAvatarScreenState extends State<AthleteAvatarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _locationController = TextEditingController();
  final _stateController = TextEditingController();
  final _districtController = TextEditingController();
  final _villageController = TextEditingController();
  final _sportController = TextEditingController();
  
  String _selectedSport = 'Athletics';
  String? _avatarPath;
  final ImagePicker _picker = ImagePicker();

  final List<String> _sports = [
    'Athletics',
    'Basketball',
    'Football',
    'Cricket',
    'Badminton',
    'Tennis',
    'Swimming',
    'Boxing',
    'Wrestling',
    'Gymnastics',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Header
                  Text(
                    'Create Your Athlete Profile',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Set up your SAI Scout profile to start your journey',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  
                  // Avatar Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Athlete Avatar',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                  width: 2,
                                ),
                              ),
                              child: _avatarPath != null
                                  ? ClipOval(
                                      child: Image.file(
                                        File(_avatarPath!),
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.person_add,
                                      size: 48,
                                      color: Color(0xFF64748B),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: _pickAvatar,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Add Photo'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Personal Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Full Name',
                              hintText: 'Enter your full name',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Age
                          TextFormField(
                            controller: _ageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              hintText: 'Enter your age',
                              prefixIcon: Icon(Icons.cake),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
                              }
                              final age = int.tryParse(value);
                              if (age == null || age < 5 || age > 50) {
                                return 'Please enter a valid age (5-50)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Aadhaar ID
                          TextFormField(
                            controller: _aadhaarController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Aadhaar ID',
                              hintText: 'Enter your 12-digit Aadhaar number',
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your Aadhaar ID';
                              }
                              if (value.length != 12) {
                                return 'Aadhaar ID must be 12 digits';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Location Information
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // State
                          TextFormField(
                            controller: _stateController,
                            decoration: const InputDecoration(
                              labelText: 'State',
                              hintText: 'Enter your state',
                              prefixIcon: Icon(Icons.location_on),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your state';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // District
                          TextFormField(
                            controller: _districtController,
                            decoration: const InputDecoration(
                              labelText: 'District',
                              hintText: 'Enter your district',
                              prefixIcon: Icon(Icons.location_city),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your district';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Village
                          TextFormField(
                            controller: _villageController,
                            decoration: const InputDecoration(
                              labelText: 'Village/Town',
                              hintText: 'Enter your village or town',
                              prefixIcon: Icon(Icons.home),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your village/town';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sport Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sport Preference',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          DropdownButtonFormField<String>(
                            value: _selectedSport,
                            decoration: const InputDecoration(
                              labelText: 'Primary Sport',
                              prefixIcon: Icon(Icons.sports),
                            ),
                            items: _sports.map((String sport) {
                              return DropdownMenuItem<String>(
                                value: sport,
                                child: Text(sport),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedSport = newValue!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Create Profile Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _createProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Create Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );
      
      if (image != null) {
        setState(() {
          _avatarPath = image.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _createProfile() {
    if (_formKey.currentState!.validate()) {
      final athlete = AthleteProfile(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        age: int.parse(_ageController.text),
        aadhaarId: _aadhaarController.text,
        location: '${_villageController.text}, ${_districtController.text}, ${_stateController.text}',
        state: _stateController.text,
        district: _districtController.text,
        village: _villageController.text,
        sport: _selectedSport,
        level: 1,
        experience: 0,
        achievements: [],
        testHistory: {},
        avatarPath: _avatarPath ?? '',
        createdAt: DateTime.now(),
      );

      Provider.of<AthleteProvider>(context, listen: false).login(athlete, 'demo-token');
      
      Navigator.pushReplacementNamed(context, '/ar-setup');
    }
  }
}
