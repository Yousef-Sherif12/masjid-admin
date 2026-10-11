import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/core/theme/admin_theme.dart';
import 'package:masjid_admin/features/messages/data/repositories/messages_repository_impl.dart';
import 'package:masjid_admin/features/messages/domain/entities/admin_message.dart';
import 'package:masjid_admin/features/messages/presentation/cubit/messages_cubit.dart';
import 'package:masjid_admin/features/messages/presentation/cubit/messages_state.dart';

class MessagesScreen extends StatelessWidget {
  final String collectionKey;
  final String collectionLabel;

  const MessagesScreen({
    super.key,
    required this.collectionKey,
    required this.collectionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessagesCubit(
        MessagesRepositoryImpl(),
        collectionKey: collectionKey,
      )..init(),
      child: _MessagesView(collectionLabel: collectionLabel),
    );
  }
}

class _MessagesView extends StatefulWidget {
  final String collectionLabel;

  const _MessagesView({required this.collectionLabel});

  @override
  State<_MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<_MessagesView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  /// توحيد الحروف العربية وإزالة التشكيل والرموز القرآنية لتسهيل البحث بدون تشكيل
  String _normalizeArabic(String input) {
    return input
        // إزالة التشكيل والحركات وعلامات الوقف القرآنية والمدود
        .replaceAll(
          RegExp(
            r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E8\u06EA-\u06ED\u0640]',
          ),
          '',
        )
        // توحيد أشكال الألف (أ، إ، آ، ٱ -> ا)
        .replaceAll(RegExp(r'[أإآٱ]'), 'ا')
        // توحيد التاء المربوطة والهاء
        .replaceAll('ة', 'ه')
        // توحيد الياء والألف المقصورة
        .replaceAll('ى', 'ي')
        // توحيد الهمزات على الواو والياء
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .trim()
        .toLowerCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditDialog(
    BuildContext context, {
    AdminMessage? existing,
  }) async {
    final cubit = context.read<MessagesCubit>();
    final textController = TextEditingController(text: existing?.text ?? '');
    final subTextController =
        TextEditingController(text: existing?.subText ?? '');
    final fadlController = TextEditingController(text: existing?.fadl ?? '');
    final durationController = TextEditingController(
      text: (existing?.duration ?? 15).toString(),
    );
    final fontSizeController = TextEditingController(
      text: existing?.fontSize != null ? existing!.fontSize.toString() : '',
    );

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AdminTheme.softEmerald,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                existing == null ? Icons.post_add_rounded : Icons.edit_rounded,
                color: AdminTheme.primaryEmerald,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(existing == null ? 'إضافة نص جديد' : 'تعديل بيانات النص'),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 6,
                  minLines: 4,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'النص الأساسي (الآية / الحديث / الذكر) *',
                    alignLabelWithHint: true,
                    hintText: 'اكتب النص الذي سيظهر على الشاشة...',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: subTextController,
                  textDirection: TextDirection.rtl,
                  decoration: const InputDecoration(
                    labelText: 'المصدر / السورة / الراوي (اختياري)',
                    prefixIcon: Icon(Icons.menu_book_outlined, size: 20),
                    hintText: 'مثال: رواه البخاري ومسلم',
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: fadlController,
                  textDirection: TextDirection.rtl,
                  maxLines: 3,
                  minLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'الفضل أو الشرح المختصر (اختياري)',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.auto_awesome_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'مدة العرض (ثانية)',
                          prefixIcon: Icon(Icons.timer_outlined, size: 20),
                          suffixText: 'ث',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: fontSizeController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'حجم الخط (فارغ = تلقائي)',
                          prefixIcon: Icon(
                            Icons.format_size_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            icon: Icon(
              existing == null ? Icons.add_rounded : Icons.check_rounded,
              size: 18,
            ),
            onPressed: () async {
              final text = textController.text.trim();
              if (text.isEmpty) return;

              final subText = subTextController.text.trim();
              final fadl = fadlController.text.trim();
              final duration =
                  int.tryParse(durationController.text.trim()) ?? 15;
              final rawFont = fontSizeController.text.trim();
              final fontSize =
                  rawFont.isEmpty ? null : double.tryParse(rawFont);

              Navigator.pop(ctx);

              if (existing == null) {
                await cubit.addMessage(
                  text: text,
                  subText: subText,
                  fadl: fadl,
                  duration: duration,
                  fontSize: fontSize,
                );
              } else {
                await cubit.updateMessage(
                  docId: existing.id,
                  text: text,
                  subText: subText,
                  fadl: fadl,
                  duration: duration,
                  fontSize: fontSize,
                );
              }
            },
            label: Text(existing == null ? 'إضافة النص' : 'حفظ التعديلات'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AdminMessage item) {
    final cubit = context.read<MessagesCubit>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('تأكيد الحذف'),
          ],
        ),
        content: const Text(
          'هل تريد حذف هذا النص نهائياً من المجموعة؟ لا يمكن التراجع عن هذا الإجراء.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            onPressed: () async {
              Navigator.pop(ctx);
              await cubit.deleteMessage(item.id);
            },
            label: const Text('حذف النص'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MessagesCubit, MessagesState>(
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
        final cubit = context.read<MessagesCubit>();
        final isLiveActive = state.liveDisplay.active;
        final activeDocId =
            (isLiveActive && state.liveDisplay.collection == cubit.collectionKey)
                ? state.liveDisplay.docId
                : null;

        final normalizedQuery = _normalizeArabic(_searchQuery);
        final filteredMessages = normalizedQuery.isEmpty
            ? state.messages
            : state.messages.where((m) {
                return _normalizeArabic(m.text).contains(normalizedQuery) ||
                    _normalizeArabic(m.subText).contains(normalizedQuery) ||
                    _normalizeArabic(m.fadl).contains(normalizedQuery);
              }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.collectionLabel,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${state.messages.length} نص في هذه المجموعة',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AdminTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث النصوص',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: cubit.loadMessages,
              ),
              const SizedBox(width: 6),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddEditDialog(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة نص جديد'),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // شريط تنبيه البث المباشر في حال تفعيله
                    if (isLiveActive)
                      Container(
                        margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D6B4B), Color(0xFF159468)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AdminTheme.primaryEmerald.withValues(
                                alpha: 0.25,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cast_connected_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'البث المباشر نشط الآن على شاشة المسجد',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'الشاشة تعرض حالياً النص المثبّت بدلاً من التبديل التلقائي',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonalIcon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AdminTheme.darkEmerald,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () async {
                                await cubit.stopLiveDisplay();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        '✅ تم إيقاف البث المباشر وعادت الشاشة للوضع التلقائي',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.stop_circle_outlined, size: 18),
                              label: const Text('إيقاف البث'),
                            ),
                          ],
                        ),
                      ),

                    // شريط البحث السريع داخل النصوص
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              textDirection: TextDirection.rtl,
                              decoration: InputDecoration(
                                hintText:
                                    'ابحث في نصوص ${widget.collectionLabel}...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: AdminTheme.textSecondary,
                                ),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                      )
                                    : null,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: filteredMessages.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.article_outlined,
                                    size: 56,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _searchQuery.isEmpty
                                        ? 'لا توجد نصوص في هذه المجموعة بعد'
                                        : 'لا توجد نتائج مطابقة للبحث',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AdminTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : _searchQuery.trim().isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    90,
                                  ),
                                  itemCount: filteredMessages.length,
                                  itemBuilder: (ctx, i) {
                                    final item = filteredMessages[i];
                                    return _MessageCard(
                                      key: ValueKey(item.id),
                                      index: i,
                                      item: item,
                                      isLiveActive: activeDocId == item.id,
                                      allowDrag: false,
                                      onToggleLive: () =>
                                          cubit.toggleLiveDisplay(item.id),
                                      onEdit: () => _showAddEditDialog(
                                        context,
                                        existing: item,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, item),
                                    );
                                  },
                                )
                              : ReorderableListView.builder(
                                  buildDefaultDragHandles: false,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    90,
                                  ),
                                  itemCount: filteredMessages.length,
                                  onReorder: cubit.reorderMessages,
                                  itemBuilder: (ctx, i) {
                                    final item = filteredMessages[i];
                                    return _MessageCard(
                                      key: ValueKey(item.id),
                                      index: i,
                                      item: item,
                                      isLiveActive: activeDocId == item.id,
                                      allowDrag: true,
                                      onToggleLive: () =>
                                          cubit.toggleLiveDisplay(item.id),
                                      onEdit: () => _showAddEditDialog(
                                        context,
                                        existing: item,
                                      ),
                                      onDelete: () =>
                                          _confirmDelete(context, item),
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

class _MessageCard extends StatelessWidget {
  final int index;
  final AdminMessage item;
  final bool isLiveActive;
  final bool allowDrag;
  final VoidCallback onToggleLive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MessageCard({
    super.key,
    required this.index,
    required this.item,
    required this.isLiveActive,
    required this.allowDrag,
    required this.onToggleLive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLiveActive
                ? AdminTheme.primaryEmerald
                : AdminTheme.cardBorder,
            width: isLiveActive ? 2 : 1,
          ),
          boxShadow: isLiveActive
              ? [
                  BoxShadow(
                    color: AdminTheme.primaryEmerald.withValues(alpha: 0.14),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (allowDrag) ...[
                    ReorderableDragStartListener(
                      index: index,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AdminTheme.surfaceBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.drag_indicator_rounded,
                          color: AdminTheme.textSecondary,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isLiveActive
                          ? AdminTheme.primaryEmerald
                          : AdminTheme.softEmerald,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isLiveActive
                            ? Colors.white
                            : AdminTheme.primaryEmerald,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.text,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: AdminTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              if (item.subText.isNotEmpty || item.fadl.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AdminTheme.surfaceBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (item.subText.isNotEmpty)
                        Row(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 15,
                              color: AdminTheme.accentGold,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.subText,
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AdminTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (item.fadl.isNotEmpty) ...[
                        if (item.subText.isNotEmpty) const SizedBox(height: 4),
                        Text(
                          item.fadl,
                          textDirection: TextDirection.rtl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AdminTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(height: 1, color: AdminTheme.cardBorder),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MetaBadge(
                        icon: Icons.timer_outlined,
                        label: '${item.duration} ث',
                      ),
                      const SizedBox(width: 6),
                      _MetaBadge(
                        icon: Icons.format_size_rounded,
                        label: item.fontSize != null
                            ? 'خط ${item.fontSize!.toInt()}'
                            : 'خط تلقائي',
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: onToggleLive,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isLiveActive
                                ? AdminTheme.primaryEmerald
                                : AdminTheme.softEmerald,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isLiveActive
                                    ? Icons.cast_connected_rounded
                                    : Icons.cast_rounded,
                                size: 15,
                                color: isLiveActive
                                    ? Colors.white
                                    : AdminTheme.primaryEmerald,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isLiveActive ? 'يُعرض الآن' : 'بث مباشر',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isLiveActive
                                      ? Colors.white
                                      : AdminTheme.primaryEmerald,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'تعديل النص',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(
                          Icons.edit_outlined,
                          color: AdminTheme.textSecondary,
                          size: 20,
                        ),
                        onPressed: onEdit,
                      ),
                      IconButton(
                        tooltip: 'حذف النص',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.red.shade600,
                          size: 20,
                        ),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AdminTheme.surfaceBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AdminTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AdminTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
