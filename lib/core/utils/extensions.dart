extension IntExt on int {
  String toLocaleString() {
    final s   = toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  String toMinSec() {
    final m = (this ~/ 60).toString().padLeft(2, '0');
    final s = (this %  60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String toHourMinSec() {
    final h = this ~/ 3600;
    final m = ((this % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (this % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

extension StringExt on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String toReadableGoal() => replaceAll('_', ' ').split(' ').map((w) => w.capitalize()).join(' ');
}

extension DoubleExt on double {
  String toCalString() => toStringAsFixed(0);
}

extension DateTimeExt on DateTime {
  String toDateKey() => '${year}-${month.toString().padLeft(2,'0')}-${day.toString().padLeft(2,'0')}';

  String toRelative() {
    final now  = DateTime.now();
    final diff = now.difference(this);
    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    return '${day.toString().padLeft(2,'0')}/${month.toString().padLeft(2,'0')}/$year';
  }
}