import 'package:flutter_test/flutter_test.dart';
import 'package:bjut_campus/features/pay/payment_model.dart';
import 'package:bjut_campus/features/pay/pay_app.dart';

class UncertainRecharge implements OfficialRechargeAdapter {
  int attempts = 0;
  @override
  Future<void> open(TopUp order) async {
    attempts++;
    throw StateError('unknown');
  }
}

void main() {
  late MockPaymentSource source;
  late MockRechargeAdapter adapter;
  late PaymentController controller;
  setUp(() {
    source = MockPaymentSource();
    adapter = MockRechargeAdapter();
    controller = PaymentController(source, adapter);
  });
  test('default target and no deficit', () async {
    await controller.refresh();
    expect(controller.targetCents, 5000);
    expect(controller.deficitCents, 0);
    expect(controller.order, isNull);
  });
  test('any deficit prepares exact amount without a threshold', () async {
    source.spend(1);
    await controller.refresh();
    expect(controller.order!.amountCents, 1);
    expect(controller.order!.status, TopUpStatus.awaitingConfirmation);
  });
  test('unsubmitted proposals coalesce; submitted ones remain fixed', () async {
    source.spend(1200);
    await controller.refresh();
    source.spend(500);
    await controller.refresh();
    expect(controller.order!.amountCents, 1700);
    await controller.confirm();
    final id = controller.order!.id;
    source.spend(500);
    await controller.refresh();
    expect(controller.order!.id, id);
    expect(controller.order!.amountCents, 1700);
  });
  test('repeated confirm does not duplicate payment', () async {
    source.spend(1200);
    await controller.refresh();
    await Future.wait([
      controller.confirm(),
      controller.confirm(),
      controller.confirm(),
    ]);
    expect(adapter.openCount, 1);
    controller.awaitCredit();
    await controller.confirm();
    expect(adapter.openCount, 1);
  });
  test('balance movement alone is not proof of order settlement', () async {
    source.spend(1200);
    await controller.refresh();
    await controller.confirm();
    controller.awaitCredit();
    source.balanceCents = 5000;
    await controller.refresh();
    expect(controller.order!.status, TopUpStatus.awaitingCredit);
  });
  test('credit idempotency and verified success', () async {
    source.spend(1200);
    await controller.refresh();
    await controller.confirm();
    controller.awaitCredit();
    source.credit(controller.order!);
    source.credit(controller.order!);
    await controller.refresh();
    expect(source.balanceCents, 5000);
    expect(controller.order!.status, TopUpStatus.succeeded);
  });
  test('launch uncertainty locks retries', () async {
    final uncertain = UncertainRecharge();
    final c = PaymentController(source, uncertain);
    source.spend(1200);
    await c.refresh();
    await c.confirm();
    await c.confirm();
    expect(uncertain.attempts, 1);
    expect(c.order!.status, TopUpStatus.awaitingCredit);
    await c.refresh();
    expect(c.order!.status, TopUpStatus.awaitingCredit);
  });
  test('target changes cannot replace unresolved payment', () async {
    source.spend(1200);
    await controller.refresh();
    await controller.confirm();
    final id = controller.order!.id;
    controller.setTarget(10000);
    expect(controller.order!.id, id);
    expect(controller.order!.amountCents, 1200);
  });
  test(
    'invalid targets rejected and above target gives zero deficit',
    () async {
      await controller.refresh();
      expect(() => controller.setTarget(-1), throwsArgumentError);
      expect(() => controller.setTarget(100001), throwsArgumentError);
      controller.setTarget(4000);
      expect(controller.deficitCents, 0);
    },
  );
  test('explicit demo cancellation and failure are distinct', () async {
    source.spend(1200);
    await controller.refresh();
    await controller.confirm();
    controller.mockTerminal(TopUpStatus.canceled);
    expect(controller.order!.status, TopUpStatus.canceled);
    await controller.refresh();
    await controller.confirm();
    controller.mockTerminal(TopUpStatus.failed);
    expect(controller.order!.status, TopUpStatus.failed);
  });
  testWidgets('home clearly disclaims payment capability and shows no QR', (
    tester,
  ) async {
    await tester.pumpWidget(const BjutPayApp());
    await tester.pumpAndSettle();
    expect(find.text('校园付款码尚未接入'), findsOneWidget);
    expect(find.text('离线 Mock 演示 · 不可用于消费'), findsOneWidget);
    await tester.tap(find.text('模拟消费 ¥12'));
    await tester.pumpAndSettle();
    expect(find.text('待确认补款'), findsOneWidget);
  });
}
