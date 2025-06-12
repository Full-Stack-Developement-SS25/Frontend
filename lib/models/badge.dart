class Badge {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final String awardedAt;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.awardedAt,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconUrl: json['icon_url'],
      awardedAt: json['awarded_at'],
    );
  }
}
