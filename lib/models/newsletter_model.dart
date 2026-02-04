/// Newsletter Model
class NewsletterModel {
  final int id;
  final String title;
  final String content;
  final String imageUrl;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  NewsletterModel({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsletterModel.fromJson(Map<String, dynamic> json) {
    return NewsletterModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'image_url': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
