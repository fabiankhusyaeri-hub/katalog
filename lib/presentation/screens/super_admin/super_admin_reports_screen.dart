import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'super_admin_order_detail_screen.dart';

class SuperAdminReportsScreen extends StatefulWidget {
  const SuperAdminReportsScreen({super.key});

  @override
  State<SuperAdminReportsScreen> createState() =>
      _SuperAdminReportsScreenState();
}

class _SuperAdminReportsScreenState extends State<SuperAdminReportsScreen> {
  String _selectedStatus = 'all';
  DateTime? _fromDate;
  DateTime? _toDate;

  String _formatDate(DateTime? value) {
    if (value == null) return '-';
    return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  }

  Future<Map<String, dynamic>> _loadReports() async {
    final usersSnap = await FirebaseFirestore.instance
        .collection('users')
        .get();
    final ordersSnap = await FirebaseFirestore.instance
        .collection('orders')
        .get();

    final totalUsers = usersSnap.docs.length;
    final totalOrders = ordersSnap.docs.length;
    final pendingOrders = ordersSnap.docs.where((doc) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      return status == 'pending';
    }).length;
    final completedOrders = ordersSnap.docs.where((doc) {
      final status = (doc.data()['status'] ?? '').toString().toLowerCase();
      return status == 'completed' || status == 'success';
    }).length;
    final totalRevenue = ordersSnap.docs.fold<int>(0, (totalSum, doc) {
      final total = doc.data()['total'];
      if (total is num) return totalSum + total.toInt();
      return totalSum;
    });

    final reports = ordersSnap.docs.map((doc) {
      final data = doc.data();
      final items = (data['items'] as List<dynamic>? ?? const [])
          .map((item) => item['title'] ?? item['name'] ?? 'Produk')
          .join(', ');
      final createdAt = data['created_at'];
      return {
        'id': doc.id,
        'status': (data['status'] ?? 'pending').toString(),
        'total': (data['total'] ?? 0).toString(),
        'items': items,
        'createdAt': createdAt is Timestamp ? createdAt.toDate() : null,
      };
    }).toList();

    return {
      'totalUsers': totalUsers,
      'totalOrders': totalOrders,
      'pendingOrders': pendingOrders,
      'completedOrders': completedOrders,
      'totalRevenue': totalRevenue,
      'reports': reports,
    };
  }

  List<Map<String, dynamic>> _filterReports(List<dynamic> reports) {
    return reports.whereType<Map<String, dynamic>>().where((item) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      final createdAt = item['createdAt'] as DateTime?;

      final matchesStatus =
          _selectedStatus == 'all' || status == _selectedStatus;
      final matchesFrom =
          _fromDate == null ||
          createdAt == null ||
          !createdAt.isBefore(_fromDate!);
      final matchesTo =
          _toDate == null ||
          createdAt == null ||
          !createdAt.isAfter(
            DateTime(
              _toDate!.year,
              _toDate!.month,
              _toDate!.day,
              23,
              59,
              59,
              999,
            ),
          );

      return matchesStatus && matchesFrom && matchesTo;
    }).toList();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final initialDate = (isFrom
        ? _fromDate ?? _toDate ?? DateTime.now()
        : _toDate ?? _fromDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_toDate != null && _fromDate!.isAfter(_toDate!)) {
          _toDate = picked;
        }
      } else {
        _toDate = picked;
        if (_fromDate != null && _toDate!.isBefore(_fromDate!)) {
          _fromDate = picked;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        actions: [
          IconButton(
            tooltip: 'Export laporan',
            icon: const Icon(Icons.file_download_outlined),
            onPressed: () async {
              final reportsData = await _loadReports();
              final filteredReports = _filterReports(
                (reportsData['reports'] as List?) ?? const [],
              );
              final rows = <String>[
                'order_id,status,total,items,created_at',
                ...filteredReports.map((item) {
                  final createdAt = item['createdAt'];
                  final dateText = createdAt is DateTime
                      ? createdAt.toIso8601String()
                      : '';
                  final safeItems = (item['items'] ?? '').toString().replaceAll(
                    ',',
                    ';',
                  );
                  return '${item['id']},${item['status']},${item['total']},"$safeItems",$dateText';
                }),
              ];
              final csv = rows.join('\n');
              await Clipboard.setData(ClipboardData(text: csv));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Laporan berhasil disalin ke clipboard'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data =
              snapshot.data ??
              {
                'totalUsers': 0,
                'totalOrders': 0,
                'pendingOrders': 0,
                'completedOrders': 0,
                'totalRevenue': 0,
                'reports': const [],
              };

          final allReports = (data['reports'] as List?) ?? const [];
          final filteredReports = _filterReports(allReports);
          final filteredRevenue = filteredReports.fold<int>(0, (
            totalSum,
            item,
          ) {
            final total = item['total'];
            if (total is num) return totalSum + total.toInt();
            if (total is String) return totalSum + (int.tryParse(total) ?? 0);
            return totalSum;
          });

          final stats = [
            {
              'label': 'Total User',
              'value': '${data['totalUsers']}',
              'color': Colors.blue,
            },
            {
              'label': 'Pesanan',
              'value': '${filteredReports.length}',
              'color': Colors.green,
            },
            {
              'label': 'Status',
              'value': _selectedStatus == 'all' ? 'Semua' : _selectedStatus,
              'color': Colors.orange,
            },
            {
              'label': 'Pendapatan',
              'value': 'Rp$filteredRevenue',
              'color': Colors.purple,
            },
          ];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: stats.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final stat = stats[index];
                  final color = stat['color'] as Color;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            stat['value'] as String,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat['label'] as String,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filter Laporan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          SizedBox(
                            width: 180,
                            child: DropdownButtonFormField<String>(
                              initialValue: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text('Semua'),
                                ),
                                DropdownMenuItem(
                                  value: 'pending',
                                  child: Text('Pending'),
                                ),
                                DropdownMenuItem(
                                  value: 'completed',
                                  child: Text('Completed'),
                                ),
                                DropdownMenuItem(
                                  value: 'success',
                                  child: Text('Success'),
                                ),
                                DropdownMenuItem(
                                  value: 'cancelled',
                                  child: Text('Cancelled'),
                                ),
                                DropdownMenuItem(
                                  value: 'processing',
                                  child: Text('Processing'),
                                ),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() => _selectedStatus = value);
                                }
                              },
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _pickDate(isFrom: true),
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text('Dari: ${_formatDate(_fromDate)}'),
                          ),
                          TextButton.icon(
                            onPressed: () => _pickDate(isFrom: false),
                            icon: const Icon(Icons.calendar_today_outlined),
                            label: Text('Sampai: ${_formatDate(_toDate)}'),
                          ),
                          if (_selectedStatus != 'all' ||
                              _fromDate != null ||
                              _toDate != null)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStatus = 'all';
                                  _fromDate = null;
                                  _toDate = null;
                                });
                              },
                              child: const Text('Reset'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Pesanan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${filteredReports.length} hasil',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (filteredReports.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Tidak ada data yang sesuai dengan filter saat ini',
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredReports.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = filteredReports[index];
                    final status = (item['status'] ?? 'pending').toString();
                    final createdAt = item['createdAt'] as DateTime?;
                    final badgeColor = status.toLowerCase() == 'pending'
                        ? Colors.orange
                        : status.toLowerCase() == 'completed' ||
                              status.toLowerCase() == 'success'
                        ? Colors.green
                        : Colors.blue;

                    return Card(
                      child: InkWell(
                        onTap: () {
                          final orderId = item['id'] as String? ?? '';
                          if (orderId.isEmpty) return;
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SuperAdminOrderDetailScreen(orderId: orderId),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #${item['id']?.toString().substring(0, 6) ?? '---'}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item['items'] ?? '-',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      createdAt != null
                                          ? _formatDate(createdAt.toLocal())
                                          : '-',
                                      style: TextStyle(
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: badgeColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(
                                        color: badgeColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Rp${item['total']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
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
            ],
          );
        },
      ),
    );
  }
}
