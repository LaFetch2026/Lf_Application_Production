enum ChipType { category, contextual }

class FilterChipItem {
  final String label;
  final ChipType type;
  final int id;
  final int count;

  const FilterChipItem({
    required this.label,
    required this.type,
    required this.id,
    required this.count,
  });

  factory FilterChipItem.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString() ?? '';
    final chipType =
        typeStr == 'contextual' ? ChipType.contextual : ChipType.category;

    return FilterChipItem(
      label: json['label']?.toString() ?? '',
      type: chipType,
      id: (json['id'] as num?)?.toInt() ?? 0,
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        'type': type == ChipType.contextual ? 'contextual' : 'category',
        'id': id,
        'count': count,
      };

  /// Returns the query parameter key/value pair for this chip.
  /// Category chips set subCatId; contextual chips set contextualCategoryId.
  MapEntry<String, String> get queryParam => type == ChipType.category
      ? MapEntry('subCatId', id.toString())
      : MapEntry('contextualCategoryId', id.toString());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterChipItem &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          type == other.type &&
          id == other.id &&
          count == other.count;

  @override
  int get hashCode => Object.hash(label, type, id, count);

  @override
  String toString() =>
      'FilterChipItem(label: $label, type: $type, id: $id, count: $count)';
}
