import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:masjid_admin/core/utils/version_bumper.dart';
import 'package:masjid_admin/features/iqama/domain/repositories/iqama_repository.dart';

class IqamaRepositoryImpl implements IqamaRepository {
  final FirebaseFirestore _db;
  final VersionBumper _versionBumper;

  IqamaRepositoryImpl({
    FirebaseFirestore? firestore,
    VersionBumper? versionBumper,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _versionBumper = versionBumper ?? VersionBumper();

  DocumentReference<Map<String, dynamic>> get _docRef =>
      _db.collection('settings').doc('iqama_times');

  @override
  Future<Map<String, int>> getIqamaTimes() async {
    final doc = await _docRef.get();
    final data = doc.data() ?? {};
    return data.map((k, v) => MapEntry(k, ((v ?? 10) as num).toInt()));
  }

  @override
  Future<void> updateIqamaTimes(Map<String, int> times) async {
    await _docRef.set(times, SetOptions(merge: true));
    await _versionBumper.bumpIqamaVersion();
  }
}
