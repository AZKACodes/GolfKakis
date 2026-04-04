class SessionVisitor {
  const SessionVisitor({
    required this.id,
    required this.platform,
    required this.lastSeenAt,
    this.linkedUserId,
  });

  final String id;
  final String platform;
  final String? linkedUserId;
  final DateTime lastSeenAt;

  SessionVisitor copyWith({
    String? id,
    String? platform,
    String? linkedUserId,
    DateTime? lastSeenAt,
    bool clearLinkedUserId = false,
  }) {
    return SessionVisitor(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      linkedUserId: clearLinkedUserId
          ? null
          : (linkedUserId ?? this.linkedUserId),
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'platform': platform,
      'linked_user_id': linkedUserId,
      'last_seen_at': lastSeenAt.toUtc().toIso8601String(),
    };
  }

  factory SessionVisitor.fromJson(Map<String, dynamic> json) {
    return SessionVisitor(
      id: json['id'] as String? ?? '',
      platform: json['platform'] as String? ?? '',
      linkedUserId: json['linked_user_id'] as String?,
      lastSeenAt:
          DateTime.tryParse(json['last_seen_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
