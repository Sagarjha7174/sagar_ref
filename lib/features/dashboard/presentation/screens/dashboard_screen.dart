import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/extensions/date_extensions.dart';
import '../../../complaints/domain/entities/complaint.dart';
import '../../../complaints/domain/usecases/record_collection_use_case.dart';
import '../../../complaints/presentation/providers/pending_complaints_provider.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../domain/entities/dashboard_data.dart';
import '../widgets/earnings_card.dart';
import '../widgets/status_count_card.dart';
import '../widgets/monthly_earnings_chart.dart';
import '../widgets/appliance_distribution_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.dashboard),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DashboardTimeFilter>(
                  value: ref.watch(dashboardTimeFilterProvider),
                  icon: Icon(Icons.filter_list, color: theme.colorScheme.onPrimary),
                  dropdownColor: theme.colorScheme.surface,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  onChanged: (DashboardTimeFilter? newValue) {
                    if (newValue != null) {
                      ref.read(dashboardTimeFilterProvider.notifier).setFilter(newValue);
                    }
                  },
                  items: DashboardTimeFilter.values.map((DashboardTimeFilter filter) {
                    return DropdownMenuItem<DashboardTimeFilter>(
                      value: filter,
                      child: Text(filter.label),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Collections'),
            ],
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
          ),
        ),
        body: dashboardAsync.when(
          loading: () => const LoadingWidget(),
          error: (error, _) => ErrorStateWidget(
            message: error.toString(),
            onRetry: () => ref.invalidate(dashboardProvider),
          ),
          data: (data) => TabBarView(
            children: [
              _DashboardBody(data: data),
              _CollectionsTab(data: data),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Earnings Grid
        _buildEarningsGrid(context),
        const SizedBox(height: 12),

        // Status Counts
        _buildStatusCounts(context),
        const SizedBox(height: 12),

        // Monthly Chart
        MonthlyEarningsChart(monthlyTrend: data.monthlyTrend),
        const SizedBox(height: 12),

        // Appliance Distribution
        ApplianceDistributionChart(distribution: data.applianceDistribution),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEarningsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.6,
      children: [
        EarningsCard(
          label: Strings.todayEarnings,
          amount: data.todayEarnings,
          icon: Icons.today,
          color: const Color(0xFF1565C0),
        ),
        EarningsCard(
          label: Strings.weeklyEarnings,
          amount: data.weeklyEarnings,
          icon: Icons.calendar_view_week,
          color: const Color(0xFF7B1FA2),
        ),
        EarningsCard(
          label: Strings.monthlyEarnings,
          amount: data.monthlyEarnings,
          icon: Icons.calendar_month,
          color: const Color(0xFF2E7D32),
        ),
        EarningsCard(
          label: Strings.totalEarnings,
          amount: data.totalEarnings,
          icon: Icons.account_balance_wallet,
          color: const Color(0xFFE65100),
        ),
      ],
    );
  }

  Widget _buildStatusCounts(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatusCountCard(
            label: Strings.pending,
            count: data.pendingCount,
            color: AppTheme.pendingColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatusCountCard(
            label: Strings.completed,
            count: data.completedCount,
            color: AppTheme.completedColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatusCountCard(
            label: Strings.rejected,
            count: data.rejectedCount,
            color: AppTheme.rejectedColor,
          ),
        ),
      ],
    );
  }
}

class _CollectionsTab extends ConsumerWidget {
  const _CollectionsTab({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        // Collection Stats Row
        Row(
          children: [
            Expanded(
              child: _CollectionStatCard(
                label: 'Total Earned',
                amount: data.totalEarnings,
                color: theme.colorScheme.primary,
                icon: Icons.account_balance_wallet,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CollectionStatCard(
                label: 'Total Collected',
                amount: data.totalCollected,
                color: Colors.green.shade700,
                icon: Icons.check_circle_outline,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _CollectionStatCard(
                label: 'Remains to Collect',
                amount: data.totalPending,
                color: Colors.red.shade700,
                icon: Icons.pending_actions,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Pending Collections (${data.pendingCollections.length})',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (data.pendingCollections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'All payments collected!',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          ...data.pendingCollections.map((complaint) => _PendingCollectionCard(
                complaint: complaint,
              )),
      ],
    );
  }
}

class _CollectionStatCard extends StatelessWidget {
  const _CollectionStatCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1.5,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '₹${amount.toStringAsFixed(0)}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingCollectionCard extends ConsumerWidget {
  const _PendingCollectionCard({required this.complaint});

  final Complaint complaint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final earned = complaint.amountEarned ?? 0;
    final collected = complaint.amountCollected ?? 0;
    final pending = complaint.amountPending ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/complaints/${complaint.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    complaint.customerName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Pending: ₹${pending.toStringAsFixed(0)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              complaint.phoneNumber,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Completed: ${complaint.completedAt?.toDisplayDateTime() ?? complaint.createdAt.toDisplayDateTime()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ₹${earned.toStringAsFixed(0)}  •  Collected: ₹${collected.toStringAsFixed(0)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.call, color: Colors.green, size: 20),
                      onPressed: () => _callCustomer(context, complaint.phoneNumber),
                      tooltip: 'Call Customer',
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => _showRecordPaymentDialog(context, ref),
                      style: ElevatedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                      child: const Text('Collect', style: TextStyle(fontSize: 12)),
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

  Future<void> _callCustomer(BuildContext context, String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _showRecordPaymentDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => _RecordPaymentDialog(
        complaint: complaint,
        onSuccess: () {
          ref.invalidate(dashboardProvider);
          ref.invalidate(pendingComplaintsNotifierProvider);
          ref.invalidate(historyNotifierProvider);
        },
      ),
    );
  }
}

class _RecordPaymentDialog extends ConsumerStatefulWidget {
  const _RecordPaymentDialog({
    required this.complaint,
    required this.onSuccess,
  });

  final Complaint complaint;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_RecordPaymentDialog> createState() => _RecordPaymentDialogState();
}

class _RecordPaymentDialogState extends ConsumerState<_RecordPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _collectController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _collectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = widget.complaint.amountPending ?? 0;

    return AlertDialog(
      title: const Text('Record Collection'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${widget.complaint.customerName}'),
            const SizedBox(height: 4),
            Text('Remaining Pending: ₹${pending.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _collectController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Amount Collected Today',
                prefixText: '₹ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Amount is required';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Amount must be greater than zero';
                }
                if (amount > pending) {
                  return 'Cannot collect more than ₹${pending.toStringAsFixed(0)}';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Record'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final collectAmt = double.parse(_collectController.text);
    final currentCollected = widget.complaint.amountCollected ?? 0;
    final totalEarned = widget.complaint.amountEarned ?? 0;

    final newCollected = currentCollected + collectAmt;
    final newPending = totalEarned - newCollected;

    final useCase = ref.read(recordCollectionUseCaseProvider);
    final result = await useCase.call(RecordCollectionParams(
      id: widget.complaint.id,
      amountCollected: newCollected,
      amountPending: newPending >= 0 ? newPending : 0,
    ));

    if (mounted) {
      setState(() => _isSubmitting = false);
      result.when(
        success: (_) {
          Navigator.of(context).pop();
          widget.onSuccess();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Recorded payment of ₹${collectAmt.toStringAsFixed(0)}'),
              backgroundColor: Colors.green,
            ),
          );
        },
        failure: (f) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(f.message),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }
}
