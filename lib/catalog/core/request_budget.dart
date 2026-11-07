// Limits of the requests to Open Food Facts (BR2.3, scalability-design.md):
// a sliding window of 60 seconds with at most 8 searches and 60 product
// reads, below the limits Open Food Facts publishes per IP. Answers from the
// cache never count. The budget lives in memory and restarts with the app.

import 'dart:collection';

import '../../core/clock.dart';

/// Kind of an Open Food Facts request.
enum OffRequestKind { search, product }

/// Sliding-window budget of the requests, on the injected clock.
class RequestBudget {
  RequestBudget(this._clock);

  static const Duration window = Duration(seconds: 60);
  static const int maxSearches = 8;
  static const int maxProducts = 60;

  final Clock _clock;
  final Queue<DateTime> _searches = Queue();
  final Queue<DateTime> _products = Queue();

  /// Takes one request of [kind] from the budget; false (and nothing taken)
  /// when the window is full: the request must not start.
  bool tryAcquire(OffRequestKind kind) {
    final now = _clock.now();
    final (queue, limit) = switch (kind) {
      OffRequestKind.search => (_searches, maxSearches),
      OffRequestKind.product => (_products, maxProducts),
    };
    while (queue.isNotEmpty && now.difference(queue.first) >= window) {
      queue.removeFirst();
    }
    if (queue.length >= limit) return false;
    queue.addLast(now);
    return true;
  }
}
