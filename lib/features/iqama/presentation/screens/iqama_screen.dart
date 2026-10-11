import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:masjid_admin/core/theme/admin_theme.dart';
import 'package:masjid_admin/features/iqama/presentation/cubit/iqama_cubit.dart';
import 'package:masjid_admin/features/iqama/presentation/cubit/iqama_state.dart';

class IqamaScreen extends StatelessWidget {
  const IqamaScreen({super.key});

  static const List<({
    String name,
    String subtitle,
    IconData icon,
    Color color,
    Color bgColor,
    List<int> presets,
  })> _prayers = [
    (
      name: 'الفجر',
      subtitle: 'وقت الانتظار بعد أذان الفجر',
      icon: Icons.wb_twilight_rounded,
      color: Color(0xFF0284C7),
      bgColor: Color(0xFFE0F2FE),
      presets: [15, 20, 25, 30],
    ),
    (
      name: 'الظهر',
      subtitle: 'وقت الانتظار بعد أذان الظهر',
      icon: Icons.wb_sunny_rounded,
      color: Color(0xFFD97706),
      bgColor: Color(0xFFFEF3C7),
      presets: [10, 15, 20],
    ),
    (
      name: 'العصر',
      subtitle: 'وقت الانتظار بعد أذان العصر',
      icon: Icons.light_mode_rounded,
      color: Color(0xFFEA580C),
      bgColor: Color(0xFFFFEDD5),
      presets: [10, 15, 20],
    ),
    (
      name: 'المغرب',
      subtitle: 'وقت الانتظار بعد أذان المغرب',
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFDC2626),
      bgColor: Color(0xFFFEE2E2),
      presets: [5, 10, 12, 15],
    ),
    (
      name: 'العشاء',
      subtitle: 'وقت الانتظار بعد أذان العشاء',
      icon: Icons.nights_stay_rounded,
      color: Color(0xFF4338CA),
      bgColor: Color(0xFFE0E7FF),
      presets: [10, 15, 20],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IqamaCubit, IqamaState>(
      listener: (context, state) {
        if (state.saveSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ تم حفظ أوقات الإقامة وتحديث شاشة المسجد فوراً'),
              backgroundColor: AdminTheme.primaryEmerald,
            ),
          );
        } else if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<IqamaCubit>();

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(
                  Icons.access_time_filled_rounded,
                  color: AdminTheme.primaryEmerald,
                  size: 24,
                ),
                SizedBox(width: 10),
                Text('إعدادات أوقات الإقامة'),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'إعادة التحميل',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: cubit.loadIqamaTimes,
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        // بانر توضيحي علوي
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: AdminTheme.headerGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AdminTheme.primaryEmerald.withValues(
                                  alpha: 0.2,
                                ),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.timer_rounded,
                                  color: AdminTheme.softGold,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'العد التنازلي للإقامة بعد الأذان',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'حدّد عدد الدقائق بين انتهاء الأذان وإقامة الصلاة لكل فرض. يتحدث العداد على شاشة المسجد تلقائياً فور الحفظ.',
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
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // بطاقات الصلوات الخمس
                        ..._prayers.map((prayer) {
                          final value =
                              (state.iqamaTimes[prayer.name] ?? 10).clamp(1, 30);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // الصف الأول: الأيقونة + اسم الصلاة + شارة الدقائق الحالية
                                    Row(
                                      children: [
                                        Container(
                                          width: 46,
                                          height: 46,
                                          decoration: BoxDecoration(
                                            color: prayer.bgColor,
                                            borderRadius:
                                                BorderRadius.circular(13),
                                          ),
                                          child: Icon(
                                            prayer.icon,
                                            color: prayer.color,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'صلاة ${prayer.name}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                  color: AdminTheme.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                prayer.subtitle,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AdminTheme.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          constraints: const BoxConstraints(
                                            minWidth: 78,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AdminTheme.softEmerald,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '$value دقيقة',
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w900,
                                              color: AdminTheme.primaryEmerald,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // الصف الثاني: أزرار الاختيار السريع (Presets)
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 6,
                                      children: prayer.presets.map((preset) {
                                        final isSelected = value == preset;
                                        return InkWell(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () => cubit.updateLocalMinutes(
                                            prayer.name,
                                            preset,
                                          ),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? AdminTheme.primaryEmerald
                                                  : AdminTheme.surfaceBg,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '$preset د',
                                              style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AdminTheme.textSecondary,
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        IconButton.filledTonal(
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade50,
                                            foregroundColor:
                                                Colors.red.shade700,
                                          ),
                                          icon: const Icon(
                                            Icons.remove_rounded,
                                            size: 20,
                                          ),
                                          onPressed: value > 1
                                              ? () => cubit.updateLocalMinutes(
                                                    prayer.name,
                                                    value - 1,
                                                  )
                                              : null,
                                        ),
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderTheme.of(context)
                                                .copyWith(
                                              activeTrackColor:
                                                  AdminTheme.primaryEmerald,
                                              inactiveTrackColor:
                                                  AdminTheme.softEmerald,
                                              thumbColor:
                                                  AdminTheme.primaryEmerald,
                                              overlayColor: AdminTheme
                                                  .primaryEmerald
                                                  .withValues(alpha: 0.12),
                                            ),
                                            child: Slider(
                                              value: value.toDouble(),
                                              min: 1,
                                              max: 30,
                                              divisions: 29,
                                              label: '$value دقيقة',
                                              onChanged: (v) =>
                                                  cubit.updateLocalMinutes(
                                                prayer.name,
                                                v.toInt(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton.filledTonal(
                                          style: IconButton.styleFrom(
                                            backgroundColor:
                                                AdminTheme.softEmerald,
                                            foregroundColor:
                                                AdminTheme.primaryEmerald,
                                          ),
                                          icon: const Icon(
                                            Icons.add_rounded,
                                            size: 20,
                                          ),
                                          onPressed: value < 30
                                              ? () => cubit.updateLocalMinutes(
                                                    prayer.name,
                                                    value + 1,
                                                  )
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),

                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(minHeight: 54),
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: state.isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save_rounded),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                state.isSaving
                                    ? 'جاري الحفظ وتحديث الشاشة...'
                                    : 'حفظ أوقات الإقامة وتطبيقها على الشاشة',
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            onPressed:
                                state.isSaving ? null : cubit.saveIqamaTimes,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
