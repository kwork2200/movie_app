import 'package:flutter/material.dart';
import '../../services/network_service.dart';
import '../../services/dns_detector_service.dart';
import '../screens/no_internet_screen.dart';
import '../screens/dns_blocked_screen.dart';

class NetworkAwareWidget extends StatefulWidget {
  final Widget child;

  const NetworkAwareWidget({
    super.key,
    required this.child,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  final NetworkService _networkService = NetworkService();
  final DnsDetectorService _dnsService = DnsDetectorService();
  bool _isConnected = true;
  bool _isDnsEnabled = false;

  @override
  void initState() {
    super.initState();
    _isConnected = _networkService.isConnected;
    _isDnsEnabled = _dnsService.isDnsEnabled;
    
    // Listen to network changes
    _networkService.connectionStream.listen((isConnected) {
      if (mounted) {
        setState(() {
          _isConnected = isConnected;
        });
      }
    });

    // Listen to DNS status changes
    _dnsService.dnsStatusStream.listen((isDnsEnabled) {
      if (mounted) {
        setState(() {
          _isDnsEnabled = isDnsEnabled;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Priority: First check DNS, then check internet
    if (_isDnsEnabled) {
      return const DnsBlockedScreen();
    } else if (!_isConnected) {
      return const NoInternetScreen();
    } else {
      return widget.child;
    }
  }
}
