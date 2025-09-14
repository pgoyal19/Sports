import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../providers/athlete_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/auth_service.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';
import '../widgets/language_selector.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabController.forward();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomePage(),
      _DiscoverPage(),
      _ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.sports,
                color: AppTheme.textOnPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('GoChamp'),
          ],
        ),
        actions: [
          _NotificationButton(),
          const SizedBox(width: 8),
          _ProfileMenu(),
          const SizedBox(width: 16),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          boxShadow: [
            BoxShadow(
              color: AppTheme.neutral200,
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
        destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.leaderboard_outlined),
              selectedIcon: Icon(Icons.leaderboard),
              label: 'Discover',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, '/ar-setup'),
        icon: const Icon(Icons.camera_alt),
              label: const Text('Start Test'),
              backgroundColor: AppTheme.primary,
              foregroundColor: AppTheme.textOnPrimary,
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.notifications_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.error,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final athleteProvider = Provider.of<AthleteProvider>(context);
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: athleteProvider.isLoggedIn 
              ? AppTheme.primaryGradient 
              : LinearGradient(colors: [AppTheme.neutral300, AppTheme.neutral400]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          athleteProvider.isLoggedIn ? Icons.person : Icons.person_outline,
          color: AppTheme.textOnPrimary,
          size: 20,
        ),
      ),
      onSelected: (value) async {
        if (value == 'login') {
          Navigator.pushNamed(context, '/phone-auth');
        } else if (value == 'language') {
          Navigator.pushNamed(context, '/language-settings');
        } else if (value == 'logout') {
          await AuthService.logout();
          athleteProvider.logout();
          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        }
      },
      itemBuilder: (context) => [
        if (!athleteProvider.isLoggedIn)
          const PopupMenuItem(
            value: 'login',
            child: Row(
              children: [
                Icon(Icons.login, color: AppTheme.primary),
                SizedBox(width: 12),
                Text('Login'),
              ],
            ),
          )
        else ...[
          const PopupMenuItem(
            value: 'language',
            child: Row(
              children: [
                Icon(Icons.language, color: AppTheme.primary),
                SizedBox(width: 12),
                Text('Language'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, color: AppTheme.error),
                SizedBox(width: 12),
                Text('Logout'),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gamificationProvider, child) {
    return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Welcome Section
            _WelcomeSection(),
            const SizedBox(height: 24),
            
            // Quick Stats
            _QuickStatsSection(gamificationProvider: gamificationProvider),
            const SizedBox(height: 24),
            
            // Main Action Cards
            _ActionCardsSection(),
            const SizedBox(height: 24),
            
            // Recent Activity
            _RecentActivitySection(),
            const SizedBox(height: 24),
            
            // Achievement Badges
            _AchievementSection(gamificationProvider: gamificationProvider),
            const SizedBox(height: 100), // Space for FAB
          ],
        );
      },
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AthleteProvider>(
      builder: (context, athleteProvider, child) {
        final athlete = athleteProvider.currentAthlete;
        final greeting = _getGreeting();
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting${athlete?.name ?? 'Athlete'}!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                athlete != null 
                    ? 'Ready to push your limits in ${athlete.sport}?'
                    : 'Ready to discover your sporting potential?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textOnPrimary.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.textOnPrimary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: AppTheme.textOnPrimary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Powered Assessment',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning, ';
    if (hour < 17) return 'Good Afternoon, ';
    return 'Good Evening, ';
  }
}

class _QuickStatsSection extends StatelessWidget {
  final GamificationProvider gamificationProvider;

  const _QuickStatsSection({required this.gamificationProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Level',
            value: '${gamificationProvider.currentLevel}',
            icon: Icons.star,
            color: AppTheme.accent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Score',
            value: '${gamificationProvider.totalScore}',
            icon: Icons.emoji_events,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Streak',
            value: '${gamificationProvider.currentStreak}',
            icon: Icons.local_fire_department,
            color: AppTheme.error,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCardsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
      children: [
            Expanded(
              child: _ActionCard(
                title: 'Start Test',
                subtitle: 'AI-powered assessment',
          icon: Icons.play_circle_fill,
                color: AppTheme.primary,
          onTap: () => Navigator.pushNamed(context, '/ar-setup'),
        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'View Results',
                subtitle: 'Your performance',
          icon: Icons.insights,
                color: AppTheme.secondary,
          onTap: () => Navigator.pushNamed(context, '/results'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                title: 'Leaderboard',
                subtitle: 'See rankings',
                icon: Icons.leaderboard,
                color: AppTheme.accent,
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionCard(
                title: 'Profile',
                subtitle: 'Manage account',
                icon: Icons.person,
                color: AppTheme.info,
                onTap: () => Navigator.pushNamed(context, '/avatar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/results'),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Column(
            children: [
              _ActivityItem(
                icon: Icons.trending_up,
                title: 'Vertical Jump Test',
                subtitle: 'Score: 85/100',
                time: '2 hours ago',
                color: AppTheme.success,
              ),
              const Divider(height: 24),
              _ActivityItem(
                icon: Icons.emoji_events,
                title: 'New Achievement',
                subtitle: 'First Steps Badge',
                time: 'Yesterday',
                color: AppTheme.accent,
              ),
              const Divider(height: 24),
              _ActivityItem(
                icon: Icons.leaderboard,
                title: 'Rank Improved',
                subtitle: 'Moved up 3 positions',
                time: '2 days ago',
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textTertiary,
          ),
        ),
      ],
    );
  }
}

class _AchievementSection extends StatelessWidget {
  final GamificationProvider gamificationProvider;

  const _AchievementSection({required this.gamificationProvider});

  @override
  Widget build(BuildContext context) {
    final badges = gamificationProvider.earnedBadges;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 100,
          child: badges.isEmpty
              ? _EmptyAchievements()
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: badges.length,
                  itemBuilder: (context, index) {
                    final badge = badges[index];
                    return _AchievementBadge(badge: badge);
                  },
                ),
        ),
      ],
    );
  }
}

class _EmptyAchievements extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.neutral50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.neutral200,
          width: 1,
        ),
      ),
      child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(
              Icons.emoji_events_outlined,
              color: AppTheme.textTertiary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete tests to earn badges!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final dynamic badge; // Using dynamic for now since Badge class is in gamification_provider

  const _AchievementBadge({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.emoji_events,
              color: AppTheme.accent,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Badge',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DiscoverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Text(
          'Discover',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Explore top athletes and trending sports',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        // Quick Stats
        Row(
          children: [
            Expanded(
              child: _DiscoverStatCard(
                title: 'Active Athletes',
                value: '2.4K',
                icon: Icons.people,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiscoverStatCard(
                title: 'Tests Today',
                value: '156',
                icon: Icons.analytics,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Featured Athletes
        Text(
          'Featured Athletes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return _FeaturedAthleteCard(index: index);
            },
          ),
        ),
        const SizedBox(height: 24),

        // Quick Actions
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _DiscoverActionCard(
                title: 'Leaderboard',
                subtitle: 'See rankings',
                icon: Icons.leaderboard,
                color: AppTheme.accent,
                onTap: () => Navigator.pushNamed(context, '/leaderboard'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DiscoverActionCard(
                title: 'SAI Dashboard',
                subtitle: 'Official stats',
                icon: Icons.dashboard,
                color: AppTheme.info,
                onTap: () => Navigator.pushNamed(context, '/sai-dashboard'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DiscoverStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DiscoverStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedAthleteCard extends StatelessWidget {
  final int index;

  const _FeaturedAthleteCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final athletes = [
      {'name': 'Arjun Mehta', 'sport': 'Athletics', 'score': 98, 'location': 'Karnataka'},
      {'name': 'Priya Sharma', 'sport': 'Basketball', 'score': 95, 'location': 'Maharashtra'},
      {'name': 'Rohit Singh', 'sport': 'Football', 'score': 92, 'location': 'Punjab'},
    ];
    
    final athlete = athletes[index];
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Center(
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.textOnPrimary.withOpacity(0.2),
                  child: Text(
                    (athlete['name'] as String? ?? 'A')[0],
                    style: const TextStyle(
                      color: AppTheme.textOnPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  athlete['name'] as String? ?? 'Unknown',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  athlete['sport'] as String? ?? 'General',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
          const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: ${athlete['score']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      athlete['location'] as String? ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoverActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DiscoverActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AthleteProvider>(
      builder: (context, athleteProvider, child) {
        final athlete = athleteProvider.currentAthlete;
        
    if (athlete == null) {
          return _NotLoggedInProfile();
        }
        
        return _LoggedInProfile(athlete: athlete);
      },
    );
  }
}

class _NotLoggedInProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                size: 60,
                color: AppTheme.textTertiary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Welcome to GoChamp',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your profile to start your sports journey',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Get Started'),
            ),
          ],
        ),
        ),
      );
    }
}

class _LoggedInProfile extends StatelessWidget {
  final dynamic athlete; // Using dynamic for AthleteProfile

  const _LoggedInProfile({required this.athlete});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Profile Header
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.textOnPrimary.withOpacity(0.2),
                child: athlete.avatarPath.isNotEmpty
                    ? ClipOval(
                        child: Image.asset(
                          athlete.avatarPath,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Text(
                        athlete.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textOnPrimary,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Text(
                athlete.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                athlete.sport,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textOnPrimary.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                athlete.location,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textOnPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Profile Stats
        Row(
      children: [
            Expanded(
              child: _ProfileStatCard(
                title: 'Level',
                value: '${athlete.level}',
                icon: Icons.star,
                color: AppTheme.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileStatCard(
                title: 'Experience',
                value: '${athlete.experience}',
                icon: Icons.trending_up,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ProfileStatCard(
                title: 'Tests',
                value: '${athlete.testHistory.length}',
                icon: Icons.analytics,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Profile Actions
        Text(
          'Account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        _ProfileActionTile(
          icon: Icons.history,
          title: 'Test History',
          subtitle: 'View your performance',
          onTap: () => Navigator.pushNamed(context, '/results'),
        ),
        _ProfileActionTile(
          icon: Icons.edit,
          title: 'Edit Profile',
          subtitle: 'Update your information',
          onTap: () => Navigator.pushNamed(context, '/avatar'),
        ),
        _ProfileActionTile(
          icon: Icons.settings,
          title: 'Settings',
          subtitle: 'App preferences',
          onTap: () {},
        ),
        _ProfileActionTile(
          icon: Icons.logout,
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () {
            Provider.of<AthleteProvider>(context, listen: false).logout();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Logged out successfully'),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          isDestructive: true,
        ),
      ],
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDestructive 
                ? AppTheme.error.withOpacity(0.1)
                : AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppTheme.error : AppTheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.error : AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppTheme.textTertiary,
        ),
        onTap: onTap,
      ),
    );
  }
}


