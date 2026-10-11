abstract class IqamaRepository {
  Future<Map<String, int>> getIqamaTimes();
  Future<void> updateIqamaTimes(Map<String, int> times);
}
