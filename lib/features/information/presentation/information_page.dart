import 'package:flutter/material.dart';

import '../data/information_repository.dart';
import '../domain/information_item.dart';

class InformationPage extends StatefulWidget {
  const InformationPage({super.key});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  final InformationRepository _repository = InformationRepository();
  late Future<List<InformationItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _repository.getItems();
  }

  Future<void> _refresh() async {
    setState(() {
      _itemsFuture = _repository.getItems();
    });
    await _itemsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<InformationItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.error_outline,
              title: '信息暂时无法加载',
              detail: '请稍后重试。${snapshot.error}',
              action: _refresh,
            );
          }
          final items = snapshot.data ?? const <InformationItem>[];
          if (items.isEmpty) {
            return const _MessageState(
              icon: Icons.inbox_outlined,
              title: '暂无信息',
              detail: '内容包还没有发布条目。',
            );
          }
          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Text(
                '校内信息',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '常用服务与校园信息，内容随 App 版本更新。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 18),
              ...items.map((item) => _InformationCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.item});

  final InformationItem item;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: CircleAvatar(
          backgroundColor: colors.primaryContainer,
          foregroundColor: colors.onPrimaryContainer,
          child: const Icon(Icons.info_outline),
        ),
        title: Text(
          item.title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text('${item.category} · 更新于 ${_date(item.updatedAt)}'),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(item.body)),
          if (item.links.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...item.links.map(
              (link) => Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(link.label),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _date(DateTime value) =>
      '${value.year}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
  });

  final IconData icon;
  final String title;
  final String detail;
  final Future<void> Function()? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(detail, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(onPressed: action, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}
