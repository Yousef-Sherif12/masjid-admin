import 'package:flutter/material.dart';
import 'package:masjid_admin/screens/messages_screen.dart';
import 'package:masjid_admin/services/firebase_service.dart';

class CollectionsScreen extends StatefulWidget {
  const CollectionsScreen({super.key});

  @override
  State<CollectionsScreen> createState() => _CollectionsScreenState();
}

class _CollectionsScreenState extends State<CollectionsScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _collections = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    _collections = await FirebaseService.getCollectionsConfig();
    setState(() => _isLoading = false);
  }

  void _showAddCollectionDialog() {
    final labelController = TextEditingController();
    final keyController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shadowColor: Colors.green,
        surfaceTintColor: Colors.white,
        title: const Text('إضافة مجموعة جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                labelText: 'اسم المجموعة',
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                hintText: 'قال الله تعالى',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'مفتاح المجموعة',

                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                hintText: 'ramadan',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'إلغاء',
              style: TextStyle(color: Colors.red, fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (labelController.text.trim().isEmpty ||
                  keyController.text.trim().isEmpty) {
                return;
              }
              Navigator.pop(ctx);
              await FirebaseService.addCollection(
                key: keyController.text.trim().replaceAll(' ', '_'),
                label: labelController.text.trim(),
              );
              await _load();
            },
            child: const Text(
              'إضافة',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'المجموعات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh_sharp), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('مجموعة جديدة'),
        onPressed: _showAddCollectionDialog,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _collections.isEmpty
          ? const Center(child: Text('لا يوجد مجموعات'))
          : ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _collections.length,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) newIndex--;
                final list = List<Map<String, dynamic>>.from(_collections);
                final item = list.removeAt(oldIndex);
                list.insert(newIndex, item);
                setState(() => _collections = list);
                await FirebaseService.reorderCollections(list);
              },
              itemBuilder: (ctx, i) {
                final col = _collections[i];
                final isActive = col['active'] == true;

                return ListTile(
                  key: ValueKey(col['id']),
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(
                    col['label'] ?? col['id'],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isActive ? null : Colors.grey,
                    ),
                  ),
                  subtitle: Text(col['id'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ Switch مع check
                      Switch(
                        value: isActive,
                        onChanged: (val) async {
                          final success =
                              await FirebaseService.toggleCollection(
                                col['id'],
                                val,
                              );

                          if (!success && mounted) {
                            // ✅ رسالة خطأ لو حاول يقفل الأخير
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '⚠️ لازم يكون في مجموعة واحدة على الأقل شغالة',
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          await _load();
                        },
                      ),
                      // ✅ فتح النصوص
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.green,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MessagesScreen(
                              collectionKey: col['id'],
                              collectionLabel: col['label'] ?? col['id'],
                            ),
                          ),
                        ).then((_) => _load()),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
