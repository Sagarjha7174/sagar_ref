import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/string_constants.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_state_widget.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../complaints/domain/entities/complaint.dart';
import '../../../complaints/presentation/providers/pending_complaints_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/history_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController1 = ScrollController();
  final _scrollController2 = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController1.addListener(_onScroll);
    _scrollController2.addListener(_onScroll);
  }

  void _onScroll() {
    bool shouldLoad = false;
    
    if (_scrollController1.hasClients) {
      if (_scrollController1.position.pixels >= _scrollController1.position.maxScrollExtent - 200) {
        shouldLoad = true;
      }
    }
    
    if (_scrollController2.hasClients) {
      if (_scrollController2.position.pixels >= _scrollController2.position.maxScrollExtent - 200) {
        shouldLoad = true;
      }
    }

    if (shouldLoad) {
      ref.read(historyNotifierProvider.notifier).loadHistory(loadMore: true);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyNotifierProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(Strings.history),
          bottom: TabBar(
            tabs: const [
              Tab(text: 'Completed'),
              Tab(text: 'Rejected'),
            ],
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
          ),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: Strings.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(historyNotifierProvider.notifier).setSearchQuery('');
                          },
                        )
                      : null,
                  isDense: true,
                ),
                onChanged: (value) {
                  ref.read(historyNotifierProvider.notifier).setSearchQuery(value);
                  setState(() {});
                },
              ),
            ),

            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text(Strings.thisMonth),
                        selected: state.filter.filterMonth != null && state.filter.filterMonth!.month == DateTime.now().month,
                        onSelected: (selected) {
                          if (selected) {
                            final now = DateTime.now();
                            ref.read(historyNotifierProvider.notifier).setMonthFilter(
                                  DateTime(now.year, now.month),
                                );
                          } else {
                            ref.read(historyNotifierProvider.notifier).clearFilters();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text(Strings.dateRange),
                        selected: state.filter.filterStartDate != null && state.filter.filterStartDate!.month != 1,
                        onSelected: (_) => _showDateRangePicker(),
                      ),
                      if (state.filter.hasActiveFilter &&
                          (state.filter.filterMonth != null ||
                              state.filter.filterStartDate != null)) ...[
                        const SizedBox(width: 8),
                        ActionChip(
                          label: const Text(Strings.clear),
                          onPressed: () {
                            ref.read(historyNotifierProvider.notifier).clearFilters();
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Tab View lists
            Expanded(
              child: TabBarView(
                children: [
                  Column(
                    children: [
                      Expanded(child: _buildList(state, ComplaintStatus.completed)),
                      _buildEarningsBanner(state, theme),
                    ],
                  ),
                  _buildList(state, ComplaintStatus.rejected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarningsBanner(HistoryState state, ThemeData theme) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: theme.colorScheme.onPrimaryContainer,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.filter.hasActiveFilter ? 'Filtered Earnings' : 'Total Earnings',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹${state.totalEarnings.toStringAsFixed(0)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(HistoryState state, ComplaintStatus status) {
    if (state.isLoading) {
      return const LoadingWidget();
    }

    if (state.error != null) {
      return ErrorStateWidget(
        message: state.error!,
        onRetry: () => ref.read(historyNotifierProvider.notifier).loadHistory(),
      );
    }

    final filteredComplaints = state.complaints
        .where((c) => c.status == status)
        .toList();

    return _buildHistoryList(filteredComplaints, status);
  }

  Widget _buildHistoryList(List<Complaint> filteredComplaints, ComplaintStatus status) {
    final hasReachedMax = ref.watch(historyNotifierProvider).hasReachedMax;
    final isLoading = ref.watch(historyNotifierProvider).isLoading;

    if (filteredComplaints.isEmpty && hasReachedMax && !isLoading) {
      return EmptyStateWidget(
        icon: status == ComplaintStatus.completed
            ? Icons.check_circle_outline
            : Icons.cancel_outlined,
        title: status == ComplaintStatus.completed
            ? 'No completed complaints'
            : 'No rejected complaints',
        subtitle: Strings.noHistorySubtitle,
      );
    }

    return ListView.builder(
      controller: status == ComplaintStatus.completed ? _scrollController1 : _scrollController2,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: filteredComplaints.length + 1,
      itemBuilder: (context, index) {
        if (index == filteredComplaints.length) {
          final hasReachedMax = ref.read(historyNotifierProvider).hasReachedMax;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: hasReachedMax 
                  ? const Text('End of history') 
                  : const CircularProgressIndicator(),
            ),
          );
        }

        final complaint = filteredComplaints[index];
        return HistoryCard(
          complaint: complaint,
          onTap: () => context.push('/complaints/${complaint.id}'),
          onReopen: () => _reopenComplaint(complaint),
          onDelete: status == ComplaintStatus.rejected 
              ? () => _deleteComplaint(complaint) 
              : null,
        );
      },
    );
  }

  Future<void> _showDateRangePicker() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      ref.read(historyNotifierProvider.notifier).setDateRange(
            picked.start,
            picked.end,
          );
    }
  }

  Future<void> _reopenComplaint(Complaint complaint) async {
    final useCase = ref.read(reopenComplaintUseCaseProvider);
    final result = await useCase.call(complaint.id);

    if (mounted) {
      result.when(
        success: (_) {
          ref.invalidate(pendingComplaintsNotifierProvider);
          ref.invalidate(dashboardProvider);
          ref.read(historyNotifierProvider.notifier).loadHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(Strings.complaintReopened),
              backgroundColor: Colors.green,
            ),
          );
        },
        failure: (f) {
          if (f.message.contains('pending')) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text(Strings.cannotReopen),
                content: const Text(Strings.cannotReopenBody),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(Strings.ok),
                  ),
                ],
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(f.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    }
  }

  Future<void> _deleteComplaint(Complaint complaint) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Complaint'),
        content: const Text('Are you sure you want to delete this rejected complaint? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final useCase = ref.read(deleteComplaintUseCaseProvider);
    final result = await useCase.call(complaint.id);

    if (mounted) {
      result.when(
        success: (_) {
          ref.read(historyNotifierProvider.notifier).loadHistory();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Complaint deleted successfully'),
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
