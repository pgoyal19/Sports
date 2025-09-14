import 'package:flutter/foundation.dart';

class Badge {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final String color;
  final DateTime earnedAt;
  final bool isRare;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.color,
    required this.earnedAt,
    this.isRare = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'color': color,
      'earnedAt': earnedAt.toIso8601String(),
      'isRare': isRare,
    };
  }

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconPath: json['iconPath'],
      color: json['color'],
      earnedAt: DateTime.parse(json['earnedAt']),
      isRare: json['isRare'] ?? false,
    );
  }
}

class LeaderboardEntry {
  final String athleteId;
  final String name;
  final String avatarPath;
  final int score;
  final String location;
  final int rank;
  final String sport;

  LeaderboardEntry({
    required this.athleteId,
    required this.name,
    required this.avatarPath,
    required this.score,
    required this.location,
    required this.rank,
    required this.sport,
  });
}

class GamificationProvider extends ChangeNotifier {
  List<Badge> _earnedBadges = [];
  int _totalScore = 0;
  int _currentLevel = 1;
  int _currentStreak = 0;
  int _maxStreak = 0;
  List<LeaderboardEntry> _villageLeaderboard = [];
  List<LeaderboardEntry> _districtLeaderboard = [];
  List<LeaderboardEntry> _stateLeaderboard = [];
  Map<String, int> _testScores = {};

  List<Badge> get earnedBadges => _earnedBadges;
  int get totalScore => _totalScore;
  int get currentLevel => _currentLevel;
  int get currentStreak => _currentStreak;
  int get maxStreak => _maxStreak;
  List<LeaderboardEntry> get villageLeaderboard => _villageLeaderboard;
  List<LeaderboardEntry> get districtLeaderboard => _districtLeaderboard;
  List<LeaderboardEntry> get stateLeaderboard => _stateLeaderboard;
  Map<String, int> get testScores => _testScores;

  void addScore(int points) {
    _totalScore += points;
    _checkLevelUp();
    notifyListeners();
  }

  void addBadge(Badge badge) {
    if (!_earnedBadges.any((b) => b.id == badge.id)) {
      _earnedBadges.add(badge);
      notifyListeners();
    }
  }

  void updateStreak(bool testCompleted) {
    if (testCompleted) {
      _currentStreak++;
      if (_currentStreak > _maxStreak) {
        _maxStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
    notifyListeners();
  }

  void _checkLevelUp() {
    int requiredScore = _currentLevel * 1000;
    if (_totalScore >= requiredScore) {
      _currentLevel++;
      _addLevelUpBadge();
    }
  }

  void _addLevelUpBadge() {
    addBadge(Badge(
      id: 'level_$_currentLevel',
      name: 'Level $_currentLevel Achiever',
      description: 'Reached level $_currentLevel',
      iconPath: 'assets/badges/level.png',
      color: '#FFD700',
      earnedAt: DateTime.now(),
    ));
  }

  void updateTestScore(String testType, int score) {
    _testScores[testType] = score;
    _checkTestBadges(testType, score);
    notifyListeners();
  }

  void _checkTestBadges(String testType, int score) {
    // First test badge
    if (!_earnedBadges.any((b) => b.id == 'first_test')) {
      addBadge(Badge(
        id: 'first_test',
        name: 'First Steps',
        description: 'Completed your first test',
        iconPath: 'assets/badges/first_test.png',
        color: '#10B981',
        earnedAt: DateTime.now(),
      ));
    }

    // High score badges
    if (score >= 90 && !_earnedBadges.any((b) => b.id == '${testType}_excellent')) {
      addBadge(Badge(
        id: '${testType}_excellent',
        name: '${testType.toUpperCase()} Expert',
        description: 'Scored 90+ in $testType',
        iconPath: 'assets/badges/excellent.png',
        color: '#F59E0B',
        earnedAt: DateTime.now(),
        isRare: true,
      ));
    }

    // Streak badges
    if (_currentStreak >= 7 && !_earnedBadges.any((b) => b.id == 'week_streak')) {
      addBadge(Badge(
        id: 'week_streak',
        name: 'Consistent Performer',
        description: '7-day test streak',
        iconPath: 'assets/badges/streak.png',
        color: '#8B5CF6',
        earnedAt: DateTime.now(),
        isRare: true,
      ));
    }
  }

  void updateLeaderboards({
    required List<LeaderboardEntry> village,
    required List<LeaderboardEntry> district,
    required List<LeaderboardEntry> state,
  }) {
    _villageLeaderboard = village;
    _districtLeaderboard = district;
    _stateLeaderboard = state;
    notifyListeners();
  }

  void reset() {
    _earnedBadges.clear();
    _totalScore = 0;
    _currentLevel = 1;
    _currentStreak = 0;
    _maxStreak = 0;
    _testScores.clear();
    notifyListeners();
  }
}
