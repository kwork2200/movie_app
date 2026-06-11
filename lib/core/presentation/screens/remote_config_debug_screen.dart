import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/remote_config_service.dart';
import '../../services/ad_service.dart';

/// Debug screen to test Remote Config real-time updates
class RemoteConfigDebugScreen extends StatefulWidget {
  const RemoteConfigDebugScreen({super.key});

  @override
  State<RemoteConfigDebugScreen> createState() => _RemoteConfigDebugScreenState();
}

class _RemoteConfigDebugScreenState extends State<RemoteConfigDebugScreen> {
  StreamSubscription? _configSubscription;
  bool _isFetching = false;
  String _lastUpdateTime = 'Never';
  
  // Current values
  bool _showBannerAds = false;
  bool _showNativeAds = false;
  bool _showInterstitialAds = false;
  int _interstitialFrequency = 0;

  @override
  void initState() {
    super.initState();
    _updateValues();
    
    // Listen to config updates
    _configSubscription = RemoteConfigService.instance.configUpdates.listen((_) {
      _onConfigUpdated();
    });
  }

  void _updateValues() {
    setState(() {
      _showBannerAds = AdService.instance.shouldShowBannerAds;
      _showNativeAds = AdService.instance.shouldShowNativeAds;
      _showInterstitialAds = AdService.instance.shouldShowInterstitialAds;
      _interstitialFrequency = AdService.instance.interstitialAdFrequency;
    });
  }

  void _onConfigUpdated() {
    setState(() {
      _lastUpdateTime = DateTime.now().toString().substring(11, 19);
    });
    _updateValues();
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Remote Config Updated!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _manualFetch() async {
    setState(() {
      _isFetching = true;
    });

    final updated = await RemoteConfigService.instance.fetchAndActivate();

    setState(() {
      _isFetching = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(updated ? '✅ Config Updated!' : 'ℹ️ Already up-to-date'),
          duration: const Duration(seconds: 2),
          backgroundColor: updated ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _configSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remote Config Debug'),
        actions: [
          if (_isFetching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _manualFetch,
              tooltip: 'Fetch Now',
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    icon: Icons.update,
                    label: 'Last Update',
                    value: _lastUpdateTime,
                    color: Colors.blue,
                  ),
                  const Divider(height: 24),
                  const Text(
                    '💡 Tip: Change values in Firebase Console and see them update here in real-time!',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Ad Visibility Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ad Visibility',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildToggleRow(
                    icon: Icons.ad_units,
                    label: 'Banner Ads',
                    value: _showBannerAds,
                  ),
                  const Divider(height: 24),
                  _buildToggleRow(
                    icon: Icons.dynamic_feed,
                    label: 'Native Ads',
                    value: _showNativeAds,
                  ),
                  const Divider(height: 24),
                  _buildToggleRow(
                    icon: Icons.fullscreen,
                    label: 'Interstitial Ads',
                    value: _showInterstitialAds,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusRow(
                    icon: Icons.repeat,
                    label: 'Interstitial Frequency',
                    value: 'Every $_interstitialFrequency screens',
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Manual Fetch Button
          ElevatedButton.icon(
            onPressed: _isFetching ? null : _manualFetch,
            icon: _isFetching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_download),
            label: Text(_isFetching ? 'Fetching...' : 'Fetch Config Now'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Instructions
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'How to Test',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Keep this screen open\n'
                    '2. Go to Firebase Console → Remote Config\n'
                    '3. Change any ad setting (e.g., show_banner_ads)\n'
                    '4. Click "Publish changes"\n'
                    '5. Watch this screen update automatically!\n'
                    '\n'
                    'Updates happen via:\n'
                    '• Real-time listener (instant)\n'
                    '• Periodic fetch (every 30 seconds)\n'
                    '• Manual fetch (tap refresh button)',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String label,
    required bool value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: value ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value ? 'Enabled' : 'Disabled',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
