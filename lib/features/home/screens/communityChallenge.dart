import 'package:bite_smart/features/home/screens/leadeerBoard.dart';
import 'package:flutter/material.dart';

class FeaturedChallenge {
  final String badge;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const FeaturedChallenge({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}

class Challenge {
  final String emoji;
  final Color iconBg;
  final String name;
  final String meta;
  final List<String> avatarInitials;
  final List<Color> avatarColors;
  final String participantCount;
  final String statusLabel;
  final ChallengeStatus status;
  final double progress;
  final Color progressColor;

  const Challenge({
    required this.emoji,
    required this.iconBg,
    required this.name,
    required this.meta,
    required this.avatarInitials,
    required this.avatarColors,
    required this.participantCount,
    required this.statusLabel,
    required this.status,
    required this.progress,
    required this.progressColor,
  });
}

enum ChallengeStatus { join, joined, preRegister }

// ─── Main Screen ─────────────────────────────────────────────────────────────

class CommunityChallengesScreen extends StatefulWidget {
  const CommunityChallengesScreen({super.key});

  @override
  State<CommunityChallengesScreen> createState() =>
      _CommunityChallengesScreenState();
}

class _CommunityChallengesScreenState extends State<CommunityChallengesScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All Active', 'My Challenges', 'Starting'];

  final List<FeaturedChallenge> _featured = const [
    FeaturedChallenge(
      badge: '🔥 TRENDING',
      title: '7-Day Sugar-Free',
      subtitle: 'Reset your insulin levels and...',
      gradient: [Color(0xFF2d7a4f), Color(0xFF1a5c38)],
    ),
    FeaturedChallenge(
      badge: '✨ NEW',
      title: 'Protein Power',
      subtitle: 'Hit your daily protein goals...',
      gradient: [Color(0xFF534AB7), Color(0xFF3C3489)],
    ),
  ];

  final List<Challenge> _challenges = const [
    Challenge(
      emoji: '🚶',
      iconBg: Color(0xFFFFF4E8),
      name: 'Walk 10k Steps',
      meta: 'Daily Goal · 2 days left',
      avatarInitials: ['A', 'K', 'M'],
      avatarColors: [Color(0xFFE87040), Color(0xFF534AB7), Color(0xFF2d7a4f)],
      participantCount: '+1.2k',
      statusLabel: 'Join',
      status: ChallengeStatus.join,
      progress: 0.70,
      progressColor: Color(0xFF2d7a4f),
    ),
    Challenge(
      emoji: '💧',
      iconBg: Color(0xFFE8F4FF),
      name: 'Hydration Station',
      meta: 'Habit Building · 5 days left',
      avatarInitials: ['S', 'J'],
      avatarColors: [Color(0xFFD4537E), Color(0xFF534AB7)],
      participantCount: '+8k',
      statusLabel: 'Joined',
      status: ChallengeStatus.joined,
      progress: 0.40,
      progressColor: Color(0xFF378ADD),
    ),
    Challenge(
      emoji: '🧘',
      iconBg: Color(0xFFEEEEFE),
      name: 'Mindful Minutes',
      meta: 'Wellness · Starts tomorrow',
      avatarInitials: ['L'],
      avatarColors: [Color(0xFFE87040)],
      participantCount: '+340',
      statusLabel: 'Join',
      status: ChallengeStatus.join,
      progress: 0.0,
      progressColor: Color(0xFF9FE1CB),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildFeaturedSection(),
              _buildTabs(),
              _buildOngoingSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  [
              Text(
                'Community Challenges',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Push your limits together.',
                style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDDDDDD), width: 0.5),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 18,
              color: Color(0xFF555555),
            ),
          ),
        ],
      ),
    );
  }

  // ── Featured ──────────────────────────────────────────────────────────────

  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Featured',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                ),
                child: const Text('Leaderboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1A1A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) =>
                _buildFeaturedCard(_featured[index]),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildFeaturedCard(FeaturedChallenge c) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: c.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  c.subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: const Text(
                    'Join Challenge',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────

  Widget _buildTabs() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEBEBE6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final selected = i == _selectedTab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : [],
                      ),
                      margin: const EdgeInsets.all(3),
                      alignment: Alignment.center,
                      child: Text(
                        _tabs[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? const Color(0xFF1A1A1A)
                              : const Color(0xFF888888),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  // ── Ongoing Challenges ────────────────────────────────────────────────────

  Widget _buildOngoingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Text(
            'Ongoing Challenges',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        ...(_challenges
            .map(
              (c) => Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 5,
                ),
                child: _buildChallengeCard(c),
              ),
            )
            .toList()),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge c) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: c.iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 10),
              // Name & meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      c.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      c.meta,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Action button
              _buildActionButton(c.status, c.statusLabel),
            ],
          ),
          const SizedBox(height: 10),
          // Footer row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildAvatars(c.avatarInitials, c.avatarColors),
                  const SizedBox(width: 8),
                  Text(
                    c.participantCount,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
              Text(
                c.status == ChallengeStatus.joined
                    ? 'Your Progress: ${(c.progress * 100).toInt()}%'
                    : c.status == ChallengeStatus.preRegister
                    ? 'Pre-registration'
                    : '${(c.progress * 100).toInt()}% Global Goal',
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFFAAAAAA),
                  fontStyle: c.status == ChallengeStatus.preRegister
                      ? FontStyle.italic
                      : FontStyle.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: c.progress,
              minHeight: 5,
              backgroundColor: const Color(0xFFF0F0EC),
              valueColor: AlwaysStoppedAnimation<Color>(c.progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ChallengeStatus status, String label) {
    switch (status) {
      case ChallengeStatus.joined:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2d7a4f),
            side: const BorderSide(color: Color(0xFF2d7a4f), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            '✓ $label',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
      case ChallengeStatus.preRegister:
        return OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF555555),
            side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
      default:
        return ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A1A),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        );
    }
  }

  Widget _buildAvatars(List<String> initials, List<Color> colors) {
    return SizedBox(
      width: initials.length * 18.0 + 6,
      height: 24,
      child: Stack(
        children: List.generate(initials.length, (i) {
          return Positioned(
            left: i * 18.0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: colors[i],
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  initials[i],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
