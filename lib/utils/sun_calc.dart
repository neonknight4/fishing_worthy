import 'dart:math';

class SunCalc {
  static DateTime? sunriseTime(double lat, double lon, DateTime date) =>
      _calc(lat, lon, date, true);

  static DateTime? sunsetTime(double lat, double lon, DateTime date) =>
      _calc(lat, lon, date, false);

  static DateTime? _calc(double lat, double lon, DateTime date, bool isSunrise) {
    final jd = _toJulian(date);
    final n = jd - 2451545.0 + 0.0008;
    final jStar = n - lon / 360.0;
    final mRad = (357.5291 + 0.98560028 * jStar) % 360 * pi / 180;
    final c = 1.9148 * sin(mRad) + 0.02 * sin(2 * mRad) + 0.0003 * sin(3 * mRad);
    final lambdaRad = ((mRad * 180 / pi + c + 180 + 102.9372) % 360) * pi / 180;
    final jTransit = 2451545.0 + jStar +
        0.0053 * sin(mRad) -
        0.0069 * sin(2 * lambdaRad);
    final sinDec = sin(lambdaRad) * sin(23.4397 * pi / 180);
    final cosDec = cos(asin(sinDec));
    final cosH = (sin(-0.8333 * pi / 180) - sin(lat * pi / 180) * sinDec) /
        (cos(lat * pi / 180) * cosDec);
    if (cosH > 1 || cosH < -1) return null;
    final hDeg = acos(cosH) * 180 / pi;
    final jResult = isSunrise ? jTransit - hDeg / 360.0 : jTransit + hDeg / 360.0;
    return _fromJulian(jResult);
  }

  static double _toJulian(DateTime date) {
    final d = DateTime.utc(date.year, date.month, date.day);
    return d.millisecondsSinceEpoch / 86400000.0 + 2440587.5;
  }

  static DateTime _fromJulian(double jd) {
    final ms = ((jd - 2440587.5) * 86400000.0).round();
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true).toLocal();
  }
}
