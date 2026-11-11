import 'package:flutter/material.dart';

import 'payment_model.dart';

String money(int cents) => '¥${(cents / 100).toStringAsFixed(2)}';

class BjutPayApp extends StatelessWidget {
  const BjutPayApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BJUT Pay · 离线演示',
    theme: ThemeData(
      colorSchemeSeed: const Color(0xff17685b),
      useMaterial3: true,
    ),
    home: const PayHome(),
  );
}

class PayHome extends StatefulWidget {
  const PayHome({super.key});
  @override
  State<PayHome> createState() => _PayHomeState();
}

class _PayHomeState extends State<PayHome> with WidgetsBindingObserver {
  final source = MockPaymentSource();
  late final controller = PaymentController(source, MockRechargeAdapter());
  final target = TextEditingController(text: '50');
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.refresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) controller.refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    target.dispose();
    super.dispose();
  }

  String statusLabel(TopUpStatus status) => switch (status) {
    TopUpStatus.awaitingConfirmation => '待确认补款',
    TopUpStatus.paying => '模拟支付中',
    TopUpStatus.awaitingCredit => '待入账 / 结果未明，禁止重复付款',
    TopUpStatus.succeeded => '已核验模拟入账',
    TopUpStatus.failed => '模拟支付失败',
    TopUpStatus.canceled => '已取消',
  };
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('BJUT Pay')),
    body: SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '离线 Mock 演示 · 不可用于消费',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(28),
                child: Column(
                  children: [
                    Icon(Icons.lock_outline, size: 64),
                    SizedBox(height: 12),
                    Text('校园付款码尚未接入', style: TextStyle(fontSize: 22)),
                    Text('等待验证官方签发与认证流程。此处不生成或展示模拟二维码。'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '模拟余额 ${controller.balanceCents == null ? '未读取' : money(controller.balanceCents!)}',
              style: const TextStyle(fontSize: 28),
            ),
            Text(
              '目标余额 ${money(controller.targetCents)} · 待补 ${money(controller.deficitCents)}',
            ),
            TextField(
              controller: target,
              decoration: const InputDecoration(labelText: '目标余额（元，0–1000）'),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            TextButton(
              onPressed: () {
                final input = target.text.trim();
                if (!RegExp(r'^\d{1,4}(\.\d{1,2})?$').hasMatch(input)) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('请输入最多两位小数的金额')));
                  return;
                }
                final parts = input.split('.');
                final cents =
                    int.parse(parts[0]) * 100 +
                    (parts.length == 2
                        ? int.parse(parts[1].padRight(2, '0'))
                        : 0);
                if (cents > 100000) return;
                controller.setTarget(cents);
              },
              child: const Text('保存目标余额'),
            ),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                  onPressed: controller.busy ? null : controller.refresh,
                  child: const Text('刷新余额 / 核验入账'),
                ),
                OutlinedButton(
                  onPressed: controller.busy || source.balanceCents < 1200
                      ? null
                      : () {
                          source.spend(1200);
                          controller.refresh();
                        },
                  child: const Text('模拟消费 ¥12'),
                ),
              ],
            ),
            if (controller.error != null)
              Text(
                controller.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (controller.order case final order?) ...[
              const Divider(),
              Text(
                statusLabel(order.status),
                style: const TextStyle(fontSize: 20),
              ),
              Text('本笔模拟补款 ${money(order.amountCents)}'),
              if (order.status == TopUpStatus.awaitingConfirmation)
                FilledButton(
                  onPressed: controller.busy ? null : controller.confirm,
                  child: const Text('进入模拟充值（无真实交易）'),
                ),
              if (order.status == TopUpStatus.paying) ...[
                const Text('真实接入时将在学校官方页面由用户确认付款。本 Demo 不打开未经确认的充值网址。'),
                TextButton(
                  onPressed: controller.awaitCredit,
                  child: const Text('模拟完成支付 / 结果不明确'),
                ),
                TextButton(
                  onPressed: () =>
                      controller.mockTerminal(TopUpStatus.canceled),
                  child: const Text('模拟取消支付'),
                ),
                TextButton(
                  onPressed: () => controller.mockTerminal(TopUpStatus.failed),
                  child: const Text('模拟明确失败'),
                ),
              ],
              if (order.status == TopUpStatus.awaitingCredit)
                FilledButton(
                  onPressed: () {
                    source.credit(order);
                    controller.refresh();
                  },
                  child: const Text('模拟到账并核验'),
                ),
            ],
            const SizedBox(height: 20),
            const Text(
              '说明：余额、消费与订单均为本次会话的内存模拟数据，退出后重置。不保存账号、密码、支付凭证。不支持真实支付或后台自动充值。',
            ),
          ],
        ),
      ),
    ),
  );
}
