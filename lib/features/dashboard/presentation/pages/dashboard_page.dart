import 'package:erp_mini/core/constants/app_colors.dart';
import 'package:erp_mini/core/constants/app_text_style.dart';
import 'package:erp_mini/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:erp_mini/features/dashboard/presentation/widgets/dashboard_active_sessions_grid.dart';
import 'package:erp_mini/features/dashboard/presentation/widgets/dashboard_birthdays_sidebar.dart';
import 'package:erp_mini/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:erp_mini/features/dashboard/presentation/widgets/dashboard_withdrawals_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// ==============================================================================
// صفحة لوحة التحكم الرئيسية (DashboardPage)
// الشاشة الأساسية لموظفي الاستقبال، تعرض:
// - الجلسات النشطة في المكان بتحديث لحظي
// - قائمة جانبية مثبتة (Sticky Sidebar) لأعياد الميلاد ومسحوبات الخزينة وزر بدء سيشن
// - دعم كامل للتجاوب (Responsive Layout) مع الشاشات الكبيرة والصغيرة
// ==============================================================================
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // تحميل بيانات الداشبورد والجلسات عند الدخول للشاشة
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboard();
    context.read<SessionsCubit>().loadSessions();
  }

  // فتح نافذة بدء جلسة جديدة وربطها بالـ Cubits
  void _openStartSessionDialog() {
    final sessionsCubit = context.read<SessionsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    StartSessionDialog.show(
      context,
      dataSource: sessionsCubit.dataSource,
      onStartSession:
          ({
            required customerId,
            required customerName,
            deskId,
            deskLabel,
            ratePerMinute,
          }) async {
            await sessionsCubit.startSession(
              customerId: customerId,
              customerName: customerName,
              deskId: deskId,
              deskLabel: deskLabel,
              ratePerMinute: ratePerMinute,
            );
            dashboardCubit.refresh();
          },
    );
  }

  // فتح نافذة إنهاء الجلسة وتسوية الفاتورة
  void _openEndSessionDialog(Session session) {
    final sessionsCubit = context.read<SessionsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    EndSessionDialog.show(
      context,
      session: session,
      onConfirmEnd:
          ({
            required sessionId,
            required totalAmount,
            required paidAmount,
            required paymentMethod,
          }) async {
            await sessionsCubit.closeSession(
              sessionId,
              totalAmount: totalAmount,
              paidAmount: paidAmount,
              paymentMethod: paymentMethod,
            );
            dashboardCubit.refresh();
          },
    );
  }

  // فتح نافذة سحب نقدية من الخزينة
  void _openCashWithdrawalDialog() {
    final dashboardCubit = context.read<DashboardCubit>();
    CashWithdrawalDialog.show(
      context,
      onConfirm:
          ({
            required staffName,
            required amount,
            required reason,
            createdAt,
          }) async {
            await dashboardCubit.addCashWithdrawal(
              staffName: staffName,
              amount: amount,
              reason: reason,
              createdAt: createdAt,
            );
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<DashboardCubit, DashboardState>(
        listener: (context, state) {},
        builder: (context, state) {
          // 1. حالة التحميل
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. حالة حدوث خطأ مع زر إعادة المحاولة
          if (state is DashboardError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 48,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'حدث خطأ أثناء تحميل البيانات',
                    style: AppTextStyles.headlineSm,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.message,
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<DashboardCubit>().refresh(),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // 3. حالة اكتمال تحميل البيانات بنجاح
          if (state is DashboardLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // بناء المحتوى الرئيسي للشاشة عبر تجميع الويدجتات المخصصة
  Widget _buildContent(BuildContext context, DashboardLoaded state) {
    final activeSessions = state.activeSessions;
    final upcomingBirthdays = state.upcomingBirthdays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── الشريط العلوي الثابت مع أيقونة الساعة المتحركة Lottie ───
          const DashboardHeader(),
          const SizedBox(height: 16),

          // ─── محتوى الصفحة: الجلسات النشطة + القائمة الجانبية ───
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 650;

                if (isDesktop) {
                  // عرض الديسكتوب: عمودين متجاورين
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // قسم الجلسات النشطة قابل للتمرير
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await context.read<DashboardCubit>().refresh();
                            if (!context.mounted) return;
                            await context.read<SessionsCubit>().loadSessions();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 24, left: 8),
                            child: DashboardActiveSessionsGrid(
                              activeSessions: activeSessions,
                              onPause: (id) async {
                                await context
                                    .read<SessionsCubit>()
                                    .pauseSession(id);
                                if (context.mounted) {
                                  context.read<DashboardCubit>().refresh();
                                }
                              },
                              onResume: (id) async {
                                await context
                                    .read<SessionsCubit>()
                                    .resumeSession(id);
                                if (context.mounted) {
                                  context.read<DashboardCubit>().refresh();
                                }
                              },
                              onEnd: _openEndSessionDialog,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // اللوحة الجانبية الثابتة: زر بدء سيشن + أعياد الميلاد + الخزينة
                      SizedBox(
                        width: 220,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _openStartSessionDialog,
                                icon: const Icon(
                                  LucideIcons.plus,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  'بدء سيشن جديدة',
                                  style: AppTextStyles.labelLg.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              DashboardBirthdaysSidebar(
                                upcomingBirthdays: upcomingBirthdays,
                              ),
                              const SizedBox(height: 14),
                              DashboardWithdrawalsSidebar(
                                withdrawals: state.cashWithdrawals,
                                onWithdrawPressed: _openCashWithdrawalDialog,
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  // عرض الشاشات الصغيرة: عمود واحد ممتد
                  return RefreshIndicator(
                    onRefresh: () async {
                      await context.read<DashboardCubit>().refresh();
                      if (!context.mounted) return;
                      await context.read<SessionsCubit>().loadSessions();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _openStartSessionDialog,
                            icon: const Icon(
                              LucideIcons.plus,
                              size: 16,
                              color: Colors.white,
                            ),
                            label: Text(
                              'بدء سيشن جديدة',
                              style: AppTextStyles.labelLg.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DashboardActiveSessionsGrid(
                            activeSessions: activeSessions,
                            onPause: (id) async {
                              await context.read<SessionsCubit>().pauseSession(
                                id,
                              );
                              if (context.mounted) {
                                context.read<DashboardCubit>().refresh();
                              }
                            },
                            onResume: (id) async {
                              await context.read<SessionsCubit>().resumeSession(
                                id,
                              );
                              if (context.mounted) {
                                context.read<DashboardCubit>().refresh();
                              }
                            },
                            onEnd: _openEndSessionDialog,
                          ),
                          const SizedBox(height: 20),
                          DashboardBirthdaysSidebar(
                            upcomingBirthdays: upcomingBirthdays,
                          ),
                          const SizedBox(height: 14),
                          DashboardWithdrawalsSidebar(
                            withdrawals: state.cashWithdrawals,
                            onWithdrawPressed: _openCashWithdrawalDialog,
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
