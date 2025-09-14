import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/athlete_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String _selectedLevel = 'Village';
  String _selectedSport = 'All Sports';

  final List<String> _levels = ['Village', 'District', 'State', 'National'];
  final List<String> _sports = ['All Sports', 'Athletics', 'Basketball', 'Football', 'Cricket'];

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  void _loadLeaderboardData() {
    // Simulate loading leaderboard data
    final gamificationProvider = Provider.of<GamificationProvider>(context, listen: false);
    
    // Mock data for demonstration
    final villageData = [
      LeaderboardEntry(
        athleteId: '1',
        name: 'Rajesh Kumar',
        avatarPath: '',
        score: 95,
        location: 'Village A',
        rank: 1,
        sport: 'Athletics',
      ),
      LeaderboardEntry(
        athleteId: '2',
        name: 'Priya Sharma',
        avatarPath: '',
        score: 92,
        location: 'Village B',
        rank: 2,
        sport: 'Basketball',
      ),
      LeaderboardEntry(
        athleteId: '3',
        name: 'Amit Singh',
        avatarPath: '',
        score: 88,
        location: 'Village C',
        rank: 3,
        sport: 'Football',
      ),
    ];

    final districtData = [
      LeaderboardEntry(
        athleteId: '4',
        name: 'Suresh Patel',
        avatarPath: '',
        score: 98,
        location: 'District X',
        rank: 1,
        sport: 'Athletics',
      ),
      LeaderboardEntry(
        athleteId: '5',
        name: 'Meera Joshi',
        avatarPath: '',
        score: 94,
        location: 'District Y',
        rank: 2,
        sport: 'Swimming',
      ),
    ];

    final stateData = [
      LeaderboardEntry(
        athleteId: '6',
        name: 'Vikram Reddy',
        avatarPath: '',
        score: 99,
        location: 'Maharashtra',
        rank: 1,
        sport: 'Athletics',
      ),
    ];

    gamificationProvider.updateLeaderboards(
      village: villageData,
      district: districtData,
      state: stateData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Column(
        children: [
          // Level Selector
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: _levels.map((level) {
                final isSelected = _selectedLevel == level;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.grey[200],
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(level),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Leaderboard Content
          Expanded(
            child: Consumer<GamificationProvider>(
              builder: (context, gamificationProvider, child) {
                List<LeaderboardEntry> data = [];
                
                switch (_selectedLevel) {
                  case 'Village':
                    data = gamificationProvider.villageLeaderboard;
                    break;
                  case 'District':
                    data = gamificationProvider.districtLeaderboard;
                    break;
                  case 'State':
                    data = gamificationProvider.stateLeaderboard;
                    break;
                  case 'National':
                    data = _getNationalLeaderboard();
                    break;
                }

                if (data.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final entry = data[index];
                    return _buildLeaderboardItem(entry, index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFFE2E8F0),
              child: entry.avatarPath.isNotEmpty
                  ? ClipOval(
                      child: Image.asset(
                        entry.avatarPath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      entry.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF64748B),
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Name and Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        entry.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.sport,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(entry.score),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${entry.score}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'points',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF64748B); // Grey
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return const Color(0xFF10B981); // Green
    if (score >= 70) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Red
  }

  List<LeaderboardEntry> _getNationalLeaderboard() {
    return [
      LeaderboardEntry(
        athleteId: '7',
        name: 'Arjun Mehta',
        avatarPath: '',
        score: 100,
        location: 'Karnataka',
        rank: 1,
        sport: 'Athletics',
      ),
      LeaderboardEntry(
        athleteId: '8',
        name: 'Kavya Nair',
        avatarPath: '',
        score: 97,
        location: 'Kerala',
        rank: 2,
        sport: 'Swimming',
      ),
      LeaderboardEntry(
        athleteId: '9',
        name: 'Rohit Sharma',
        avatarPath: '',
        score: 95,
        location: 'Punjab',
        rank: 3,
        sport: 'Cricket',
      ),
    ];
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Leaderboard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSport,
              decoration: const InputDecoration(labelText: 'Sport'),
              items: _sports.map((sport) {
                return DropdownMenuItem(value: sport, child: Text(sport));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSport = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Apply sport filter here
              },
              child: const Text('Apply Filter'),
            ),
          ],
        ),
      ),
    );
  }
}
