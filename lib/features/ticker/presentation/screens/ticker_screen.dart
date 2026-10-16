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
                          Icon(Icons.tune_rounded, size: 18),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'العرض والخطوط',
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
              // التبويب الثاني: إعدادات العرض والخطوط
              // -------------------------------------------------------------
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // البطاقة الأولى: نوع خط الآيات والأحاديث
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.font_download_rounded,
                                        color: AdminTheme.primaryEmerald,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'نوع خط الآيات والأحاديث',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AdminTheme.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'اختر نوع الخط المفضل، ويتم التبديل على الشاشة فوراً',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: AdminTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                Row(
                                  children: [
                                    // خيار روبوتو
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => cubit.updateContentFontFamily('Roboto'),
                                        borderRadius: BorderRadius.circular(14),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: state.contentFontFamily == 'Roboto'
                                                ? AdminTheme.softEmerald
                                                : AdminTheme.surfaceBg,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: state.contentFontFamily == 'Roboto'
                                                  ? AdminTheme.primaryEmerald
                                                  : AdminTheme.cardBorder,
                                              width: state.contentFontFamily == 'Roboto' ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    state.contentFontFamily == 'Roboto'
                                                        ? Icons.radio_button_checked_rounded
                                                        : Icons.radio_button_off_rounded,
                                                    color: state.contentFontFamily == 'Roboto'
                                                        ? AdminTheme.primaryEmerald
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'روبوتو (Roboto)',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                'النسخ الكلاسيكي المريح - ممتاز للتشكيل والآيات الطويلة',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: AdminTheme.textSecondary,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // خيار تجوال
                                    Expanded(
                                      child: InkWell(
                                        onTap: () => cubit.updateContentFontFamily('Tajawal'),
                                        borderRadius: BorderRadius.circular(14),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: state.contentFontFamily == 'Tajawal'
                                                ? AdminTheme.softEmerald
                                                : AdminTheme.surfaceBg,
                                            borderRadius: BorderRadius.circular(14),
                                            border: Border.all(
                                              color: state.contentFontFamily == 'Tajawal'
                                                  ? AdminTheme.primaryEmerald
                                                  : AdminTheme.cardBorder,
                                              width: state.contentFontFamily == 'Tajawal' ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    state.contentFontFamily == 'Tajawal'
                                                        ? Icons.radio_button_checked_rounded
                                                        : Icons.radio_button_off_rounded,
                                                    color: state.contentFontFamily == 'Tajawal'
                                                        ? AdminTheme.primaryEmerald
                                                        : Colors.grey,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  const Text(
                                                    'تجوال (Tajawal)',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 14.5,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              const Text(
                                                'الخط العصري الأنيق - تصميم هندسي واضح وحديث',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: AdminTheme.textSecondary,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                // عينة معاينة حية للخط
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AdminTheme.cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'معاينة الخط المحدد (${state.contentFontFamily}):',
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AdminTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          '﴿فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ۝﴾',
                                          textAlign: TextAlign.center,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: state.contentFontFamily == 'Tajawal'
                                                ? 'Tajawal'
                                                : null,
                                            color: AdminTheme.primaryEmerald,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // البطاقة الثانية: حجم خط التاريخ الميلادي والهجري
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.format_size_rounded,
                                        color: AdminTheme.primaryEmerald,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'حجم خط التاريخ (الميلادي والهجري)',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AdminTheme.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'تحكم في حجم خط التاريخ لمنع نزوله لسطر ثانٍ عند طول اسم الشهر',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: AdminTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // التحكم بالزيادة والنقصان
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton.filledTonal(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red.shade700,
                                        minimumSize: const Size(46, 46),
                                      ),
                                      onPressed: state.dateFontSize > 11
                                          ? () => cubit.updateDateFontSize(state.dateFontSize - 1)
                                          : null,
                                      icon: const Icon(Icons.remove_rounded, size: 22),
                                      tooltip: 'تصغير خط التاريخ',
                                    ),
                                    const SizedBox(width: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: AdminTheme.primaryEmerald,
                                          width: 1.5,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            '${state.dateFontSize.toInt()} pt',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w900,
                                              color: AdminTheme.primaryEmerald,
                                            ),
                                          ),
                                          const Text(
                                            'حجم الخط الحالي',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: AdminTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    IconButton.filledTonal(
                                      style: IconButton.styleFrom(
                                        backgroundColor: AdminTheme.softEmerald,
                                        foregroundColor: AdminTheme.primaryEmerald,
                                        minimumSize: const Size(46, 46),
                                      ),
                                      onPressed: state.dateFontSize < 22
                                          ? () => cubit.updateDateFontSize(state.dateFontSize + 1)
                                          : null,
                                      icon: const Icon(Icons.add_rounded, size: 22),
                                      tooltip: 'تكبير خط التاريخ',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // أزرار اختصارات سريعة
                                Center(
                                  child: Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      (size: 13.0, label: 'صغير 13'),
                                      (size: 14.0, label: 'متوسط 14'),
                                      (size: 15.0, label: 'افتراضي 15'),
                                      (size: 17.0, label: 'كبير 17'),
                                      (size: 19.0, label: 'كبير جداً 19'),
                                    ].map((preset) {
                                      final isSelected = state.dateFontSize.toInt() == preset.size.toInt();
                                      return ChoiceChip(
                                        label: Text(preset.label),
                                        selected: isSelected,
                                        selectedColor: AdminTheme.softEmerald,
                                        labelStyle: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: isSelected
                                              ? AdminTheme.primaryEmerald
                                              : AdminTheme.textSecondary,
                                        ),
                                        onSelected: (_) => cubit.updateDateFontSize(preset.size),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // محاكاة حية للتاريخ في عمود المواقيت
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AdminTheme.cardBorder),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'معاينة التاريخ (كما يظهر على الشاشة بسطر واحد دائماً):',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: AdminTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'الأربعاء 4 ربيع الثاني 1448هـ',
                                        maxLines: 1,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: state.dateFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: AdminTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '15 أكتوبر 2026م',
                                        maxLines: 1,
                                        textDirection: TextDirection.rtl,
                                        style: TextStyle(
                                          fontSize: state.dateFontSize,
                                          fontWeight: FontWeight.w700,
                                          color: AdminTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // البطاقة الثالثة: ضبط التاريخ الهجري حسب الرؤية الشرعية
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(22),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.nights_stay_rounded,
                                        color: AdminTheme.primaryEmerald,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ضبط التاريخ الهجري (الرؤية الشرعية)',
                                            style: TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800,
                                              color: AdminTheme.textPrimary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'تقديم أو تأخير اليوم بمقدار يوم أو يومين عند ثبوت الهلال',
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: AdminTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton.filledTonal(
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red.shade50,
                                        foregroundColor: Colors.red.shade700,
                                        minimumSize: const Size(46, 46),
                                      ),
                                      onPressed: offset > -3
                                          ? () => cubit.updateHijriOffset(offset - 1)
                                          : null,
                                      icon: const Icon(Icons.remove_rounded, size: 22),
                                    ),
                                    const SizedBox(width: 14),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: offset == 0
                                            ? AdminTheme.surfaceBg
                                            : AdminTheme.softEmerald,
                                        borderRadius: BorderRadius.circular(14),
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
                                                : (offset < 0 ? '$offset يوم' : 'تلقائي (0)'),
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w900,
                                              color: offset == 0
                                                  ? AdminTheme.textPrimary
                                                  : AdminTheme.primaryEmerald,
                                            ),
                                          ),
                                          Text(
                                            offset == 0
                                                ? 'التقويم الافتراضي'
                                                : (offset > 0
                                                    ? 'تقديم التاريخ الهجري'
                                                    : 'تأخير التاريخ الهجري'),
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AdminTheme.textSecondary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    IconButton.filledTonal(
                                      style: IconButton.styleFrom(
                                        backgroundColor: AdminTheme.softEmerald,
                                        foregroundColor: AdminTheme.primaryEmerald,
                                        minimumSize: const Size(46, 46),
                                      ),
                                      onPressed: offset < 3
                                          ? () => cubit.updateHijriOffset(offset + 1)
                                          : null,
                                      icon: const Icon(Icons.add_rounded, size: 22),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Wrap(
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
                                          fontSize: 12,
                                          color: isSelected
                                              ? AdminTheme.primaryEmerald
                                              : AdminTheme.textSecondary,
                                        ),
                                        onSelected: (_) => cubit.updateHijriOffset(preset),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (offset != 0) ...[
                                  const SizedBox(height: 14),
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () => cubit.updateHijriOffset(0),
                                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                                      label: const Text('إعادة الضبط للتاريخ الافتراضي'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
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
