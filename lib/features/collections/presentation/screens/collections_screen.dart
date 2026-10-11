import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/core/theme/admin_theme.dart';
import 'package:masjid_admin/features/collections/domain/entities/collection_item.dart';
import 'package:masjid_admin/features/collections/presentation/cubit/collections_cubit.dart';
import 'package:masjid_admin/features/collections/presentation/cubit/collections_state.dart';
import 'package:masjid_admin/features/messages/presentation/screens/messages_screen.dart';

class CollectionsScreen extends StatelessWidget {
  const CollectionsScreen({super.key});

  Future<void> _showAddCollectionDialog(BuildContext context) async {
    final cubit = context.read<CollectionsCubit>();
    final labelController = TextEditingController();
    final keyController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.create_new_folder_rounded, color: AdminTheme.primaryEmerald),
            SizedBox(width: 10),
            Text('إضافة مجموعة عرض جديدة'),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'تظهر المجموعات المفعّلة بالتناوب على شاشة المسجد مع إمكانية التحكم في ترتيبها.',
                style: TextStyle(fontSize: 13, color: AdminTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                textDirection: TextDirection.rtl,
                decoration: const InputDecoration(
                  labelText: 'اسم المجموعة (يظهر كعنوان على الشاشة) *',
                  hintText: 'مثال: نفحات رمضانية',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keyController,
                textDirection: TextDirection.ltr,
                decoration: const InputDecoration(
                  labelText: 'المعرّف البرمجي بالإنجليزية (بدون مسافات) *',
                  hintText: 'ramadan_messages',
                  prefixIcon: Icon(Icons.key_rounded),
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
          FilledButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            onPressed: () async {
              final label = labelController.text.trim();
              final key = keyController.text.trim().replaceAll(' ', '_');
              if (label.isEmpty || key.isEmpty) return;
              Navigator.pop(ctx);
              await cubit.addCollection(key: key, label: label);
            },
            label: const Text('إنشاء المجموعة'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditLabelDialog(
    BuildContext context,
    CollectionItem item,
  ) async {
    final cubit = context.read<CollectionsCubit>();
    final labelController = TextEditingController(text: item.label);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AdminTheme.primaryEmerald),
            SizedBox(width: 10),
            Text('تعديل اسم المجموعة'),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: TextField(
            controller: labelController,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'اسم المجموعة على الشاشة',
              prefixIcon: Icon(Icons.label_outline_rounded),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            icon: const Icon(Icons.check_rounded, size: 18),
            onPressed: () async {
              final newLabel = labelController.text.trim();
              if (newLabel.isEmpty) return;
              Navigator.pop(ctx);
              await cubit.updateCollectionLabel(
                key: item.id,
                newLabel: newLabel,
              );
            },
            label: const Text('حفظ الاسم'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCollection(
    BuildContext context,
    CollectionItem item,
    int activeCount,
  ) {
    if (item.active && activeCount <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⚠️ لا يمكن حذف المجموعة الوحيدة النشطة؛ قم بتفعيل مجموعة أخرى أولاً',
          ),
          backgroundColor: Colors.orange.shade800,
        ),
      );
      return;
    }

    final cubit = context.read<CollectionsCubit>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('حذف المجموعة'),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إزالة مجموعة "${item.label}" (${item.id}) من قائمة العرض؟',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            onPressed: () async {
              Navigator.pop(ctx);
              await cubit.deleteCollection(item.id);
            },
            label: const Text('حذف المجموعة'),
          ),
        ],
      ),
    );
  }

  void _openMessages(BuildContext context, String key, String label) {
    final cubit = context.read<CollectionsCubit>();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessagesScreen(
          collectionKey: key,
          collectionLabel: label,
        ),
      ),
    ).then((_) => cubit.loadCollections());
  }

  ({IconData icon, Color color, Color bgColor}) _collectionVisuals(String id) {
    final lower = id.toLowerCase();
    if (lower.contains('quran')) {
      return (
        icon: Icons.menu_book_rounded,
        color: const Color(0xFF0D6B4B),
        bgColor: const Color(0xFFE6F4EF),
      );
    }
    if (lower.contains('hadith')) {
      return (
        icon: Icons.mosque_rounded,
        color: const Color(0xFFB78103),
        bgColor: const Color(0xFFFFF8E5),
      );
    }
    if (lower.contains('thaqil')) {
      return (
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF6B21A8),
        bgColor: const Color(0xFFF5EEFD),
      );
    }
    if (lower.contains('prayer') || lower.contains('dua')) {
      return (
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFF0369A1),
        bgColor: const Color(0xFFE6F4FE),
      );
    }
    return (
      icon: Icons.collections_bookmark_rounded,
      color: const Color(0xFF334155),
      bgColor: const Color(0xFFF1F5F9),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CollectionsCubit, CollectionsState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<CollectionsCubit>();
        final activeCount = state.collections.where((c) => c.active).length;

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(
                  Icons.dashboard_customize_rounded,
                  color: AdminTheme.primaryEmerald,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text('إدارة المحتوى والأذكار'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث البيانات',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: cubit.loadCollections,
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add_rounded),
            label: const Text('مجموعة جديدة'),
            onPressed: () => _showAddCollectionDialog(context),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : CustomScrollView(
                  slivers: [
                    // 1. بطاقة الملخص العلوية الاحترافية (Hero Banner)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AdminTheme.headerGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AdminTheme.primaryEmerald.withValues(
                                  alpha: 0.22,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.16,
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'شاشة العرض الرئيسية',
                                        style: TextStyle(
                                          color: AdminTheme.softGold,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'التحكم في المجموعات والأذكار',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'رتّب أولوية ظهور الآيات والأحاديث والأدعية، أو عدّل أذكار الصلوات والصباح والمساء.',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$activeCount / ${state.collections.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      'مجموعة نشطة',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 2. قسم الأذكار الثابتة (تُعرض بعد الصلوات وبالريموت)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.stars_rounded,
                                  color: AdminTheme.accentGold,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'الأذكار الثابتة (بعد الصلوات وأزرار الريموت)',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final isWide = constraints.maxWidth > 620;
                                final cards = [
                                  _FixedAdhkarCard(
                                    title: 'أذكار بعد الصلاة',
                                    subtitle: 'تُعرض عقب الصلوات أو بالزر الأخضر',
                                    icon: Icons.mosque_rounded,
                                    accentColor: const Color(0xFF0D6B4B),
                                    bgColor: const Color(0xFFE8F6F1),
                                    onTap: () => _openMessages(
                                      context,
                                      'adhkar_salah',
                                      'أذكار بعد الصلاة',
                                    ),
                                  ),
                                  _FixedAdhkarCard(
                                    title: 'أذكار الصباح',
                                    subtitle: 'تُعرض بعد الفجر أو بالزر الأصفر',
                                    icon: Icons.wb_sunny_rounded,
                                    accentColor: const Color(0xFFD97706),
                                    bgColor: const Color(0xFFFEF3C7),
                                    onTap: () => _openMessages(
                                      context,
                                      'adhkar_sabah',
                                      'أذكار الصباح',
                                    ),
                                  ),
                                  _FixedAdhkarCard(
                                    title: 'أذكار المساء',
                                    subtitle: 'تُعرض بعد العصر أو بالزر الأزرق',
                                    icon: Icons.nights_stay_rounded,
                                    accentColor: const Color(0xFF3730A3),
                                    bgColor: const Color(0xFFE0E7FF),
                                    onTap: () => _openMessages(
                                      context,
                                      'adhkar_masa',
                                      'أذكار المساء',
                                    ),
                                  ),
                                ];

                                if (isWide) {
                                  return Row(
                                    children: [
                                      Expanded(child: cards[0]),
                                      const SizedBox(width: 12),
                                      Expanded(child: cards[1]),
                                      const SizedBox(width: 12),
                                      Expanded(child: cards[2]),
                                    ],
                                  );
                                }
                                return Column(
                                  children: [
                                    cards[0],
                                    const SizedBox(height: 8),
                                    cards[1],
                                    const SizedBox(height: 8),
                                    cards[2],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 3. عنوان قائمة مجموعات العرض المتناوب
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 18, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.layers_rounded,
                                  color: AdminTheme.primaryEmerald,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'مجموعات العرض المتناوب على الشاشة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AdminTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              'اسحب لترتيب الأولوية ↕',
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. قائمة المجموعات القابلة لإعادة الترتيب
                    if (state.collections.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'لا توجد مجموعات حالياً',
                            style: TextStyle(color: AdminTheme.textSecondary),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                        sliver: SliverReorderableList(
                          itemCount: state.collections.length,
                          onReorder: cubit.reorderCollections,
                          itemBuilder: (ctx, i) {
                            final col = state.collections[i];
                            final isActive = col.active;
                            final visuals = _collectionVisuals(col.id);

                            return Padding(
                              key: ValueKey(col.id),
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Material(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(
                                    color: isActive
                                        ? AdminTheme.cardBorder
                                        : Colors.grey.shade200,
                                    width: 1,
                                  ),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () =>
                                      _openMessages(context, col.id, col.label),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // الصف الأول: مقبض السحب + الأيقونة + اسم المجموعة الكامل + زر الفتح
                                        Row(
                                          children: [
                                            ReorderableDragStartListener(
                                              index: i,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AdminTheme.surfaceBg,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: const Icon(
                                                  Icons.drag_indicator_rounded,
                                                  color:
                                                      AdminTheme.textSecondary,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? visuals.bgColor
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                visuals.icon,
                                                color: isActive
                                                    ? visuals.color
                                                    : Colors.grey,
                                                size: 22,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    col.label,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      color: isActive
                                                          ? AdminTheme
                                                              .textPrimary
                                                          : Colors.grey,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'المعرّف: ${col.id} • الترتيب #${i + 1}',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: AdminTheme
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              width: 34,
                                              height: 34,
                                              decoration: BoxDecoration(
                                                color: AdminTheme.softEmerald,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: const Icon(
                                                Icons
                                                    .arrow_forward_ios_rounded,
                                                color:
                                                    AdminTheme.primaryEmerald,
                                                size: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        const Divider(
                                          height: 1,
                                          color: AdminTheme.cardBorder,
                                        ),
                                        const SizedBox(height: 6),
                                        // الصف الثاني: شارة الحالة ومفتاح التفعيل وأزرار التعديل والحذف
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isActive
                                                    ? AdminTheme.softEmerald
                                                    : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                isActive
                                                    ? 'نشط على الشاشة'
                                                    : 'متوقف حالياً',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isActive
                                                      ? AdminTheme
                                                          .primaryEmerald
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              tooltip: 'تعديل اسم المجموعة',
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                                color:
                                                    AdminTheme.textSecondary,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showEditLabelDialog(
                                                context,
                                                col,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              tooltip: 'حذف المجموعة',
                                              icon: Icon(
                                                Icons.delete_outline_rounded,
                                                color: Colors.red.shade600,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _confirmDeleteCollection(
                                                context,
                                                col,
                                                activeCount,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Switch(
                                              value: isActive,
                                              onChanged: (val) async {
                                                final success = await cubit
                                                    .toggleCollection(
                                                  col.id,
                                                  val,
                                                );
                                                if (!success &&
                                                    context.mounted) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: const Text(
                                                        '⚠️ يجب أن تبقى مجموعة واحدة على الأقل مفعلة للعرض على الشاشة',
                                                      ),
                                                      backgroundColor:
                                                          Colors.orange.shade800,
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}

class _FixedAdhkarCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Color bgColor;
  final VoidCallback onTap;

  const _FixedAdhkarCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AdminTheme.cardBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AdminTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
