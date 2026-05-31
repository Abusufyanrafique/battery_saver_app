class JunkItem {
  final String label;
  final String size;
  final double sizeInMB;
  final bool isChecked;

  const JunkItem({
    required this.label,
    required this.size,
    required this.sizeInMB,
    required this.isChecked,
  });

  JunkItem copyWith({
    String? label,
    String? size,
    double? sizeInMB,
    bool? isChecked,
  }) {
    return JunkItem(
      label: label ?? this.label,
      size: size ?? this.size,
      sizeInMB: sizeInMB ?? this.sizeInMB,
      isChecked: isChecked ?? this.isChecked,
    );
  }
}