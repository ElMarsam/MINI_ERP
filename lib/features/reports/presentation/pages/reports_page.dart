import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../domain/entities/report_data.dart';
import '../pdf/report_pdf_builder.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportPeriod _period = ReportPeriod.daily;

  ReportData get _data => _getMockData(_period);

  Future<void> _exportPdf(ReportData data) async {
    final pdfBytes = await ReportPdfBuilder.build(data);
    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'NileHub_Report_${data.reportNumber}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;

    return Scaffold(
      backgroundColor: ReportPalette.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReportsHeader(onExportPdf: () => _exportPdf(data)),
                const SizedBox(height: 16),
                SummaryCards(data: data),
                const SizedBox(height: 16),
                ResponsiveReportGrid(
                  wideColumns: 2,
                  children: [
                    RevenueSourcesCard(data: data),
                    PaymentMethodsCard(data: data),
                  ],
                ),
                if (data.hasExpenses) ...[
                  const SizedBox(height: 16),
                  ExpensesCard(data: data),
                ],
                const SizedBox(height: 16),
                TransactionsLedger(
                  transactions: data.transactions,
                  totalCount: data.transactionsTotalCount,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// عداد تلقائي برقم مسلسل يتزايد كل يوم بناءً على تقويم السنة
  String _generateDailyReportNumber(DateTime date) {
    final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    return 'NH-${date.year}-$dayOfYear';
  }

  ReportData _getMockData(ReportPeriod period) {
    final now = DateTime.now();
    return ReportData(
      period: ReportPeriod.daily,
      from: now,
      to: now,
      reportNumber: _generateDailyReportNumber(now),
      sessionsRevenue: 6850,
      sessionsCount: 48,
      sessionsMinutes: 3420,
      buffetItems: const [
        BuffetItem(name: 'قهوة تركي مظبوط', quantity: 68, revenue: 2040),
        BuffetItem(name: 'لاتيه كراميل', quantity: 34, revenue: 1700),
        BuffetItem(name: 'مياه معدنية (كبير)', quantity: 95, revenue: 950),
        BuffetItem(name: 'عصير مانجو فريش', quantity: 28, revenue: 1400),
        BuffetItem(name: 'شاي كشري أصلي', quantity: 45, revenue: 675),
        BuffetItem(name: 'تشيز كيك لوتس', quantity: 19, revenue: 950),
      ],
      events: [
        EventBooking(
          customerName: 'مهندس كريم ممدوح',
          eventDate: DateTime(2026, 3, 2),
          total: 7500,
          deposit: 3000,
          status: 'مؤكد',
        ),
        EventBooking(
          customerName: 'أستاذة نوران حسن',
          eventDate: DateTime(2026, 3, 4),
          total: 4500,
          deposit: 1500,
          status: 'مؤكد',
        ),
      ],
      paymentsByMethod: const {
        PaymentMethod.cash: 7200,
        PaymentMethod.instaPay: 4100,
        PaymentMethod.vodafoneCash: 2475,
      },
      changePercent: 14.2,
      transactions: [
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 7)),
          receiptNumber: 'REC-301',
          customerName: 'إسلام الشناوي',
          customerTag: 'مشترك',
          itemLabel: 'قعدة فردي + شاي',
          type: RevenueType.session,
          amount: 140,
          method: PaymentMethod.cash,
          employeeName: 'عمرو',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 6, minutes: 40)),
          receiptNumber: 'REC-302',
          customerName: 'بسملة خالد',
          itemLabel: 'مكتب هادئ (4 ساعات)',
          type: RevenueType.session,
          amount: 250,
          method: PaymentMethod.instaPay,
          employeeName: 'مريم',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 5, minutes: 15)),
          receiptNumber: 'REC-303',
          customerName: 'دكتور وليد عبد الله',
          customerTag: 'VIP',
          itemLabel: '2 قهوة تركي + تشيز كيك',
          type: RevenueType.buffet,
          amount: 280,
          method: PaymentMethod.cash,
          employeeName: 'عمرو',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 4, minutes: 30)),
          receiptNumber: 'REC-304',
          customerName: 'مهندس كريم ممدوح',
          customerTag: 'حفل',
          itemLabel: 'عربون حفلة تخرج (قاعة أ)',
          type: RevenueType.event,
          amount: 3000,
          method: PaymentMethod.vodafoneCash,
          employeeName: 'سلمى',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 3, minutes: 50)),
          receiptNumber: 'REC-305',
          customerName: 'يوسف رامي',
          itemLabel: 'مساحة عمل مفتوحة',
          type: RevenueType.session,
          amount: 180,
          method: PaymentMethod.cash,
          employeeName: 'مريم',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 3, minutes: 10)),
          receiptNumber: 'REC-306',
          customerName: 'آية مرسي',
          itemLabel: 'لاتيه كراميل + مياه',
          type: RevenueType.buffet,
          amount: 110,
          method: PaymentMethod.instaPay,
          employeeName: 'عمرو',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 2, minutes: 20)),
          receiptNumber: 'REC-307',
          customerName: 'فريق تيم وورك',
          customerTag: 'مجموعة',
          itemLabel: 'حجز قاعة اجتماعات صغيرة (ساعتين)',
          type: RevenueType.session,
          amount: 600,
          method: PaymentMethod.cash,
          employeeName: 'سلمى',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 1, minutes: 45)),
          receiptNumber: 'REC-308',
          customerName: 'أستاذة نوران حسن',
          customerTag: 'حفل',
          itemLabel: 'عربون عيد ميلاد',
          type: RevenueType.event,
          amount: 1500,
          method: PaymentMethod.vodafoneCash,
          employeeName: 'مريم',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(hours: 1, minutes: 10)),
          receiptNumber: 'REC-309',
          customerName: 'محمود الصفتي',
          itemLabel: 'عصير مانجو فريش',
          type: RevenueType.buffet,
          amount: 50,
          method: PaymentMethod.cash,
          employeeName: 'عمرو',
        ),
        ReportTransaction(
          dateTime: now.subtract(const Duration(minutes: 45)),
          receiptNumber: 'REC-310',
          customerName: 'رنا حسام',
          itemLabel: 'قعدة فردي + قهوة',
          type: RevenueType.session,
          amount: 160,
          method: PaymentMethod.instaPay,
          employeeName: 'سلمى',
        ),
      ],
      transactionsTotalCount: 84,
    );
  }
}

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({super.key, this.onExportPdf});
  final VoidCallback? onExportPdf;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton.icon(
      onPressed: onExportPdf,
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
      label: const Text('تصدير PDF'),
      style: FilledButton.styleFrom(
        backgroundColor: ReportPalette.accent,
      ),
    );

    return ReportCard(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 12,
        spacing: 12,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التقارير المالية',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 4),
              Text(
                'تحليل تفصيلي للإيرادات وتوزيع وسائل الدفع.',
                style: TextStyle(fontSize: 13, color: ReportPalette.mutedText),
              ),
            ],
          ),
          onExportPdf == null
              ? Tooltip(message: 'التصدير غير متاح', child: button)
              : button,
        ],
      ),
    );
  }
}

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key, required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    return ResponsiveReportGrid(
      wideColumns: 4,
      children: [
        _MetricCard(
          label: 'إيرادات السيشنات',
          icon: Icons.chair_alt_outlined,
          value: data.sessionsRevenue,
          subtitle:
          '${formatNumber(data.sessionsCount)} سيشن (${formatNumber(data.sessionsMinutes)} دقيقة)',
        ),
        _MetricCard(
          label: 'مبيعات البوفيه',
          icon: Icons.coffee_outlined,
          value: data.buffetRevenue,
          subtitle: '${formatNumber(data.buffetItemsCount)} صنف تم صرفه',
        ),
        _MetricCard(
          label: 'مقبوضات الفعاليات',
          icon: Icons.celebration_outlined,
          value: data.eventsRevenue,
          subtitle: 'عرابين ${data.eventsBookingsCount} حفلة مؤكدة',
        ),
        _MetricCard(
          label: 'إجمالي المتحصلات',
          icon: Icons.payments_outlined,
          value: data.totalCollected,
          subtitle: _changeText(data),
          highlighted: true,
        ),
      ],
    );
  }

  String _changeText(ReportData d) {
    final sign = d.changePercent >= 0 ? '+' : '-';
    final percent = d.changePercent.abs().toStringAsFixed(1);
    return '$sign$percent% عن أمس';
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.subtitle,
    this.highlighted = false,
  });

  final String label;
  final IconData icon;
  final int value;
  final String subtitle;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final fg = highlighted ? ReportPalette.accent : ReportPalette.text;
    final muted = highlighted ? ReportPalette.accent : ReportPalette.mutedText;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted ? ReportPalette.accentSoft : ReportPalette.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: muted)),
              Icon(icon, size: 18, color: muted),
            ],
          ),
          const SizedBox(height: 6),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatNumber(value),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                TextSpan(
                  text: '  ج.م',
                  style: TextStyle(fontSize: 12, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );
  }
}

class RevenueSourcesCard extends StatelessWidget {
  const RevenueSourcesCard({super.key, required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final total = data.sessionsRevenue + data.buffetRevenue + data.eventsRevenue;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'توزيع مصادر الإيراد',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            'الحصة النسبية لكل قسم في ${periodNoun(data.period)}',
            style: const TextStyle(fontSize: 12, color: ReportPalette.mutedText),
          ),
          const SizedBox(height: 16),
          _SourceRow(
            label: 'جلسات العمل (سيشنات ومساحات)',
            amount: data.sessionsRevenue,
            total: total,
            color: ReportPalette.accent,
          ),
          _SourceRow(
            label: 'البوفيه والمشروبات والمأكولات',
            amount: data.buffetRevenue,
            total: total,
            color: ReportPalette.warning,
          ),
          _SourceRow(
            label: 'أعياد الميلاد وحجوزات القاعات',
            amount: data.eventsRevenue,
            total: total,
            color: ReportPalette.info,
          ),
        ],
      ),
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
  });

  final String label;
  final int amount;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : amount / total;
    final percent = (fraction * 100).round();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(label, style: const TextStyle(fontSize: 13)),
              ),
              Text(
                '${formatNumber(amount)} ج.م ($percent%)',
                style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 7,
              backgroundColor: ReportPalette.surface,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentMethodsCard extends StatelessWidget {
  const PaymentMethodsCard({super.key, required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final total = data.totalCollected;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تحصيل وسائل الدفع',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          const Text(
            'توزيع الكاش والمحافظ والتحويلات',
            style: TextStyle(fontSize: 12, color: ReportPalette.mutedText),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _PaymentTile(
                  label: 'كاش',
                  icon: Icons.payments_outlined,
                  amount: data.paid(PaymentMethod.cash),
                  total: total,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PaymentTile(
                  label: 'InstaPay',
                  icon: Icons.qr_code_2,
                  amount: data.paid(PaymentMethod.instaPay),
                  total: total,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PaymentTile(
                  label: 'فودافون كاش',
                  icon: Icons.phone_android,
                  amount: data.paid(PaymentMethod.vodafoneCash),
                  total: total,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  const _PaymentTile({
    required this.label,
    required this.icon,
    required this.amount,
    required this.total,
  });

  final String label;
  final IconData icon;
  final int amount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : amount / total * 100;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: ReportPalette.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: ReportPalette.accent),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatNumber(amount),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            '${percent.toStringAsFixed(1)}%',
            style: const TextStyle(fontSize: 12, color: ReportPalette.mutedText),
          ),
        ],
      ),
    );
  }
}

class ExpensesCard extends StatelessWidget {
  const ExpensesCard({super.key, required this.data});
  final ReportData data;

  @override
  Widget build(BuildContext context) {
    final expenses = data.expenses ?? const <ExpenseItem>[];

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'المصروفات وصافي الربح',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          const Text(
            'المصروفات تظهر في التقرير الشهري فقط',
            style: TextStyle(fontSize: 12, color: ReportPalette.mutedText),
          ),
          const SizedBox(height: 12),
          for (final x in expenses)
            _ExpenseLine(label: x.name, value: formatNumber(x.amount)),
          _ExpenseLine(
            label: 'إجمالي المصروفات',
            value: formatNumber(data.totalExpenses),
            strong: true,
            topBorder: true,
          ),
          _ExpenseLine(
            label:
            'صافي الربح (المحصّل ${formatNumber(data.totalCollected)} – المصروفات)',
            value: formatNumber(data.netProfit),
            strong: true,
            accent: true,
            topBorder: true,
          ),
        ],
      ),
    );
  }
}

class _ExpenseLine extends StatelessWidget {
  const _ExpenseLine({
    required this.label,
    required this.value,
    this.strong = false,
    this.accent = false,
    this.topBorder = false,
  });

  final String label;
  final String value;
  final bool strong;
  final bool accent;
  final bool topBorder;

  @override
  Widget build(BuildContext context) {
    final color = accent ? ReportPalette.accent : ReportPalette.text;
    final weight = strong ? FontWeight.w700 : FontWeight.w400;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          top: topBorder
              ? const BorderSide(color: ReportPalette.text, width: 1.2)
              : BorderSide.none,
          bottom: !topBorder
              ? const BorderSide(color: ReportPalette.border)
              : BorderSide.none,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, fontWeight: weight, color: color),
            ),
          ),
          Text(
            '$value ج.م',
            style: TextStyle(fontSize: 13, fontWeight: weight, color: color),
          ),
        ],
      ),
    );
  }
}

class TransactionsLedger extends StatefulWidget {
  const TransactionsLedger({
    super.key,
    required this.transactions,
    required this.totalCount,
  });

  final List<ReportTransaction> transactions;
  final int totalCount;

  @override
  State<TransactionsLedger> createState() => _TransactionsLedgerState();
}

class _TransactionsLedgerState extends State<TransactionsLedger> {
  RevenueType? _type;
  PaymentMethod? _method;
  String _query = '';

  static const _flex = [2, 2, 4, 4, 2, 2, 3];
  static const _minTableWidth = 900.0;

  List<ReportTransaction> get _filtered {
    final q = _query.trim();
    return widget.transactions.where((t) {
      final typeOk = _type == null || t.type == _type;
      final methodOk = _method == null || t.method == _method;
      final queryOk =
          q.isEmpty || t.receiptNumber.contains(q) || t.customerName.contains(q);
      return typeOk && methodOk && queryOk;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    final pageTotal = rows.fold<int>(0, (s, t) => s + t.amount);

    return ReportCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildFilters(),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth < _minTableWidth
                  ? _minTableWidth
                  : constraints.maxWidth;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Column(
                    children: [
                      _buildHeaderRow(),
                      if (rows.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'لا توجد معاملات مطابقة للفلتر.',
                            style: TextStyle(color: ReportPalette.mutedText),
                          ),
                        )
                      else
                        for (final t in rows) _buildDataRow(t),
                    ],
                  ),
                ),
              );
            },
          ),
          Container(
            color: ReportPalette.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'عرض ${rows.length} من أصل ${formatNumber(widget.totalCount)} معاملة'
                  '   |   إجمالي الصفحة: ${formatNumber(pageTotal)} ج.م',
              style: const TextStyle(fontSize: 12, color: ReportPalette.mutedText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        runSpacing: 10,
        spacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'دفتر اليومية والمعاملات التفصيلية',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 10),
              _SmallChip('إجمالي ${formatNumber(widget.totalCount)} حركة'),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _FilterBox(
                child: DropdownButton<RevenueType?>(
                  value: _type,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(
                      fontSize: 12, color: ReportPalette.text),
                  items: [
                    const DropdownMenuItem<RevenueType?>(
                        value: null, child: Text('كل البنود')),
                    for (final t in RevenueType.values)
                      DropdownMenuItem<RevenueType?>(
                          value: t, child: Text(revenueTypeLabel(t))),
                  ],
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
              _FilterBox(
                child: DropdownButton<PaymentMethod?>(
                  value: _method,
                  isDense: true,
                  underline: const SizedBox.shrink(),
                  style: const TextStyle(
                      fontSize: 12, color: ReportPalette.text),
                  items: [
                    const DropdownMenuItem<PaymentMethod?>(
                        value: null, child: Text('كل طرق الدفع')),
                    for (final m in PaymentMethod.values)
                      DropdownMenuItem<PaymentMethod?>(
                          value: m, child: Text(paymentMethodLabel(m))),
                  ],
                  onChanged: (v) => setState(() => _method = v),
                ),
              ),
              SizedBox(
                width: 190,
                height: 36,
                child: TextField(
                  style: const TextStyle(fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'بحث بالإيصال أو العميل',
                    prefixIcon: Icon(Icons.search, size: 18),
                    border: OutlineInputBorder(),
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onChanged: (v) => setState(() => _query = v),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cell(int index, Widget child) =>
      Expanded(flex: _flex[index], child: child);

  Widget _buildHeaderRow() {
    const headers = [
      'التاريخ والوقت',
      'رقم الإيصال',
      'العميل',
      'بند الإيراد',
      'المبلغ',
      'طريقة السداد',
      'الموظف المستلم',
    ];
    return Container(
      color: ReportPalette.surface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          for (var i = 0; i < headers.length; i++)
            _cell(
              i,
              Text(
                headers[i],
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ReportPalette.mutedText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDataRow(ReportTransaction t) {
    return DataRowBuilder(t: t, flex: _flex);
  }
}

class DataRowBuilder extends StatelessWidget {
  const DataRowBuilder({super.key, required this.t, required this.flex});
  final ReportTransaction t;
  final List<int> flex;

  Widget _cell(int index, Widget child) => Expanded(flex: flex[index], child: child);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: ReportPalette.border)),
      ),
      child: Row(
        children: [
          _cell(
            0,
            Text(formatTime(t.dateTime),
                style: const TextStyle(
                    fontSize: 12, color: ReportPalette.mutedText)),
          ),
          _cell(
            1,
            Text(t.receiptNumber,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          _cell(
            2,
            Row(
              children: [
                Flexible(
                  child: Text(
                    t.customerName,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                if (t.customerTag != null) ...[
                  const SizedBox(width: 6),
                  _SmallChip(t.customerTag!),
                ],
              ],
            ),
          ),
          _cell(
            3,
            Text(t.itemLabel,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12)),
          ),
          _cell(
            4,
            Text('${formatNumber(t.amount)} ج.م',
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700)),
          ),
          _cell(
            5,
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _SmallChip(paymentMethodLabel(t.method)),
            ),
          ),
          _cell(
            6,
            Text(t.employeeName,
                style: TextStyle(
                    fontSize: 12, color: ReportPalette.mutedText)),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: ReportPalette.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, color: ReportPalette.text),
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: ReportPalette.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
