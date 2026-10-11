class LiveDisplayState {
  final bool active;
  final String collection;
  final String docId;

  const LiveDisplayState({
    this.active = false,
    this.collection = '',
    this.docId = '',
  });
}
