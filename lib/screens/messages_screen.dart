import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:masjid_admin/services/firebase_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.collectionKey,
    required this.collectionLabel,
  });

  final String collectionKey;
  final String collectionLabel;
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, String>> _collections = [];
  final Map<String, List<Map<String, dynamic>>> _data = {};
  Future<void> _initCollections() async {
    _collections = [
      {'key': widget.collectionKey, 'label': widget.collectionLabel},
    ];

    _tabController = TabController(length: 1, vsync: this);
    await _loadAll();
  }
  @override
  void initState() {
    super.initState();
    _initCollections();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    for (final col in _collections) {
      final msgs = await FirebaseService.getMessages(col['key']!);
      _data[col['key']!] = msgs;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _reload(String collection) async {
    final msgs = await FirebaseService.getMessages(collection);
    setState(() => _data[collection] = msgs);
  }

  void _showAddEditDialog({
    required String collection,
    Map<String, dynamic>? existing,
  }) {
    final textController = TextEditingController(text: existing?['text'] ?? '');
    final subTextController = TextEditingController(
      text: existing?['subText'] ?? '',
    );
    final fadlController = TextEditingController(text: existing?['fadl'] ?? '');
    final durationController = TextEditingController(
      text: existing?['duration']?.toString() ?? '10',
    );
    final fontSizeController = TextEditingController(
      text: existing?['fontSize']?.toString() ?? '',
    );

    showDialog(
      
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'إضافة نص جديد' : 'تعديل النص'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [SizedBox(height:10,),
              TextField(
                controller: textController,
                maxLines: 10,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  label: Text('النص *', style: TextStyle(fontSize: 20)),
                  
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subTextController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'المصدر / الراوي',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fadlController,
                textDirection: TextDirection.rtl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'الفضل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'مدة العرض (ثانية)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fontSizeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'حجم النص (اتركه فاضي للتلقائي)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textController.text.trim().isEmpty) return;
              Navigator.pop(ctx);

              final data = {
                'text': textController.text.trim(),
                'subText': subTextController.text.trim(),
                'fadl': fadlController.text.trim(),
                'duration': int.tryParse(durationController.text) ?? 10,
                'type': _getType(collection),
                'fontSize': fontSizeController.text.trim(),
              };

              if (existing == null) {
                await FirebaseService.addMessage(collection, data);
              } else {
                await FirebaseService.updateMessage(
                  collection,
                  existing['id'],
                  data,
                );
              }
              await _reload(collection);
            },
            child: Text(existing == null ? 'إضافة' : 'حفظ'),
          ),
        ],
      ),
    );
  }

  String _getType(String collection) {
    const types = {
      'quran_messages': 'quran',
      'hadith_messages': 'hadith',
      'thaqil': 'thaqil',
      'prayer_from_quran': 'prayer',
      'adhkar_salah': 'adhkar_salah',
      'adhkar_sabah': 'adhkar_sabah',
      'adhkar_masa': 'adhkar_masa',
    };
    return types[collection] ?? '';
  }

  void _confirmDelete(String collection, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هتحذف النص ده؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.deleteMessage(collection, docId);
              await _reload(collection);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('النصوص'),
        bottom: TabBar(
          tabAlignment: TabAlignment.start,
          controller: _tabController,
          isScrollable: true,
          tabs: _collections.map((c) => Tab(text: c['label'])).toList(),
        ),
        actions: [
          // ✅ زرار إيقاف العرض المباشر
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseService.getLiveDisplayStream(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final isActive = data?['active'] == true;
              if (!isActive) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.cast_connected, color: Colors.green),
                tooltip: 'إيقاف العرض المباشر',
                onPressed: () async {
                  await FirebaseService.clearLiveDisplay();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم إيقاف العرض')),
                    );
                  }
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAll),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseService.getLiveDisplayStream(),
              builder: (context, liveSnapshot) {
                final liveData =
                    liveSnapshot.data?.data() as Map<String, dynamic>?;

                // نقوم بالتأكد أن القيمة bool وصريحة
                final bool isActive =
                    liveData != null && liveData['active'] == true;

                final activeDocId = isActive ? liveData['docId'] : null;
                return TabBarView(
                  controller: _tabController,
                  children: _collections.map((col) {
                    final key = col['key']!;
                    final items = _data[key] ?? [];
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${items.length} نص'),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('إضافة'),
                                onPressed: () =>
                                    _showAddEditDialog(collection: key),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ReorderableListView.builder(
                            itemCount: items.length,
                            onReorder: (oldIndex, newIndex) async {
                              if (newIndex > oldIndex) newIndex--;
                              final list = List<Map<String, dynamic>>.from(
                                items,
                              );
                              final item = list.removeAt(oldIndex);
                              list.insert(newIndex, item);
                              setState(() => _data[key] = list);
                              await FirebaseService.reorderMessages(key, list);
                            },
                            itemBuilder: (ctx, i) {
                              final item = items[i];
                              final isThisActive = activeDocId == item['id'];

                              return ListTile(
                                key: ValueKey(item['id']),
                                leading: CircleAvatar(child: Text('${i + 1}')),
                                title: Text(
                                  item['text'] ?? '',
                                  textDirection: TextDirection.rtl,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle:
                                    item['subText'] != null &&
                                        item['subText'].toString().isNotEmpty
                                    ? Text(
                                        item['subText'],
                                        textDirection: TextDirection.rtl,
                                      )
                                    : null,
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // ✅ زرار Cast بيتغير حسب الحالة
                                    IconButton(
                                      icon: Icon(
                                        isThisActive
                                            ? Icons.cast_connected
                                            : Icons.cast,
                                        color: isThisActive
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      onPressed: () async {
                                        await FirebaseService.setLiveDisplay(
                                          key,
                                          item['id'],
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed: () => _showAddEditDialog(
                                        collection: key,
                                        existing: item,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(key, item['id']),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}