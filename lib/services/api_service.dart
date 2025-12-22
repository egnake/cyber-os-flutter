import 'dart:io';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../models/ip_data.dart';

class ApiService {
  final Dio _dio = Dio();

  // analiz
  Future<IpData?> fetchIpInfo(String input) async {
    try {
      String targetIp = input;
      String userQuery = input;

      // DNS Çözümleme
      try {
        if (InternetAddress.tryParse(input) == null) {
          final List<InternetAddress> result = await InternetAddress.lookup(input);
          if (result.isNotEmpty) targetIp = result[0].address;
        }
      } catch (e) { /* DNS Hatası */ }

      // IP-API
      final responseGeo = await _dio.get('http://ip-api.com/json/$targetIp?fields=66846719');
      if (responseGeo.data['status'] == 'fail') throw Exception("Hedef Bulunamadı");

      IpData data = IpData.fromJson(responseGeo.data, userQuery);

      // Header Sniffing
      Map<String, String> grabbedHeaders = {};
      try {
        String url = input.startsWith("http") ? input : "http://$input";
        final headResponse = await Dio(BaseOptions(connectTimeout: const Duration(seconds: 3))).head(url);
        headResponse.headers.forEach((name, values) {
          grabbedHeaders[name.toLowerCase()] = values.join(', ');
        });
        data = data.copyWith(httpHeaders: grabbedHeaders);
      } catch (e) { }

      // Shodan
      try {
        final responseShodan = await _dio.get('https://internetdb.shodan.io/$targetIp');
        List<String> ports = (responseShodan.data['ports'] as List).map((e) => e.toString()).toList();
        data = data.copyWith(openPorts: ports);
        
        int score = 0;
        if (['CN', 'RU', 'KP', 'IR'].contains(data.country)) score += 20;
        if (data.isProxy) score += 35;
        if (data.isHosting) score += 15;
        if (ports.contains('22')) score += 10;
        if (ports.contains('3389')) score += 25;
        if (grabbedHeaders.isNotEmpty) score += 5;
        data = data.copyWith(riskScore: score > 100 ? 100 : score);
      } catch (e) { }
      
      await _saveToHistory(data);
      return data;
    } catch (e) {
      throw Exception('Analiz Başarısız: $e');
    }
  }

  // ui

  Future<String> fetchWhois(String domain) async {
    try {
      if (InternetAddress.tryParse(domain) != null) return "IP için desteklenmiyor.";
      final response = await _dio.get('https://rdap.org/domain/$domain');
      var data = response.data;
      String output = "";
      if(data['events'] != null) for(var e in data['events']) output += "• ${e['eventAction'].toString().toUpperCase()}: ${e['eventDate']}\n";
      if(data['entities'] != null && (data['entities'] as List).isNotEmpty) output += "\n[KAYITÇI]\n${data['entities'][0]['handle'] ?? 'Gizli'}";
      return output.isEmpty ? "Veri Gizli" : output;
    } catch (e) { return "Hata: Geçersiz Domain"; }
  }

  Future<List<String>> fetchDnsRecords(String domain) async {
    try {
      List<String> records = [];
      final types = {'A': 1, 'MX': 15, 'TXT': 16, 'NS': 2};
      for(var entry in types.entries) {
        try {
          final response = await _dio.get('https://cloudflare-dns.com/dns-query?name=$domain&type=${entry.value}', options: Options(headers: {'accept': 'application/dns-json'}));
          if(response.data['Answer'] != null) {
            for(var item in response.data['Answer']) records.add("[${entry.key}] -> ${item['data']}");
          }
        } catch (e) { continue; }
      }
      return records.isEmpty ? ["Kayıt bulunamadı"] : records;
    } catch (e) { return ["Hata"]; }
  }

  Future<List<String>> fetchSubdomains(String domain) async {
    try {
      final response = await _dio.get('https://crt.sh/?q=%25.$domain&output=json');
      if (response.statusCode == 200) {
        Set<String> subs = {};
        for (var item in (response.data as List)) subs.add(item['name_value']);
        return subs.take(20).toList();
      }
      return ["Sonuç yok"];
    } catch (e) { return ["API Limiti"]; }
  }

  Future<String> fetchMacVendor(String mac) async {
    try {
      final response = await _dio.get('https://api.macvendors.com/$mac');
      return response.data;
    } catch (e) { return "Bulunamadı"; }
  }

  Future<String> getMyIp() async {
    try {
      final response = await _dio.get('https://api.ipify.org?format=json');
      return response.data['ip'];
    } catch (e) { return "Bağlantı Hatası"; }
  }

  // tcpsocket
  Future<String> pingHost(String target) async {
    try {
     
      String host = target.replaceAll("https://", "").replaceAll("http://", "").split("/")[0];
      
      final stopwatch = Stopwatch()..start();
      // Gerçek bir TCP bağlantısı kurmayı dener (Port 443 veya 80)
      // Bu yöntem HTTP 403/401 hatalarına takılmaz, sunucu oradaysa cevap verir.
      Socket socket = await Socket.connect(host, 443, timeout: const Duration(seconds: 3));
      socket.destroy();
      stopwatch.stop();
      
      return "${stopwatch.elapsedMilliseconds} ms";
    } catch (e) {
      // 443 kapalıysa 80 dene
      try {
        String host = target.replaceAll("https://", "").replaceAll("http://", "").split("/")[0];
        final stopwatch = Stopwatch()..start();
        Socket socket = await Socket.connect(host, 80, timeout: const Duration(seconds: 3));
        socket.destroy();
        stopwatch.stop();
        return "${stopwatch.elapsedMilliseconds} ms";
      } catch(e2) {
        return "Offline / Timeout";
      }
    }
  }

  Future<void> _saveToHistory(IpData data) async {
    if (!Hive.isBoxOpen('history')) await Hive.openBox<IpData>('history');
    var box = Hive.box<IpData>('history');
    await box.put(data.ip, data);
  }
}
