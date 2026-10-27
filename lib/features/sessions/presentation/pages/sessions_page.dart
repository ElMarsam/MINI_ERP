import 'package:coworking_erp/core/constants/app_colors.dart';
import 'package:coworking_erp/core/constants/app_text_style.dart';
import 'package:coworking_erp/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:coworking_erp/features/sessions/domain/entities/session.dart';
import 'package:coworking_erp/features/sessions/presentation/cubit/sessions_cubit.dart';
import 'package:coworking_erp/features/sessions/presentation/widgets/sessions_active_tab.dart';
import 'package:coworking_erp/features/sessions/presentation/widgets/sessions_closed_history_table.dart';
import 'package:coworking_erp/features/sessions/presentation/widgets/sessions_header_bar.dart';
import 'package:coworking_erp/features/widgets/common/end_session_dialog.dart';
import 'package:coworking_erp/features/widgets/common/start_session_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ==============================================================================
// صفحة إدارة السيشنات (SessionsPage)
// صفحة منسقة (Coordinator Page) تدير التفاعل مع Cubit وتجمع الـ Custom Widgets
// ==============================================================================
class SessionsPage extends StatefulWidget {
  const SessionsPage({super.key});

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage>
    with SingleTickerProviderStateMixin {
  // وحدة التحكم بالتبويبات (Active Sessions vs Closed Sessions)
  late TabController _tabController;

  // وحدة التحكم بحقل البحث
  final TextEditingController _searchController = TextEditingController();

  // نص البحث الحالي للفلترة
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<SessionsCubit>().loadSessions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // فتح نافذة بدء جلسة جديدة
  void _openStartSessionDialog() {
    final cubit = context.read<SessionsCubit>();
    final dashboardCubit = context.read<DashboardCubit>();

    StartSessionDialog.show(
      context,
      dataSource: cubit.dataSource,
      onStartSession:
          ({
            required customerId,
            required customerName,
            deskId,
            deskLabel,
            ratePerMinute,
          }) async {
            await cubit.startSession(
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

  // فتح نافذة إنهاء الجلسة وتسوية الحساب
  void _openEndSessionDialog(Session session) {
    final cubit = context.read<SessionsCubit>();
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
            await cubit.closeSession(
              sessionId,
              totalAmount: totalAmount,
              paidAmount: paidAmount,
              paymentMethod: paymentMethod,
            );
            dashboardCubit.refresh();
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SessionsCubit, SessionsState>(
        listener: (context, state) {},
        builder: (context, state) {
          // 1. حالة التحميل
          if (state is SessionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. حالة حدوث خطأ
          if (state is SessionsError) {
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
                    'حدث خطأ في تحميل السيشنات',
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
                  ElevatedButton(
                    onPressed: () =>
                        context.read<SessionsCubit>().loadSessions(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // 3. حالة اكتمال التحميل
          if (state is SessionsLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // بناء واجهة المحتوى الرئيسية للسيشنات
  Widget _buildContent(BuildContext context, SessionsLoaded state) {
    // تصفية الجلسات النشطة بحسب نص البحث
    final activeSessions = state.activeSessions.where((s) {
      if (_searchQuery.isEmpty) return true;
      return s.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (s.deskLabel != null &&
              s.deskLabel!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    // تصفية الجلسات المنتهية بحسب نص البحث
    final closedSessions = state.todaySessions.where((s) {
      if (s.status != SessionStatus.closed) return false;
      if (_searchQuery.isEmpty) return true;
      return s.customerName.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (s.deskLabel != null &&
              s.deskLabel!.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── الشريط العلوي: العنوان + حقل البحث السريع + زر بدء سيشن ───
          SessionsHeaderBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            onSearchChanged: (val) => setState(() => _searchQuery = val.trim()),
            onClearSearch: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
            onStartSessionPressed: _openStartSessionDialog,
          ),
          const SizedBox(height: 16),

          // ─── شريط التبويبات (الجلسات النشطة vs سجل اليوم المنتهي) ───
          Container(
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.divider)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.secondary,
              indicatorWeight: 3,
              labelStyle: AppTextStyles.labelLg,
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.timer, size: 16),
                      const SizedBox(width: 6),
                      Text('الجلسات النشطة (${activeSessions.length})'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.checkCheck, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'سجل جلسات اليوم المنتهية (${closedSessions.length})',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── مساحة عرض التبويبات ───
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // التبويب 1: كروت الجلسات النشطة
                SessionsActiveTab(
                  sessions: activeSessions,
                  isSearching: _searchQuery.isNotEmpty,
                  onStartSession: _openStartSessionDialog,
                  onPauseSession: (id) async {
                    await context.read<SessionsCubit>().pauseSession(id);
                    if (context.mounted) {
                      context.read<DashboardCubit>().refresh();
                    }
                  },
                  onResumeSession: (id) async {
                    await context.read<SessionsCubit>().resumeSession(id);
                    if (context.mounted) {
                      context.read<DashboardCubit>().refresh();
                    }
                  },
                  onEndSession: _openEndSessionDialog,
                ),
                // التبويب 2: جدول الجلسات المنتهية
                SessionsClosedHistoryTable(sessions: closedSessions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
