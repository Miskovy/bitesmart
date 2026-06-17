import 'package:bite_smart/core/network/api_client.dart';

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return double.tryParse(value)?.toInt() ?? 0;
  return 0;
}

class CommunityChallenge {
  final String id;
  final String title;
  final String description;
  final String category; // 'Diet' | 'Hydration' | 'Activity'
  final int targetValue;
  final String unit;
  final int pointsReward;
  final int durationDays;
  final bool isJoined;
  final int currentProgress;
  final int participantsCount;

  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetValue,
    required this.unit,
    required this.pointsReward,
    required this.durationDays,
    required this.isJoined,
    required this.currentProgress,
    required this.participantsCount,
  });

  CommunityChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? targetValue,
    String? unit,
    int? pointsReward,
    int? durationDays,
    bool? isJoined,
    int? currentProgress,
    int? participantsCount,
  }) {
    return CommunityChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetValue: targetValue ?? this.targetValue,
      unit: unit ?? this.unit,
      pointsReward: pointsReward ?? this.pointsReward,
      durationDays: durationDays ?? this.durationDays,
      isJoined: isJoined ?? this.isJoined,
      currentProgress: currentProgress ?? this.currentProgress,
      participantsCount: participantsCount ?? this.participantsCount,
    );
  }

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) {
    final titleStr = (json['title'] as String? ?? '').toLowerCase();
    
    // Dynamically infer category if not present
    String cat = json['category'] as String? ?? '';
    if (cat.isEmpty) {
      if (titleStr.contains('sugar') || titleStr.contains('diet') || titleStr.contains('fasting') || titleStr.contains('eat')) {
        cat = 'Diet';
      } else if (titleStr.contains('hydration') || titleStr.contains('water') || titleStr.contains('drink')) {
        cat = 'Hydration';
      } else {
        cat = 'Activity';
      }
    }

    // Dynamically infer targetValue and unit if not present
    int targetVal = _toInt(json['targetValue'] ?? json['target']);
    String unitStr = json['unit'] as String? ?? '';
    if (targetVal == 0) {
      if (titleStr.contains('sugar')) {
        targetVal = 7;
        unitStr = 'days';
      } else if (titleStr.contains('hydration') || titleStr.contains('water')) {
        targetVal = 8;
        unitStr = 'cups';
      } else if (titleStr.contains('10k') || titleStr.contains('steps')) {
        targetVal = 10000;
        unitStr = 'steps';
      } else {
        targetVal = 10;
        unitStr = 'mins';
      }
    }

    // Dynamically parse durationDays using dates if duration is missing
    int duration = _toInt(json['durationDays'] ?? json['duration']);
    if (duration == 0) {
      final startStr = json['startDate'] as String?;
      final endStr = json['endDate'] as String?;
      if (startStr != null && endStr != null) {
        try {
          final start = DateTime.parse(startStr);
          final end = DateTime.parse(endStr);
          duration = end.difference(start).inDays;
        } catch (_) {}
      }
      if (duration <= 0) {
        duration = _toInt(json['daysLeft'] ?? 7);
      }
      if (duration <= 0) duration = 7;
    }

    return CommunityChallenge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: cat,
      targetValue: targetVal,
      unit: unitStr,
      pointsReward: _toInt(json['pointsReward'] ?? json['rewardXp'] ?? 100),
      durationDays: duration,
      isJoined: json['isJoined'] ?? false,
      currentProgress: _toInt(json['currentProgress'] ?? json['progress']),
      participantsCount: _toInt(json['participantsCount']),
    );
  }
}

class LeaderboardPlayer {
  final int rank;
  final String name;
  final int xp;
  final String role;
  final String? avatar;
  final bool isCurrentUser;

  const LeaderboardPlayer({
    required this.rank,
    required this.name,
    required this.xp,
    required this.role,
    this.avatar,
    this.isCurrentUser = false,
  });

  LeaderboardPlayer copyWith({
    int? rank,
    String? name,
    int? xp,
    String? role,
    String? avatar,
    bool? isCurrentUser,
  }) {
    return LeaderboardPlayer(
      rank: rank ?? this.rank,
      name: name ?? this.name,
      xp: xp ?? this.xp,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
    );
  }

  factory LeaderboardPlayer.fromJson(Map<String, dynamic> json) {
    return LeaderboardPlayer(
      rank: _toInt(json['rank']),
      name: json['name'] as String? ?? '',
      xp: _toInt(json['xp']),
      role: json['role'] as String? ?? 'Starter',
      avatar: json['avatar'] as String?,
      isCurrentUser: json['isCurrentUser'] ?? false,
    );
  }
}

class LeaderboardData {
  final int userRank;
  final String userName;
  final int userXp;
  final int userPercentile;
  final String? userAvatar;
  final List<LeaderboardPlayer> podium;
  final List<LeaderboardPlayer> globalList;
  final LeaderboardPlayer? userPositionOutsideTop;
  final List<LeaderboardPlayer> friends;

  const LeaderboardData({
    required this.userRank,
    required this.userName,
    required this.userXp,
    required this.userPercentile,
    this.userAvatar,
    required this.podium,
    required this.globalList,
    this.userPositionOutsideTop,
    required this.friends,
  });

  LeaderboardData copyWith({
    int? userRank,
    String? userName,
    int? userXp,
    int? userPercentile,
    String? userAvatar,
    List<LeaderboardPlayer>? podium,
    List<LeaderboardPlayer>? globalList,
    LeaderboardPlayer? userPositionOutsideTop,
    List<LeaderboardPlayer>? friends,
  }) {
    return LeaderboardData(
      userRank: userRank ?? this.userRank,
      userName: userName ?? this.userName,
      userXp: userXp ?? this.userXp,
      userPercentile: userPercentile ?? this.userPercentile,
      userAvatar: userAvatar ?? this.userAvatar,
      podium: podium ?? this.podium,
      globalList: globalList ?? this.globalList,
      userPositionOutsideTop: userPositionOutsideTop ?? this.userPositionOutsideTop,
      friends: friends ?? this.friends,
    );
  }

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    final curUser = json['currentUser'] as Map<String, dynamic>? ?? {};
    final global = json['global'] as Map<String, dynamic>? ?? {};
    final podiumList = global['podium'] as List? ?? [];
    final listList = global['list'] as List? ?? [];
    final outside = global['userPosition'] as Map<String, dynamic>?;
    final friendsList = json['friends'] as List? ?? [];

    return LeaderboardData(
      userRank: _toInt(curUser['rank']),
      userName: curUser['name'] ?? 'You',
      userXp: _toInt(curUser['xp']),
      userPercentile: _toInt(curUser['percentile']),
      userAvatar: curUser['avatar'] as String?,
      podium: podiumList.map((item) => LeaderboardPlayer.fromJson(item as Map<String, dynamic>)).toList(),
      globalList: listList.map((item) => LeaderboardPlayer.fromJson(item as Map<String, dynamic>)).toList(),
      userPositionOutsideTop: outside != null ? LeaderboardPlayer.fromJson(outside) : null,
      friends: friendsList.map((item) => LeaderboardPlayer.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

abstract class IEngagementRepository {
  Future<List<CommunityChallenge>> getChallenges();
  Future<void> joinChallenge(String id);
  Future<void> leaveChallenge(String id);
  Future<LeaderboardData> getLeaderboard();
}

class EngagementRepository implements IEngagementRepository {
  @override
  Future<List<CommunityChallenge>> getChallenges() async {
    final response = await ApiClient.instance.get('/challenges');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final List list = resBody['data'] as List? ?? [];
      return list.map((item) => CommunityChallenge.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(resBody['message'] ?? 'Failed to load challenges');
  }

  @override
  Future<void> joinChallenge(String id) async {
    final response = await ApiClient.instance.post('/challenges/$id/join');
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to join challenge');
    }
  }

  @override
  Future<void> leaveChallenge(String id) async {
    final response = await ApiClient.instance.post('/challenges/$id/leave');
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to leave challenge');
    }
  }

  @override
  Future<LeaderboardData> getLeaderboard() async {
    final response = await ApiClient.instance.get('/leaderboard');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final data = resBody['data'] as Map<String, dynamic>;
      return LeaderboardData.fromJson(data);
    }
    throw Exception(resBody['message'] ?? 'Failed to load leaderboard');
  }
}
