// import 'package:flutter/material.dart';
// import 'package:masjid_admin/services/firebase_service.dart';

// class TickerMessagesScreen extends StatefulWidget {
//   const TickerMessagesScreen({super.key});

//   @override
//   State<TickerMessagesScreen> createState() => _TickerMessagesScreenState();
// }

// class _TickerMessagesScreenState extends State<TickerMessagesScreen> {
//   List<Map<String, dynamic>> items = [];
//   bool loading = true;

//   @override
//   void initState() {
//     super.initState();
//     loadData();
//   }

//   Future<void> loadData() async {
//     setState(() => loading = true);
//     items = await FirebaseService.getTickerMessages();
//     setState(() => loading = false);
//   }

//   Future<void> addOrEdit({Map<String, dynamic>? item}) async {
//     final controller = TextEditingController(text: item?['text'] ?? '');

//     await showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(item == null ? 'إضافة رسالة' : 'تعديل الرسالة'),
//         content: TextField(
//           controller: controller,
//           maxLines: 4,
//           textDirection: TextDirection.rtl,
//           decoration: const InputDecoration(border: OutlineInputBorder()),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('إلغاء'),
//           ),
//           FilledButton(
//             onPressed: () async {
//               final text = controller.text.trim();
//               if (text.isEmpty) return;
//               if (item == null) {
//                 await FirebaseService.addTickerMessage(text);
//               } else {
//                 await FirebaseService.updateTickerMessage(item['id'], {
//                   'text': text,
//                 });
//               }
//               if (mounted) Navigator.pop(context);
//               await loadData();
//             },
//             child: const Text('حفظ'),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> confirmDelete(String docId, String text) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('تأكيد الحذف'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             const Text('هتحذف الرسالة دي؟'),
//             const SizedBox(height: 8),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.red.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red.withOpacity(0.3)),
//               ),
//               child: Text(
//                 text,
//                 textDirection: TextDirection.rtl,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('إلغاء'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('حذف', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       await FirebaseService.deleteTickerMessage(docId);
//       await loadData();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الشريط السفلي'),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => addOrEdit(),
//         icon: const Icon(Icons.add),
//         label: const Text('إضافة رسالة'),
//       ),
//       body: loading
//           ? const Center(child: CircularProgressIndicator())
//           : items.isEmpty
//           ? const Center(child: Text('مفيش رسائل'))
//           : ReorderableListView.builder(
//               padding: const EdgeInsets.only(bottom: 80),
//               itemCount: items.length,
//               onReorder: (oldIndex, newIndex) async {
//                 if (newIndex > oldIndex) newIndex--;
//                 final item = items.removeAt(oldIndex);
//                 items.insert(newIndex, item);
//                 setState(() {});
//                 await FirebaseService.reorderTickerMessages(items);
//               },
//               itemBuilder: (context, index) {
//                 final item = items[index];
//                 final isActive = item['active'] ?? true;

//                 return Card(
//                   key: ValueKey(item['id']),
//                   margin: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   child: ListTile(
//                     leading: CircleAvatar(
//                       backgroundColor: isActive ? Colors.green : Colors.grey,
//                       child: Text(
//                         '${index + 1}',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     title: Text(
//                       item['text'] ?? '',
//                       textDirection: TextDirection.rtl,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: isActive ? null : Colors.grey),
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Switch(
//                           value: isActive,
//                           onChanged: (v) async {
//                             await FirebaseService.updateTickerMessage(
//                               item['id'],
//                               {'active': v},
//                             );
//                             await loadData();
//                           },
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.edit, color: Colors.blue),
//                           onPressed: () => addOrEdit(item: item),
//                         ),
//                         IconButton(
//                           icon: const Icon(Icons.delete, color: Colors.red),
//                           onPressed: () =>
//                               confirmDelete(item['id'], item['text'] ?? ''),
//                         ),
//                         ReorderableDragStartListener(
//                           index: index,
//                           child: const Icon(
//                             Icons.drag_handle,
//                             color: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:masjid_admin/services/firebase_service.dart';

class TickerScreen extends StatefulWidget {
  const TickerScreen({super.key});

  @override
  State<TickerScreen> createState() => _TickerScreenState();
}

class _TickerScreenState extends State<TickerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => loading = true);
    items = await FirebaseService.getTickerMessages();
    setState(() => loading = false);
  }

  Future<void> addOrEdit({Map<String, dynamic>? item}) async {
    final controller = TextEditingController(text: item?['text'] ?? '');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(item == null ? 'إضافة رسالة' : 'تعديل الرسالة', textDirection: TextDirection.rtl),
        content: TextField(
          controller: controller,
          maxLines: 4,
          textDirection: TextDirection.rtl,
          decoration: const InputDecoration(
            hintText: 'اكتب الرسالة...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              if (item == null) {
                await FirebaseService.addTickerMessage(text);
              } else {
                await FirebaseService.updateTickerMessage(item['id'], {
                  'text': text,
                });
              }
              if (mounted) Navigator.pop(context);
              await loadData();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  Future<void> confirmDelete(String docId, String text) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف', textDirection: TextDirection.rtl),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('هل تريد حذف هذه الرسالة نهائياً؟'),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                text,
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseService.deleteTickerMessage(docId);
      await loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.view_headline), text: 'رسائل الشريط'),
            Tab(icon: Icon(Icons.calendar_month), text: 'التقويم الهجري'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: loadData),
        ],
      ),
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _tabController.animation!,
        builder: (context, value, child) {
          // إخفاء الزر العائم تلقائياً عند الانتقال لتبويب التاريخ الهجري
          return value > 0.5
              ? const SizedBox.shrink()
              : FloatingActionButton.extended(
                  onPressed: () => addOrEdit(),
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة رسالة'),
                );
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // التبويب الأول: قائمة الرسائل المتحركة
          loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
                  ? const Center(child: Text('لا توجد رسائل حالياً'))
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.only(bottom: 80, top: 8),
                      itemCount: items.length,
                      onReorder: (oldIndex, newIndex) async {
                        if (newIndex > oldIndex) newIndex--;
                        final item = items.removeAt(oldIndex);
                        items.insert(newIndex, item);
                        setState(() {});
                        await FirebaseService.reorderTickerMessages(items);
                      },
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final isActive = item['active'] ?? true;

                        return Card(
                          key: ValueKey(item['id']),
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isActive ? Colors.green : Colors.grey,
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            title: Text(
                              item['text'] ?? '',
                              textDirection: TextDirection.rtl,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: isActive ? null : Colors.grey),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: isActive,
                                  onChanged: (v) async {
                                    await FirebaseService.updateTickerMessage(
                                      item['id'],
                                      {'active': v},
                                    );
                                    await loadData();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => addOrEdit(item: item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => confirmDelete(item['id'], item['text'] ?? ''),
                                ),
                                ReorderableDragStartListener(
                                  index: index,
                                  child: const Icon(Icons.drag_handle, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

          // التبويب الثاني: تعديل الفارق الهجري
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500), // للحفاظ على المظهر في شاشات الويب والديسكتوب
                child: StreamBuilder<int>(
                  stream: FirebaseService.listenToHijriOffset(),
                  builder: (context, snapshot) {
                    final offset = snapshot.data ?? 0;
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'تعديل التاريخ الهجري',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'ضبط تقديم أو تأخير الأيام حسب الرؤية الشرعية',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // زر إنقاص يوم
                                IconButton(
                                  onPressed: () async {
                                    await FirebaseService.updateHijriOffset(offset - 1);
                                  },
                                  icon: const Icon(Icons.remove_circle, color: Colors.red, size: 42),
                                ),
                                const SizedBox(width: 20),
                                // عرض الفارق الحالي
                                Container(
                                  width: 100,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    border: Border.all(color: Colors.grey[300]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    offset > 0 ? '+$offset يوم' : (offset < 0 ? '$offset يوم' : 'تلقائي'),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: offset == 0
                                          ? Colors.grey[700]
                                          : offset > 0
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // زر زيادة يوم
                                IconButton(
                                  onPressed: () async {
                                    await FirebaseService.updateHijriOffset(offset + 1);
                                  },
                                  icon: const Icon(Icons.add_circle, color: Colors.green, size: 42),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // زر إعادة التعيين للافتراضي
                            if (offset != 0)
                              TextButton.icon(
                                onPressed: () async {
                                  await FirebaseService.updateHijriOffset(0);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('إعادة تعيين للتاريخ الأصلي'),
                                style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}