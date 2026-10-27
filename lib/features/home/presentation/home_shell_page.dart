import 'package:flutter/material.dart';

import '../../information/presentation/information_page.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/presentation/schedule_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({super.key, this.scheduleRepository});

  final ScheduleRepository? scheduleRepository;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pageForIndex()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            key: Key('nav-schedule'),
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '课表',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            selectedIcon: Icon(Icons.notifications),
            label: '通知',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '校园卡',
          ),
          NavigationDestination(
            key: Key('nav-information'),
            icon: Icon(Icons.info_outline),
            selectedIcon: Icon(Icons.info),
            label: '信息',
          ),
        ],
      ),
    );
  }

  Widget _pageForIndex() {
    return switch (_selectedIndex) {
      0 => const _OverviewPage(),
      1 => SchedulePage(repository: widget.scheduleRepository),
      2 => const _ComingSoonPage(
        icon: Icons.notifications_none,
        title: '个人通知',
        detail: '接口接入后，这里会显示个人通知。',
      ),
      3 => const _ComingSoonPage(
        icon: Icons.account_balance_wallet_outlined,
        title: '校园卡',
        detail: '接口接入后，这里会显示余额；充值将单独设计。',
      ),
      _ => const InformationPage(),
    };
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          '日新工大',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '校园信息，一处查看',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        Card(
          color: colors.primary,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.waving_hand_outlined, color: colors.onPrimary),
                const SizedBox(height: 12),
                Text(
                  '欢迎回来',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '登录后即可同步你的课表、通知和校园卡信息。',
                  style: TextStyle(
                    color: colors.onPrimary.withValues(alpha: .82),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('快捷入口', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _QuickEntry(icon: Icons.calendar_month, label: '今日课表'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickEntry(icon: Icons.notifications_none, label: '个人通知'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Row(
          children: [
            Expanded(
              child: _QuickEntry(
                icon: Icons.account_balance_wallet_outlined,
                label: '校园卡余额',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _QuickEntry(icon: Icons.info_outline, label: '校内信息'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: Icon(Icons.construction_outlined, color: colors.secondary),
            title: const Text('基础壳已就绪'),
            subtitle: const Text('下一步接入真实数据源，先从接口取证开始。'),
          ),
        ),
      ],
    );
  }
}

class _QuickEntry extends StatelessWidget {
  const _QuickEntry({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(detail, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
