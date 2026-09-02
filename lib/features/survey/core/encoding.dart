import 'dart:convert';

class RangeSelection {
  final num min;
  final num max;
  const RangeSelection(this.min, this.max);

  static RangeSelection? parse(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      final j = jsonDecode(v) as Map<String, dynamic>;
      final mn = j['min'] as num?;
      final mx = j['max'] as num?;
      if (mn == null || mx == null) return null;
      return RangeSelection(mn, mx);
    } catch (_) {
      return null;
    }
  }

  String serialize() => jsonEncode({'min': min, 'max': max});
}

class LocationValue {
  final double lat;
  final double lng;
  const LocationValue(this.lat, this.lng);

  static LocationValue? parse(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    try {
      final j = jsonDecode(v) as Map<String, dynamic>;
      final lat = (j['lat'] as num?)?.toDouble();
      final lng = (j['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) return null;
      if (lat < -90 || lat > 90 || lng < -180 || lng > 180) return null;
      return LocationValue(lat, lng);
    } catch (_) {
      return null;
    }
  }

  String serialize() => jsonEncode({
        'lat': double.parse(lat.toStringAsFixed(6)),
        'lng': double.parse(lng.toStringAsFixed(6)),
      });
}

double snapToStep(double value, double min, double step) {
  if (step <= 0) return value;
  final snapped = min + ((value - min) / step + 1e-9).round() * step;
  final decimals = step.toString().split('.').length > 1
      ? step.toString().split('.')[1].length
      : 0;
  return double.parse(snapped.toStringAsFixed(decimals > 2 ? decimals : 2));
}

List<String> parseMulti(String? v) =>
    (v == null || v.isEmpty) ? [] : v.split(',').where((s) => s.isNotEmpty).toList();

List<String> parseFileUrls(String v) {
  if (v.isEmpty) return [];
  try {
    final j = jsonDecode(v);
    if (j is List) return j.whereType<String>().toList();
    return [j.toString()];
  } catch (_) {
    return [v];
  }
}

String fmtAdDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
