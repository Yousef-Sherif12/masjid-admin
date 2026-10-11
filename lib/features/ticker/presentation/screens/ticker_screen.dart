import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/core/theme/admin_theme.dart';
import 'package:masjid_admin/features/ticker/domain/entities/admin_ticker_item.dart';
import 'package:masjid_admin/features/ticker/presentation/cubit/admin_ticker_cubit.dart';
import 'package:masjid_admin/features/ticker/presentation/cubit/admin_ticker_state.dart';

class TickerScreen extends StatefulWidget {
  const TickerScreen({super.key});

  @override
  State<TickerScreen> createState() => _TickerScreenState();
}

class _TickerScreenState extends State<TickerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddOrEditDialog(
    BuildContext context, {
    AdminTickerItem? item,
  }) async {
    final cubit = context.read<AdminTickerCubit>();
    final controller = TextEditingController(text: item?.text ?? '');

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
                item == null ? Icons.campaign_rounded : Icons.edit_rounded,
                color: AdminTheme.primaryEmerald,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(item == null ? 'إضافة إعلان للشريط السفلي' : 'تعديل نص الإعلان'),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: TextField(
            controller: controller,
            maxLines: 4,
            minLines: 3,
            textDirection: TextDirection.rtl,
            decoration: const InputDecoration(
              labelText: 'نص الرسالة أو التنبيه *',
              alignLabelWithHint: true,
              hintText: 'مثال: يرجى إغلاق الهواتف المحمولة وتسوية الصفوف...',
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
              item == null ? Icons.add_rounded : Icons.check_rounded,
              size: 18,
            ),
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(ctx);
              if (item == null) {
                await cubit.addMessage(text);
              } else {
                await cubit.updateText(item.id, text);
              }
            },
            label: Text(item == null ? 'إضافة للشريط' : 'حفظ التعديل'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AdminTickerItem item,
  ) async {
    final cubit = context.read<AdminTickerCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('حذف الرسالة من الشريط'),
          ],
        ),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('هل تريد حذف هذه الرسالة نهائياً من الشريط السفلي؟'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  item.text,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            onPressed: () => Navigator.pop(ctx, true),
            label: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await cubit.deleteMessage(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminTickerCubit, AdminTickerState>(
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
        final cubit = context.read<AdminTickerCubit>();
        final offset = state.hijriOffset;
        final activeTickerItems =
            state.items.where((e) => e.active).toList();

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(
                  Icons.tune_rounded,
                  color: AdminTheme.primaryEmerald,
                  size: 22,
                ),
                SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'الشريط والتقويم الهجري',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(54),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    bottom: BorderSide(color: AdminTheme.cardBorder),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AdminTheme.primaryEmerald,
                  unselectedLabelColor: AdminTheme.textSecondary,
                  indicatorColor: AdminTheme.primaryEmerald,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13.5,
                  ),
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.campaign_outlined, size: 18),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'رسائل الشريط (${activeTickerItems.length}/${state.items.length})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_rounded, size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'التاريخ الهجري',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'تحديث',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: cubit.loadTickerMessages,
              ),
              const SizedBox(width: 8),
            ],
          ),
          floatingActionButton: ValueListenableBuilder<double>(
            valueListenable: _tabController.animation!,
            builder: (context, value, child) {
              return value > 0.5
                  ? const SizedBox.shrink()
                  : FloatingActionButton.extended(
                      onPressed: () => _showAddOrEditDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إضافة رسالة للشريط'),
                    );
            },
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // -------------------------------------------------------------
              // التبويب الأول: رسائل الشريط السفلي
              // -------------------------------------------------------------
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                      children: [
                        // معاينة حية للشريط الإخباري كما يظهر أسفل الشاشة
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            gradient: AdminTheme.headerGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AdminTheme.primaryEmerald.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.visibility_rounded,
                                    color: AdminTheme.softGold,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  const Expanded(
                                    child: Text(
                                      'معاينة الشريط النشط على الشاشة:',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AdminTheme.softGold,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${activeTickerItems.length} مفعّلة',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  activeTickerItems.isEmpty
                                      ? 'لا توجد رسائل مفعّلة حالياً في الشريط السفلي'
                                      : activeTickerItems
                                          .map((e) => e.text)
                                          .join('   •   '),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textDirection: TextDirection.rtl,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: state.items.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.campaign_outlined,
                                        size: 56,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'لا توجد رسائل في الشريط السفلي حالياً',
                                        style: TextStyle(
                                          color: AdminTheme.textSecondary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ReorderableListView.builder(
                                  buildDefaultDragHandles: false,
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    6,
                                    16,
                                    90,
                                  ),
                                  itemCount: state.items.length,
                                  onReorder: cubit.reorderMessages,
                                  itemBuilder: (context, index) {
                                    final item = state.items[index];
                                    final isActive = item.active;

                                    return Padding(
                                      key: ValueKey(item.id),
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(14),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              // الصف الأول: مقبض السحب + الرقم + نص الرسالة بعرض الكارت بالكامل
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  ReorderableDragStartListener(
                                                    index: index,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                        6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: AdminTheme
                                                            .surfaceBg,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .drag_indicator_rounded,
                                                        color: AdminTheme
                                                            .textSecondary,
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Container(
                                                    width: 34,
                                                    height: 34,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? AdminTheme
                                                              .softEmerald
                                                          : Colors
                                                              .grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        9,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      '${index + 1}',
                                                      style: TextStyle(
                                                        color: isActive
                                                            ? AdminTheme
                                                                .primaryEmerald
                                                            : Colors.grey,
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      item.text,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      style: TextStyle(
                                                        fontSize: 15.5,
                                                        height: 1.45,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: isActive
                                                            ? AdminTheme
                                                                .textPrimary
                                                            : Colors.grey,
                                                      ),
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
                                              // الصف الثاني: حالة العرض + التفعيل + التعديل + الحذف
                                              Row(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: isActive
                                                          ? AdminTheme
                                                              .softEmerald
                                                          : Colors
                                                              .grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        20,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      isActive
                                                          ? 'تُعرض في الشريط السفلي'
                                                          : 'مخفية مؤقتاً',
                                                      style: TextStyle(
                                                        fontSize: 11.5,
                                                        fontWeight:
                                                            FontWeight.w700,
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
                                                    tooltip: 'تعديل النص',
                                                    icon: const Icon(
                                                      Icons.edit_outlined,
                                                      color: AdminTheme
                                                          .textSecondary,
                                                      size: 20,
                                                    ),
                                                    onPressed: () =>
                                                        _showAddOrEditDialog(
                                                      context,
                                                      item: item,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  IconButton(
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    tooltip: 'حذف الرسالة',
                                                    icon: Icon(
                                                      Icons
                                                          .delete_outline_rounded,
                                                      color:
                                                          Colors.red.shade600,
                                                      size: 20,
                                                    ),
                                                    onPressed: () =>
                                                        _confirmDelete(
                                                      context,
                                                      item,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Switch(
                                                    value: isActive,
                                                    onChanged: (v) =>
                                                        cubit.toggleActive(
                                                      item.id,
                                                      v,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),

              // -------------------------------------------------------------
              // التبويب الثاني: تعديل الفارق الهجري
              // -------------------------------------------------------------
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 540),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AdminTheme.softEmerald,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.nights_stay_rounded,
                                color: AdminTheme.primaryEmerald,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'ضبط التاريخ الهجري حسب الرؤية الشرعية',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AdminTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'يمكنك تقديم أو تأخير التاريخ الهجري المعروض على شاشة المسجد بمقدار يوم أو يومين عند اختلاف ثبوت الهلال، ويتم التحديث على الشاشة لحظياً.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AdminTheme.textSecondary,
                                fontSize: 13.5,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 28),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton.filledTonal(
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.red.shade50,
                                    foregroundColor: Colors.red.shade700,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  onPressed: offset > -3
                                      ? () =>
                                          cubit.updateHijriOffset(offset - 1)
                                      : null,
                                  icon: const Icon(
                                    Icons.remove_rounded,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 160,
                                      minWidth: 110,
                                    ),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                        horizontal: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: offset == 0
                                            ? AdminTheme.surfaceBg
                                            : AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: offset == 0
                                              ? AdminTheme.cardBorder
                                              : AdminTheme.primaryEmerald,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            offset > 0
                                                ? '+$offset يوم'
                                                : (offset < 0
                                                    ? '$offset يوم'
                                                    : 'تلقائي (0)'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: offset == 0
                                                  ? AdminTheme.textPrimary
                                                  : AdminTheme.primaryEmerald,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            offset == 0
                                                ? 'التقويم الافتراضي'
                                                : (offset > 0
                                                    ? 'تقديم التاريخ الهجري'
                                                    : 'تأخير التاريخ الهجري'),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AdminTheme.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                IconButton.filledTonal(
                                  style: IconButton.styleFrom(
                                    backgroundColor: AdminTheme.softEmerald,
                                    foregroundColor: AdminTheme.primaryEmerald,
                                    minimumSize: const Size(48, 48),
                                  ),
                                  onPressed: offset < 3
                                      ? () =>
                                          cubit.updateHijriOffset(offset + 1)
                                      : null,
                                  icon: const Icon(Icons.add_rounded, size: 24),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            // أزرار سريعة لاختيار الفارق
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [-2, -1, 0, 1, 2].map((preset) {
                                final isSelected = offset == preset;
                                final label = preset == 0
                                    ? 'تلقائي (0)'
                                    : (preset > 0 ? '+$preset يوم' : '$preset يوم');
                                return ChoiceChip(
                                  label: Text(label),
                                  selected: isSelected,
                                  selectedColor: AdminTheme.softEmerald,
                                  labelStyle: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? AdminTheme.primaryEmerald
                                        : AdminTheme.textSecondary,
                                  ),
                                  onSelected: (_) =>
                                      cubit.updateHijriOffset(preset),
                                );
                              }).toList(),
                            ),
                            if (offset != 0) ...[
                              const SizedBox(height: 18),
                              TextButton.icon(
                                onPressed: () => cubit.updateHijriOffset(0),
                                icon: const Icon(Icons.restart_alt_rounded),
                                label: const Text(
                                  'إعادة الضبط إلى التاريخ الهجري الافتراضي',
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
