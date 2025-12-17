import 'package:hive/hive.dart';
import 'package:intl/intl.dart'; // Tarih formatı için

part 'ip_data.g.dart';

@HiveType(typeId: 0)
class IpData extends HiveObject {
  @HiveField(0) final String ip;
  @HiveField(1) final String country;
  @HiveField(2) final String city;
  @HiveField(3) final String isp;
  @HiveField(4) final double lat;
  @HiveField(5) final double lon;
  @HiveField(6) final List<String> openPorts;
  @HiveField(7) final int riskScore;
  @HiveField(8) final DateTime queryDate;
  @HiveField(9) final String originalQuery;
  @HiveField(10) final String org;
  @HiveField(11) final String timezone;
  @HiveField(12) final bool isMobile;
  @HiveField(13) final bool isProxy;
  @HiveField(14) final bool isHosting;
  @HiveField(15) final Map<String, String> httpHeaders;

  IpData({
    required this.ip,
    required this.country,
    required this.city,
    required this.isp,
    required this.lat,
    required this.lon,
    this.openPorts = const [],
    this.riskScore = 0,
    DateTime? queryDate,
    this.originalQuery = "",
    this.org = "",
    this.timezone = "",
    this.isMobile = false,
    this.isProxy = false,
    this.isHosting = false,
    this.httpHeaders = const {},
  }) : this.queryDate = queryDate ?? DateTime.now();

  factory IpData.fromJson(Map<String, dynamic> json, String query) {
    return IpData(
      ip: json['query'] ?? 'Bilinmiyor',
      originalQuery: query,
      country: json['country'] ?? 'Bilinmiyor',
      city: json['city'] ?? 'Bilinmiyor',
      isp: json['isp'] ?? 'Bilinmiyor',
      org: json['org'] ?? json['as'] ?? 'Bilinmiyor',
      timezone: json['timezone'] ?? 'UTC',
      lat: (json['lat'] ?? 0).toDouble(),
      lon: (json['lon'] ?? 0).toDouble(),
      isMobile: json['mobile'] ?? false,
      isProxy: json['proxy'] ?? false,
      isHosting: json['hosting'] ?? false,
    );
  }
  
  // Kopya Oluşturucu (State Management için)
  IpData copyWith({
    List<String>? openPorts, 
    int? riskScore,
    Map<String, String>? httpHeaders,
  }) {
    return IpData(
      ip: ip, country: country, city: city, isp: isp, lat: lat, lon: lon,
      openPorts: openPorts ?? this.openPorts,
      riskScore: riskScore ?? this.riskScore,
      queryDate: queryDate,
      originalQuery: originalQuery,
      org: org, timezone: timezone,
      isMobile: isMobile, isProxy: isProxy, isHosting: isHosting,
      httpHeaders: httpHeaders ?? this.httpHeaders,
    );
  }

  // Rapor Metni Oluşturucu
  String getFormattedReport() {
    return """
=== SİBER İSTİHBARAT RAPORU ===
Tarih: ${DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now())}
Hedef: $originalQuery ($ip)

[GENEL BİLGİLER]
• Ülke/Şehir: $country, $city
• ISP/Org: $isp / $org
• Zaman Dilimi: $timezone

[TEHDİT ANALİZİ]
• Risk Skoru: $riskScore/100
• Proxy/VPN: ${isProxy ? 'EVET' : 'HAYIR'}
• Hosting: ${isHosting ? 'EVET' : 'HAYIR'}

[AĞ TARAMASI]
• Açık Portlar: ${openPorts.isEmpty ? 'Tespit Edilemedi (Güvenli)' : openPorts.join(', ')}
${httpHeaders.isNotEmpty ? '\n[SUNUCU BİLGİSİ]\n• Server: ${httpHeaders['server'] ?? 'N/A'}\n• Tech: ${httpHeaders['x-powered-by'] ?? 'N/A'}' : ''}
===============================
""";
  }
}