import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/ip_data.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final ipDataProvider = FutureProvider.family<IpData?, String>((ref, ip) async {
  final service = ref.watch(apiServiceProvider);
  if (ip.isEmpty) return null;
  return service.fetchIpInfo(ip);
});