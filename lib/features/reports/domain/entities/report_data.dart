import 'package:flutter/material.dart';

enum ReportPeriod { daily }

enum PaymentMethod { cash, instaPay, vodafoneCash }

enum RevenueType { session, buffet, event }

class ReportTransaction {
  const ReportTransaction({
    required this.dateTime,
    required this.receiptNumber,
    required this.customerName,
    this.customerTag,
    required this.itemLabel,
    required this.type,
    required this.amount,
    required this.method,
    required this.employeeName,
  });

  final DateTime dateTime;
  final String receiptNumber;
  final String customerName;
  final String? customerTag;
  final String itemLabel;
  final RevenueType type;
  final int amount;
  final PaymentMethod method;
  final String employeeName;
}

class BuffetItem {
  const BuffetItem({
    required this.name,
    required this.quantity,
    required this.revenue,
  });

  final String name;
  final int quantity;
  final int revenue;
}

class EventBooking {
  const EventBooking({
    required this.customerName,
    required this.eventDate,
    required this.total,
    required this.deposit,
    required this.status,
  });

  final String customerName;
  final DateTime eventDate;
  final int total;
  final int deposit;
  final String status;

  int get remaining => total - deposit;
}

class ExpenseItem {
  const ExpenseItem({required this.name, required this.amount});

  final String name;
  final int amount;
}

class ReportData {
  const ReportData({
    required this.period,
    required this.from,
    required this.to,
    required this.reportNumber,
    required this.sessionsRevenue,
    required this.sessionsCount,
    required this.sessionsMinutes,
    required this.buffetItems,
    required this.events,
    required this.paymentsByMethod,
    required this.changePercent,
    required this.transactions,
    required this.transactionsTotalCount,
    this.expenses,
  });

  final ReportPeriod period;
  final DateTime from;
  final DateTime to;
  final String reportNumber;

  final int sessionsRevenue;
  final int sessionsCount;
  final int sessionsMinutes;

  final List<BuffetItem> buffetItems;
  final List<EventBooking> events;

  final Map<PaymentMethod, int> paymentsByMethod;
  final double changePercent;

  final List<ReportTransaction> transactions;
  final int transactionsTotalCount;

  final List<ExpenseItem>? expenses;

  int get avgSessionMinutes =>
      sessionsCount == 0 ? 0 : (sessionsMinutes / sessionsCount).round();
  int get avgSessionValue =>
      sessionsCount == 0 ? 0 : (sessionsRevenue / sessionsCount).round();

  int get buffetRevenue => buffetItems.fold(0, (s, i) => s + i.revenue);
  int get buffetItemsCount => buffetItems.fold(0, (s, i) => s + i.quantity);

  int get eventsRevenue => eventsDeposits;
  int get eventsBookingsCount => events.length;
  int get eventsTotal => events.fold(0, (s, e) => s + e.total);
  int get eventsDeposits => events.fold(0, (s, e) => s + e.deposit);
  int get eventsRemaining => events.fold(0, (s, e) => s + e.remaining);

  int paid(PaymentMethod method) => paymentsByMethod[method] ?? 0;
  int get totalCollected => paymentsByMethod.values.fold(0, (s, v) => s + v);

  bool get hasExpenses => expenses != null;
  int get totalExpenses =>
      (expenses ?? const <ExpenseItem>[]).fold(0, (s, x) => s + x.amount);
  int get netProfit => totalCollected - totalExpenses;
}

class ReportPalette {
  static const background = Color(0xFFF4F6F5);
  static const surface = Color(0xFFF2F4F5);
  static const text = Color(0xFF1B1F1D);
  static const mutedText = Color(0xFF6B7370);
  static const border = Color(0xFFE3E7E5);
  static const accent = Color(0xFF0B6B4B);
  static const accentSoft = Color(0xFFE3F6EC);
  static const warning = Color(0xFFB26A00);
  static const info = Color(0xFF1565C0);
}

class ReportCard extends StatelessWidget {
  const ReportCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ReportPalette.border),
      ),
      child: child,
    );
  }
}

class ResponsiveReportGrid extends StatelessWidget {
  const ResponsiveReportGrid({
    super.key,
    required this.children,
    required this.wideColumns,
    this.breakpoint = 800,
    this.spacing = 12,
  });

  final List<Widget> children;
  final int wideColumns;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrowColumns = wideColumns > 2 ? 2 : 1;
        final columns =
        constraints.maxWidth >= breakpoint ? wideColumns : narrowColumns;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final child in children)
              SizedBox(width: itemWidth, child: child),
          ],
        );
      },
    );
  }
}

String formatNumber(int n) {
  final s = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
    buf.write(s[i]);
  }
  return n < 0 ? '-$buf' : buf.toString();
}

String formatTime(DateTime d) {
  final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final minute = d.minute.toString().padLeft(2, '0');
  final suffix = d.hour < 12 ? 'ص' : 'م';
  return '${hour12.toString().padLeft(2, '0')}:$minute $suffix';
}

const _months = [
  'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
  'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';
String formatDayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';
String formatMonthYear(DateTime d) => '${_months[d.month - 1]} ${d.year}';

String periodNoun(ReportPeriod p) {
  switch (p) {
    case ReportPeriod.daily:
      return 'اليوم';
  }
}

String paymentMethodLabel(PaymentMethod m) {
  switch (m) {
    case PaymentMethod.cash:
      return 'كاش نقدي';
    case PaymentMethod.instaPay:
      return 'InstaPay';
    case PaymentMethod.vodafoneCash:
      return 'فودافون كاش';
  }
}

String revenueTypeLabel(RevenueType t) {
  switch (t) {
    case RevenueType.session:
      return 'سيشنات ومساحات';
    case RevenueType.buffet:
      return 'بوفيه ومشروبات';
    case RevenueType.event:
      return 'حجوزات وفعاليات';
  }
}
