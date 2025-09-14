import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/athlete_provider.dart';
import '../providers/blockchain_provider.dart';

class SAIDashboardScreen extends StatefulWidget {
  const SAIDashboardScreen({super.key});

  @override
  State<SAIDashboardScreen> createState() => _SAIDashboardScreenState();
}

class _SAIDashboardScreenState extends State<SAIDashboardScreen> {
  String _selectedFilter = 'All States';
  String _selectedSport = 'All Sports';
  String _selectedAgeGroup = 'All Ages';

  final List<String> _states = [
    'All States',
    'Maharashtra',
    'Karnataka',
    'Tamil Nadu',
    'Gujarat',
    'Rajasthan',
    'Uttar Pradesh',
    'West Bengal',
    'Punjab',
    'Haryana',
  ];

  final List<String> _sports = [
    'All Sports',
    'Athletics',
    'Basketball',
    'Football',
    'Cricket',
    'Badminton',
    'Tennis',
    'Swimming',
    'Boxing',
    'Wrestling',
  ];

  final List<String> _ageGroups = [
    'All Ages',
    '5-10 years',
    '11-15 years',
    '16-20 years',
    '21-25 years',
    '26+ years',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAI Official Dashboard'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilters,
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Cards
            _buildOverviewCards(),
            const SizedBox(height: 24),
            
            // Talent Heatmap
            _buildTalentHeatmap(),
            const SizedBox(height: 24),
            
            // Performance Analytics
            _buildPerformanceAnalytics(),
            const SizedBox(height: 24),
            
            // Top Performers
            _buildTopPerformers(),
            const SizedBox(height: 24),
            
            // Blockchain Verification Status
            _buildBlockchainStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Total Athletes',
            '12,847',
            Icons.people,
            const Color(0xFF10B981),
            '+15% this month',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Tests Completed',
            '45,231',
            Icons.assignment_turned_in,
            const Color(0xFF2563EB),
            '+23% this month',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTalentHeatmap() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Talent Heatmap - India',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              child: _buildHeatmapChart(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildHeatmapLegend('High Potential', const Color(0xFF10B981)),
                const SizedBox(width: 16),
                _buildHeatmapLegend('Medium Potential', const Color(0xFFF59E0B)),
                const SizedBox(width: 16),
                _buildHeatmapLegend('Low Potential', const Color(0xFFEF4444)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapChart() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map,
              size: 64,
              color: const Color(0xFF64748B),
            ),
            const SizedBox(height: 16),
            Text(
              'Interactive India Map',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click on states to view detailed analytics',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeatmapLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildPerformanceAnalytics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Performance Trends',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'];
                          return Text(months[value.toInt() % months.length]);
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 1),
                        FlSpot(2, 4),
                        FlSpot(3, 2),
                        FlSpot(4, 5),
                        FlSpot(5, 3),
                      ],
                      isCurved: true,
                      color: const Color(0xFF2563EB),
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF2563EB).withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformers() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top Performers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              return _buildPerformerTile(
                'Athlete ${index + 1}',
                'Maharashtra',
                'Athletics',
                '95%',
                index + 1,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerTile(String name, String location, String sport, String score, int rank) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _getRankColor(rank),
            child: Text(
              '$rank',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '$location • $sport',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getScoreColor(score),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              score,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockchainStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blockchain Verification Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBlockchainStat(
                    'Verified Tests',
                    '42,156',
                    Icons.verified,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBlockchainStat(
                    'Pending Verification',
                    '1,234',
                    Icons.pending,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildBlockchainStat(
                    'NFT Badges Minted',
                    '8,945',
                    Icons.workspace_premium,
                    const Color(0xFF8B5CF6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildBlockchainStat(
                    'Blockchain Uptime',
                    '99.9%',
                    Icons.trending_up,
                    const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockchainStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getScoreColor(String score) {
    final scoreValue = int.parse(score.replaceAll('%', ''));
    if (scoreValue >= 90) return const Color(0xFF10B981);
    if (scoreValue >= 70) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
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
              'Filter Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(labelText: 'State'),
              items: _states.map((state) {
                return DropdownMenuItem(value: state, child: Text(state));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
              },
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAgeGroup,
              decoration: const InputDecoration(labelText: 'Age Group'),
              items: _ageGroups.map((age) {
                return DropdownMenuItem(value: age, child: Text(age));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAgeGroup = value!;
                });
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Apply filters here
              },
              child: const Text('Apply Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
