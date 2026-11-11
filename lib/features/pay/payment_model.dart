import 'package:flutter/foundation.dart';

enum TopUpStatus {
  awaitingConfirmation,
  paying,
  awaitingCredit,
  succeeded,
  failed,
  canceled,
}

class TopUp {
  TopUp(this.id, this.amountCents);
  final String id;
  final int amountCents;
  TopUpStatus status = TopUpStatus.awaitingConfirmation;
  bool get unresolved =>
      status == TopUpStatus.awaitingConfirmation ||
      status == TopUpStatus.paying ||
      status == TopUpStatus.awaitingCredit;
}

/// No payment tokens or card identifiers are persisted by this demo.
abstract interface class CampusPaymentSource {
  Future<int> readBalanceCents();
  Future<bool> isTopUpCredited(String id);
}

abstract interface class OfficialRechargeAdapter {
  /// Implement only after the official URL, authentication and amount support
  /// are established. Opening a page is NOT proof of successful payment.
  Future<void> open(TopUp order);
}

class MockPaymentSource implements CampusPaymentSource {
  int balanceCents = 5000;
  final Set<String> _credited = {};
  @override
  Future<int> readBalanceCents() async => balanceCents;
  @override
  Future<bool> isTopUpCredited(String id) async => _credited.contains(id);
  void spend(int cents) {
    if (cents <= 0 || cents > balanceCents) {
      throw ArgumentError('Invalid mock spend');
    }
    balanceCents -= cents;
  }

  void credit(TopUp order) {
    if (_credited.add(order.id)) balanceCents += order.amountCents;
  }
}

class MockRechargeAdapter implements OfficialRechargeAdapter {
  int openCount = 0;
  @override
  Future<void> open(TopUp order) async {
    openCount++;
  }
}

class PaymentController extends ChangeNotifier {
  PaymentController(this.source, this.recharge);
  final CampusPaymentSource source;
  final OfficialRechargeAdapter recharge;
  int targetCents = 5000;
  int? balanceCents;
  TopUp? order;
  bool busy = false;
  String? error;
  int _sequence = 0;
  bool _disposed = false;
  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  int get deficitCents => balanceCents == null
      ? 0
      : (targetCents - balanceCents!).clamp(0, targetCents);

  void setTarget(int cents) {
    if (cents < 0 || cents > 100000) {
      throw ArgumentError('Target must be 0–1000 yuan');
    }
    targetCents = cents;
    _prepare();
    notifyListeners();
  }

  void _prepare() {
    final current = order;
    if (current != null &&
        current.unresolved &&
        current.status != TopUpStatus.awaitingConfirmation) {
      return;
    }
    if (deficitCents == 0) {
      if (current?.status == TopUpStatus.awaitingConfirmation) {
        current!.status = TopUpStatus.canceled;
      }
      return;
    }
    if (current?.status == TopUpStatus.awaitingConfirmation &&
        current?.amountCents == deficitCents) {
      return;
    }
    // Only a local, unsubmitted proposal can be replaced/coalesced.
    order = TopUp('mock-${++_sequence}', deficitCents);
  }

  Future<void> refresh() async {
    if (busy) return;
    busy = true;
    error = null;
    notifyListeners();
    try {
      final balance = await source.readBalanceCents();
      if (balance < 0) throw StateError('Invalid balance');
      balanceCents = balance;
      final current = order;
      if (current != null &&
          (current.status == TopUpStatus.awaitingCredit ||
              current.status == TopUpStatus.paying)) {
        if (await source.isTopUpCredited(current.id)) {
          current.status = TopUpStatus.succeeded;
        }
      }
      _prepare();
    } catch (_) {
      error = '余额或入账核验失败，请稍后刷新；不会自动重试付款。';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> confirm() async {
    final current = order;
    if (busy ||
        error != null ||
        current == null ||
        current.status != TopUpStatus.awaitingConfirmation) {
      return;
    }
    current.status = TopUpStatus.paying;
    notifyListeners();
    try {
      await recharge.open(current);
    } catch (_) {
      // A launch error may happen after a payment page opened. Do not retry.
      current.status = TopUpStatus.awaitingCredit;
      error = '打开充值入口的结果不明确，等待核验，禁止重复提交。';
      notifyListeners();
    }
  }

  void awaitCredit() {
    if (order?.status != TopUpStatus.paying) return;
    order!.status = TopUpStatus.awaitingCredit;
    notifyListeners();
  }

  /// Demo controls only. A real integration needs authoritative order status.
  void mockTerminal(TopUpStatus status) {
    if (source is! MockPaymentSource ||
        order == null ||
        order!.status != TopUpStatus.paying ||
        (status != TopUpStatus.failed && status != TopUpStatus.canceled)) {
      return;
    }
    order!.status = status;
    notifyListeners();
  }
}
