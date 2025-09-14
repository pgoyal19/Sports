import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _latest;
  List<dynamic> _leaderboard = [];
  bool _loading = true;
  late AnimationController _animationController;
  late AnimationController _chartController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chartController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _chartController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final latest = await ApiService.fetchLatestResult();
    final leaderboard = await ApiService.fetchLeaderboard();
    if (!mounted) return;
    setState(() {
      _latest = latest;
      _leaderboard = leaderboard;
      _loading = false;
    });
  }

  Map<String, dynamic>? get _analysis {
    return _latest?['analysis'] as Map<String, dynamic>?;
  }

  Map<String, dynamic>? get _videoInfo {
    return _latest?['video_info'] as Map<String, dynamic>?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header with celebration
                        _buildHeader(),
                        const SizedBox(height: 24),

                        // Performance Score Card
                        _buildScoreCard(),
                        const SizedBox(height: 24),

                        // Performance Chart
                        _buildPerformanceChart(),
                        const SizedBox(height: 24),

                        // Detailed Analysis
                        _buildDetailedAnalysis(),
                        const SizedBox(height: 24),

                        // Recommendations
                        _buildRecommendations(),
                        const SizedBox(height: 24),

                        // Leaderboard
                        _buildLeaderboard(),
                        const SizedBox(height: 100), // Space for FAB
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildHeader() {
    final score = (_latest?['score'] ?? 0).toDouble();
    final isHighScore = score >= 80;
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isHighScore ? AppTheme.primaryGradient : AppTheme.secondaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.elevatedShadow,
            ),
            child: Row(
              children: [
                SizedBox(
                  height: 80,
                  width: 80,
                  child: Lottie.network(
                    isHighScore
                        ? 'https://assets2.lottiefiles.com/packages/lf20_touohxv0.json'
                        : 'https://assets2.lottiefiles.com/packages/lf20_fcfjwiyb.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHighScore ? 'Excellent Performance!' : 'Good Job!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textOnPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your latest assessment is ready for review',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textOnPrimary.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard() {
    final score = (_latest?['score'] ?? 0).toDouble();
    final cheatDetected = (_latest?['cheat_detected'] ?? 0) == 1;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Score',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Score Display
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.neutral200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(score),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${score.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: _getScoreColor(score),
                      ),
                    ),
                    Text(
                      'out of 100',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Performance Badges
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _PerformanceBadge(
                icon: Icons.emoji_events,
                text: 'Score ${score.toStringAsFixed(0)}',
                color: _getScoreColor(score),
              ),
              _PerformanceBadge(
                icon: cheatDetected ? Icons.warning : Icons.check_circle,
                text: cheatDetected ? 'Cheat Detected' : 'Clean Run',
                color: cheatDetected ? AppTheme.error : AppTheme.success,
              ),
              _PerformanceBadge(
                icon: Icons.trending_up,
                text: _analysis?['overall_rating'] ?? _getPerformanceLevel(score),
                color: AppTheme.accent,
              ),
              if (_videoInfo != null)
                _PerformanceBadge(
                  icon: Icons.videocam,
                  text: '${_videoInfo!['frame_count']} frames',
                  color: AppTheme.info,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Performance Trend',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _chartController,
              builder: (context, child) {
                return LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: 20,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: AppTheme.neutral200,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                            return Text(
                              labels[value.toInt() % labels.length],
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textTertiary,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        color: AppTheme.primary,
                        isCurved: true,
                        barWidth: 4,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.primary,
                              strokeWidth: 2,
                              strokeColor: AppTheme.surfaceContainer,
                            );
                          },
                        ),
                        spots: [
                          FlSpot(0, 40 * _chartController.value),
                          FlSpot(1, 55 * _chartController.value),
                          FlSpot(2, 60 * _chartController.value),
                          FlSpot(3, 62 * _chartController.value),
                          FlSpot(4, 70 * _chartController.value),
                          FlSpot(5, 78 * _chartController.value),
                          FlSpot(6, 82 * _chartController.value),
                        ],
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    final score = (_latest?['score'] ?? 0).toDouble();
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Analysis',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          _AnalysisItem(
            title: 'Form & Technique',
            score: (_analysis?['form_score'] ?? (score * 0.9)).toDouble().clamp(0, 100),
            description: 'Your movement patterns and body alignment',
          ),
          const SizedBox(height: 16),
          _AnalysisItem(
            title: 'Consistency',
            score: (_analysis?['consistency_score'] ?? (score * 0.85)).toDouble().clamp(0, 100),
            description: 'How consistent your performance was',
          ),
          const SizedBox(height: 16),
          _AnalysisItem(
            title: 'Power & Speed',
            score: (_analysis?['power_score'] ?? (score * 1.1)).toDouble().clamp(0, 100),
            description: 'Your explosive power and speed metrics',
          ),
          const SizedBox(height: 16),
          _AnalysisItem(
            title: 'Technical Execution',
            score: (_analysis?['technique_score'] ?? (score * 0.95)).toDouble().clamp(0, 100),
            description: 'Your technical skill and execution quality',
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendations',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_analysis?['recommendations'] != null)
            ...(_analysis!['recommendations'] as List<dynamic>).map((rec) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _RecommendationItem(
                  icon: _getRecommendationIcon(rec.toString()),
                  title: _getRecommendationTitle(rec.toString()),
                  description: rec.toString(),
                  priority: _getRecommendationPriority(rec.toString()),
                ),
              );
            }).toList()
          else ...[
            _RecommendationItem(
              icon: Icons.straighten,
              title: 'Improve Posture',
              description: 'Focus on maintaining a straight back and aligned shoulders during movements.',
              priority: 'High',
            ),
            const SizedBox(height: 16),
            _RecommendationItem(
              icon: Icons.speed,
              title: 'Increase Speed',
              description: 'Work on explosive movements and quick transitions between exercises.',
              priority: 'Medium',
            ),
            const SizedBox(height: 16),
            _RecommendationItem(
              icon: Icons.repeat,
              title: 'Practice Consistency',
              description: 'Regular practice will help improve your form and reduce variability.',
              priority: 'Low',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to full leaderboard
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_leaderboard.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.leaderboard_outlined,
                    size: 48,
                    color: AppTheme.textTertiary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No leaderboard data available',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
            )
          else
            ..._leaderboard.take(3).map((e) {
              final rank = e['rank'] as int? ?? 0;
              final name = e['name'] as String? ?? '';
              final score = e['score'] as int? ?? 0;
              final colorHex = (e['color'] as String? ?? '#2563EB').replaceFirst('#', '');
              final color = Color(int.parse('0xFF$colorHex'));
              return _LeaderItem(rank: rank, name: name, score: score, color: color);
            }).toList(),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return AppTheme.warning;
    return AppTheme.error;
  }

  String _getPerformanceLevel(double score) {
    if (score >= 90) return 'Elite';
    if (score >= 80) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 60) return 'Average';
    return 'Needs Improvement';
  }

  IconData _getRecommendationIcon(String recommendation) {
    if (recommendation.toLowerCase().contains('posture') || recommendation.toLowerCase().contains('alignment')) {
      return Icons.straighten;
    } else if (recommendation.toLowerCase().contains('speed') || recommendation.toLowerCase().contains('power')) {
      return Icons.speed;
    } else if (recommendation.toLowerCase().contains('consistency') || recommendation.toLowerCase().contains('pattern')) {
      return Icons.repeat;
    } else if (recommendation.toLowerCase().contains('technique') || recommendation.toLowerCase().contains('form')) {
      return Icons.sports_gymnastics;
    } else {
      return Icons.lightbulb_outline;
    }
  }

  String _getRecommendationTitle(String recommendation) {
    if (recommendation.toLowerCase().contains('posture') || recommendation.toLowerCase().contains('alignment')) {
      return 'Improve Posture';
    } else if (recommendation.toLowerCase().contains('speed') || recommendation.toLowerCase().contains('power')) {
      return 'Increase Speed';
    } else if (recommendation.toLowerCase().contains('consistency') || recommendation.toLowerCase().contains('pattern')) {
      return 'Practice Consistency';
    } else if (recommendation.toLowerCase().contains('technique') || recommendation.toLowerCase().contains('form')) {
      return 'Improve Technique';
    } else {
      return 'General Improvement';
    }
  }

  String _getRecommendationPriority(String recommendation) {
    if (recommendation.toLowerCase().contains('focus') || recommendation.toLowerCase().contains('important')) {
      return 'High';
    } else if (recommendation.toLowerCase().contains('work on') || recommendation.toLowerCase().contains('practice')) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }
}

class _PerformanceBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _PerformanceBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisItem extends StatelessWidget {
  final String title;
  final double score;
  final String description;

  const _AnalysisItem({
    required this.title,
    required this.score,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Text(
              '${score.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppTheme.primary,
              ),
            ),
            Text(
              'score',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String priority;

  const _RecommendationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (priority.toLowerCase()) {
      case 'high':
        priorityColor = AppTheme.error;
        break;
      case 'medium':
        priorityColor = AppTheme.warning;
        break;
      default:
        priorityColor = AppTheme.success;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: priorityColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priority,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderItem extends StatelessWidget {
  final int rank;
  final String name;
  final int score;
  final Color color;

  const _LeaderItem({
    required this.rank,
    required this.name,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$score',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

