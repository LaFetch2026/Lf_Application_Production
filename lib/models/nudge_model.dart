/// Nudge model — a server-driven contextual badge (e.g. "Selling Fast", "Trending").
class Nudge {
  final String key;
  final String label;
  final String source;

  const Nudge({
    required this.key,
    required this.label,
    required this.source,
  });

  factory Nudge.fromJson(Map<String, dynamic> json) {
    return Nudge(
      key: json['key'] as String? ?? '',
      label: json['label'] as String? ?? '',
      source: json['source'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'source': source,
      };

  @override
  bool operator ==(Object other) =>
      other is Nudge &&
      other.key == key &&
      other.label == label &&
      other.source == source;

  @override
  int get hashCode => Object.hash(key, label, source);
}
