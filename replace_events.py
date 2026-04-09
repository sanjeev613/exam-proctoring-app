import re

file_path = "c:\\Users\\sanje\\exam_proctoring_app\\lib\\screens\\proctoring_exam_screen.dart"
with open(file_path, "r", encoding="utf-8") as f:
    code = f.read()

new_methods = """
  IconData _eventIcon(String eventType, String title) {
    final t = eventType.toLowerCase();
    final ti = title.toLowerCase();
    if (t.contains('bluetooth') || ti.contains('bluetooth') || ti.contains('bt ')) {
      return Icons.bluetooth_searching;
    }
    if (t.contains('phone') || t.contains('mobile') || ti.contains('phone') || ti.contains('mobile')) {
      return Icons.smartphone;
    }
    if (t.contains('multi') || t.contains('person') || ti.contains('person')) {
      return Icons.people;
    }
    if (t.contains('tab') || t.contains('window') || ti.contains('tab') || ti.contains('shortcut')) {
      return Icons.tab;
    }
    if (t.contains('face') || t.contains('absent') || ti.contains('face')) {
      return Icons.face_retouching_off;
    }
    if (t.contains('gaze') || t.contains('looking') || ti.contains('looking')) {
      return Icons.visibility_off;
    }
    if (t.contains('camera') || ti.contains('camera')) {
      return Icons.videocam_off;
    }
    if (t.contains('speech') || ti.contains('speech') || ti.contains('voice')) {
      return Icons.mic;
    }
    if (t.contains('copy') || t.contains('paste') || ti.contains('copy')) {
      return Icons.content_paste_off;
    }
    if (t.contains('fullscreen') || ti.contains('fullscreen')) {
      return Icons.fullscreen_exit;
    }
    if (t.contains('lighting') || ti.contains('lighting') || ti.contains('light')) {
      return Icons.light_mode;
    }
    return Icons.warning_amber_rounded;
  }

  Widget _buildEventsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Malpractice Events', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (_bluetoothDetections > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D4ED8).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bluetooth_searching, size: 12, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 3),
                        Text('$_bluetoothDetections BT', style: const TextStyle(fontSize: 10, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (_events.isEmpty)
              const Expanded(child: Center(child: Text('No suspicious behavior detected yet.')))
            else
              Expanded(
                child: ListView.separated(
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final item = _events[index];
                    final color = _severityColor(item.severity);
                    final icon = _eventIcon(item.eventType, item.title);
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          margin: const EdgeInsets.only(top: 2, right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withOpacity(0.12),
                          ),
                          child: Icon(icon, size: 14, color: color),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                              Text(
                                '${item.source} | ${item.severity.toUpperCase()} | ${item.time.hour.toString().zfill(2)}:${item.time.minute.toString().zfill(2)}:${item.time.second.toString().zfill(2)}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF667085)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _startBluetoothScan() {
    try {
      final nav = js.context['navigator'];
      if (nav == null) return;
      final bt = nav['bluetooth'];
      if (bt == null) return;
    } catch (_) {
      return;
    }

    _doBluetoothScan();
    _bluetoothScanTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _doBluetoothScan(),
    );
  }

  Future<void> _doBluetoothScan() async {
    try {
      final bt = js.context['navigator']['bluetooth'];
      if (bt == null) return;

      final devicesFuture = bt.callMethod('getDevices', []) as Object;
      final devices = await html.promiseToFuture<dynamic>(devicesFuture);

      if (devices == null) return;

      final jsList = devices as js.JsArray;
      for (final device in jsList) {
        final jsDevice = device as js.JsObject;
        final name = (jsDevice['name'] ?? 'Unknown Device').toString();
        final nameLower = name.toLowerCase();

        final isSuspicious = [
          'iphone', 'samsung', 'galaxy', 'pixel', 'oneplus', 'redmi',
          'xiaomi', 'realme', 'oppo', 'vivo', 'motorola', 'huawei', 'android',
          'airpods', 'buds', 'earbuds', 'headset', 'watch',
        ].any((kw) => nameLower.contains(kw));

        if (isSuspicious) {
          if (mounted) setState(() => _bluetoothDetections++);
          _recordMalpractice(
            title: 'Bluetooth mobile device (' + name + ')',
            severity: 'high',
            source: 'Browser BT',
            backendEventType: 'bluetooth_device_detected',
            riskPoints: 15,
            eventType: 'bluetooth',
          );
        }
      }
    } catch (e) {
    }
  }
"""

# Replace existing _buildEventsCard
pattern = re.compile(r'  Widget _buildEventsCard\(\) \{.*?\n  \}', re.DOTALL)
code = pattern.sub(new_methods.strip('\n'), code)

# Note: The JS .zfill method in Dart is actually .padLeft(2, "0"). The python script has a bug in the Dart string interpolation string, I will fix it above.
code = code.replace(".zfill(2)", ".padLeft(2, '0')")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(code)

print("Replacement successful")
