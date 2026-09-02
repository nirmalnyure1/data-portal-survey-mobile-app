import 'package:equatable/equatable.dart';

class UserLoyaltyModel extends Equatable {
  final String? tier;
  final String? tierImage;
  final int lifetimePointsEarned;
  final int balancePoints;
  final String? nextTier;
  final String? nextTierImage;
  final int? pointsToNextTier;

  const UserLoyaltyModel({
    this.tier,
    this.tierImage,
    this.lifetimePointsEarned = 0,
    this.balancePoints = 0,
    this.nextTier,
    this.nextTierImage,
    this.pointsToNextTier,
  });

  bool get isMaxLevel => nextTier == null || pointsToNextTier == null;

  int get progressTarget => isMaxLevel
      ? lifetimePointsEarned
      : lifetimePointsEarned + pointsToNextTier!;

  int get progressPercent {
    if (isMaxLevel) return 100;
    final total = lifetimePointsEarned + pointsToNextTier!;
    if (total <= 0) return 0;
    final percent = ((lifetimePointsEarned / total) * 100).round();
    return percent > 100 ? 100 : percent;
  }

  double get progress => progressPercent / 100;

  int get pointsToNext => isMaxLevel ? 0 : pointsToNextTier!;

  factory UserLoyaltyModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserLoyaltyModel();

    return UserLoyaltyModel(
      tier: map['tier']?.toString(),
      tierImage: map['tierImage']?.toString(),
      lifetimePointsEarned: (map['lifetimePointsEarned'] as num?)?.toInt() ?? 0,
      balancePoints: (map['balancePoints'] as num?)?.toInt() ?? 0,
      nextTier: map['nextTier']?.toString(),
      nextTierImage: map['nextTierImage']?.toString(),
      pointsToNextTier: (map['pointsToNextTier'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tier': tier,
      'tierImage': tierImage,
      'lifetimePointsEarned': lifetimePointsEarned,
      'balancePoints': balancePoints,
      'nextTier': nextTier,
      'nextTierImage': nextTierImage,
      'pointsToNextTier': pointsToNextTier,
    };
  }

  @override
  List<Object?> get props => [
    tier,
    tierImage,
    lifetimePointsEarned,
    balancePoints,
    nextTier,
    nextTierImage,
    pointsToNextTier,
  ];
}
