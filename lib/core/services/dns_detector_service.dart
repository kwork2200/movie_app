import 'dart:async';
import 'dart:io';

/// Service to detect if DNS/VPN/Private DNS is enabled on the device
class DnsDetectorService {
  static final DnsDetectorService _instance = DnsDetectorService._internal();
  factory DnsDetectorService() => _instance;
  DnsDetectorService._internal();

  final StreamController<bool> _dnsStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get dnsStatusStream => _dnsStatusController.stream;
  bool _isDnsEnabled = false;
  Timer? _periodicCheckTimer;

  bool get isDnsEnabled => _isDnsEnabled;

  /// Initialize and start periodic DNS checks
  Future<void> initialize() async {
    await checkDnsStatus();
    _periodicCheckTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => checkDnsStatus(),
    );
  }

  /// Check if DNS/VPN is enabled
  Future<void> checkDnsStatus() async {
    try {
      bool dnsDetected = false;
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        final name = interface.name.toLowerCase();
        // Common VPN interface names
        if (name.contains('tun') || 
            name.contains('ppp') || 
            name.contains('ipsec') ||
            name.contains('vpn') ||
            name.contains('utun')) {
          dnsDetected = true;
          break;
        }
      }
      if (!dnsDetected) {
        try {
          final result = await InternetAddress.lookup('dns.google')
              .timeout(const Duration(seconds: 3));
          if (result.isNotEmpty) {
            final ip = result.first.address;
            if (ip != '8.8.8.8' && ip != '8.8.4.4') {
            }
          }
        } catch (e) {
        }
      }
      if (_isDnsEnabled != dnsDetected) {
        _isDnsEnabled = dnsDetected;
        _dnsStatusController.add(_isDnsEnabled);
        print('DNS/VPN status changed: ${_isDnsEnabled ? "Enabled" : "Disabled"}');
      }
    } catch (e) {
      print('Error checking DNS status: $e');
      if (_isDnsEnabled != false) {
        _isDnsEnabled = false;
        _dnsStatusController.add(_isDnsEnabled);
      }
    }
  }

  void dispose() {
    _periodicCheckTimer?.cancel();
    _dnsStatusController.close();
  }
}
