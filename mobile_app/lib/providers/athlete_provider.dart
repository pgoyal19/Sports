import 'package:flutter/foundation.dart';

class AthleteProfile {
  final String id;
  final String name;
  final int age;
  final String aadhaarId;
  final String location;
  final String state;
  final String district;
  final String village;
  final String sport;
  int level;
  int experience;
  List<String> achievements;
  Map<String, dynamic> testHistory;
  final String avatarPath;
  final DateTime createdAt;

  AthleteProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.aadhaarId,
    required this.location,
    required this.state,
    required this.district,
    required this.village,
    required this.sport,
    required this.level,
    required this.experience,
    required this.achievements,
    required this.testHistory,
    required this.avatarPath,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'aadhaarId': aadhaarId,
      'location': location,
      'state': state,
      'district': district,
      'village': village,
      'sport': sport,
      'level': level,
      'experience': experience,
      'achievements': achievements,
      'testHistory': testHistory,
      'avatarPath': avatarPath,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AthleteProfile.fromJson(Map<String, dynamic> json) {
    return AthleteProfile(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      aadhaarId: json['aadhaarId'],
      location: json['location'],
      state: json['state'],
      district: json['district'],
      village: json['village'],
      sport: json['sport'],
      level: json['level'],
      experience: json['experience'],
      achievements: List<String>.from(json['achievements']),
      testHistory: Map<String, dynamic>.from(json['testHistory']),
      avatarPath: json['avatarPath'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class AthleteProvider extends ChangeNotifier {
  AthleteProfile? _currentAthlete;
  bool _isLoggedIn = false;
  String? _authToken;

  AthleteProfile? get currentAthlete => _currentAthlete;
  bool get isLoggedIn => _isLoggedIn;
  String? get authToken => _authToken;

  void login(AthleteProfile athlete, String token) {
    _currentAthlete = athlete;
    _isLoggedIn = true;
    _authToken = token;
    notifyListeners();
  }

  void logout() {
    _currentAthlete = null;
    _isLoggedIn = false;
    _authToken = null;
    notifyListeners();
  }

  void updateProfile(AthleteProfile updatedProfile) {
    _currentAthlete = updatedProfile;
    notifyListeners();
  }

  void addTestResult(String testType, Map<String, dynamic> result) {
    if (_currentAthlete != null) {
      _currentAthlete!.testHistory[testType] = result;
      notifyListeners();
    }
  }

  void addAchievement(String achievement) {
    if (_currentAthlete != null) {
      _currentAthlete!.achievements.add(achievement);
      notifyListeners();
    }
  }

  void levelUp() {
    if (_currentAthlete != null) {
      _currentAthlete!.level++;
      notifyListeners();
    }
  }
}
