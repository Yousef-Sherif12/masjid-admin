class AdminMessage {
  final String id;
  final String text;
  final String subText;
  final String fadl;
  final int duration;
  final String type;
  final double? fontSize;
  final int order;

  const AdminMessage({
    required this.id,
    required this.text,
    this.subText = '',
    this.fadl = '',
    this.duration = 10,
    required this.type,
    this.fontSize,
    this.order = 0,
  });
}
