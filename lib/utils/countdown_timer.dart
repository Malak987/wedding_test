import 'dart:async';
import 'package:flutter/foundation.dart';

class CountdownValue {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final bool finished;

  const CountdownValue({
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    this.finished = false,
  });
}

/// A minimal, allocation-light countdown ticker.
/// Exposes a [ValueNotifier] so only the countdown widgets rebuild
/// every second — never the full page.
class CountdownTimer {
  CountdownTimer(DateTime target) : _target = target {
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  final DateTime _target;
  late final Timer _timer;

  final ValueNotifier<CountdownValue> value =
      ValueNotifier<CountdownValue>(const CountdownValue());

  void _tick() {
    final now = DateTime.now();
    final diff = _target.difference(now);

    if (diff.isNegative) {
      value.value = const CountdownValue(finished: true);
      _timer.cancel();
      return;
    }

    value.value = CountdownValue(
      days: diff.inDays,
      hours: diff.inHours % 24,
      minutes: diff.inMinutes % 60,
      seconds: diff.inSeconds % 60,
    );
  }

  void dispose() {
    _timer.cancel();
    value.dispose();
  }
}
