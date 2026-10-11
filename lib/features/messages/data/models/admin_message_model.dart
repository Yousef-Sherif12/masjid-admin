import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';

class AdminMessageModel extends AdminMessage {
  const AdminMessageModel({
    required super.id,
    required super.text,
    super.subText,
    super.fadl,
    super.duration,
    required super.type,
    super.fontSize,
    super.order,
  });

  factory AdminMessageModel.fromMap(String id, Map<String, dynamic> map) {
    double? parsedFontSize;
    final rawFontSize = map['fontSize'];
    if (rawFontSize is num) {
      parsedFontSize = rawFontSize.toDouble();
    } else if (rawFontSize is String && rawFontSize.trim().isNotEmpty) {
      parsedFontSize = double.tryParse(rawFontSize.trim());
    }

    int parsedDuration = 10;
    final rawDuration = map['duration'];
    if (rawDuration is num) {
      parsedDuration = rawDuration.toInt();
    } else if (rawDuration is String) {
      parsedDuration = int.tryParse(rawDuration.trim()) ?? 10;
    }

    return AdminMessageModel(
      id: id,
      text: (map['text'] ?? '').toString(),
      subText: (map['subText'] ?? '').toString(),
      fadl: (map['fadl'] ?? '').toString(),
      duration: parsedDuration,
      type: (map['type'] ?? '').toString(),
      fontSize: parsedFontSize,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'subText': subText,
      'fadl': fadl,
      'duration': duration,
      'type': type,
      'fontSize': fontSize,
      'order': order,
    };
  }
}
