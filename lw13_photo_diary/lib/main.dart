import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const NarxozMultimediaApp());
}

String _two(int n) => n.toString().padLeft(2, '0');

String formatTimestamp(DateTime t) =>
    '${t.year}-${_two(t.month)}-${_two(t.day)} ${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';

String formatCoordinates(double lat, double lon) =>
    '${lat.abs().toStringAsFixed(4)}° ${lat >= 0 ? 'N' : 'S'}, '
    '${lon.abs().toStringAsFixed(4)}° ${lon >= 0 ? 'E' : 'W'}';

class DiaryEntry {
  final String id;
  final String? imagePath;
  final String caption;
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime timestamp;

  const DiaryEntry({
    required this.id,
    this.imagePath,
    required this.caption,
    this.latitude,
    this.longitude,
    this.accuracy,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'caption': caption,
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory DiaryEntry.fromJson(Map<String, dynamic> json) => DiaryEntry(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String?,
        caption: json['caption'] as String? ?? 'Untitled Moment',
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
        accuracy: (json['accuracy'] as num?)?.toDouble(),
        timestamp: json['timestamp'] != null
            ? DateTime.parse(json['timestamp'] as String)
            : DateTime.now(),
      );
}

class NarxozMultimediaApp extends StatelessWidget {
  const NarxozMultimediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Narxoz Geotagged Diary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF02569B)),
      ),
      home: const GeotaggedDiaryScreen(),
    );
  }
}

class GeotaggedDiaryScreen extends StatefulWidget {
  const GeotaggedDiaryScreen({super.key});

  @override
  State<GeotaggedDiaryScreen> createState() => _GeotaggedDiaryScreenState();
}

class _GeotaggedDiaryScreenState extends State<GeotaggedDiaryScreen> {
  static const String _storageKey = 'narxoz_diary_entries';

  final ImagePicker _picker = ImagePicker();
  final TextEditingController _captionController = TextEditingController();

  String? _imagePath; // path of the currently selected photo
  Position? _currentPosition;
  DateTime? _gpsTimestamp;
  bool _isLoadingGps = false;
  bool _isLoadingStorage = true;
  String _gpsStatusMessage = 'GPS coordinates not acquired yet';

  final List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntriesFromStorage();
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }


  Future<void> _loadEntriesFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rawJson = prefs.getString(_storageKey);
      if (rawJson != null) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        _entries
          ..clear()
          ..addAll(decoded
              .map((e) => DiaryEntry.fromJson(e as Map<String, dynamic>)));
      }
    } catch (e) {
      debugPrint('Error loading saved entries: $e');
    }
    if (mounted) setState(() => _isLoadingStorage = false);
  }

  Future<void> _saveEntriesToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(_entries.map((e) => e.toJson()).toList()),
      );
    } catch (e) {
      debugPrint('Error saving entries: $e');
    }
  }

  Future<void> _deleteEntry(String id) async {
    setState(() => _entries.removeWhere((e) => e.id == id));
    await _saveEntriesToStorage();
    _showSnack('🗑️ Entry deleted.');
  }

  void _showSnack(String text, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<bool> _ensureCameraPermission() async {
    // permission_handler is only needed on real mobile devices
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return true;

    PermissionStatus status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      if (mounted) {
        _showSettingsDialog(
          title: 'Camera Permission Required',
          message:
              'Camera access was permanently denied. Open app settings and allow Camera manually.',
          onOpenSettings: () => openAppSettings(),
        );
      }
    } else {
      _showSnack('📷 Camera permission denied.', color: Colors.orange.shade800);
    }
    return false;
  }

  void _showSettingsDialog({
    required String title,
    required String message,
    required VoidCallback onOpenSettings,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              onOpenSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }


  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera && !await _ensureCameraPermission()) {
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 80, 
        maxWidth: 1080,
      );

      if (picked == null) return;

      setState(() => _imagePath = picked.path);
      _showSnack(
        source == ImageSource.camera
            ? '📸 Photo captured successfully!'
            : '🖼️ Image loaded from gallery!',
        color: Colors.green.shade700,
      );

      _fetchGpsLocation();
    } catch (e) {
      _showSnack(
        source == ImageSource.camera
            ? '📷 Camera not available on this device. Try Gallery.'
            : '❌ Error selecting image: $e',
        color: Colors.orange.shade800,
      );
    }
  }

  void _showSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo (Camera)'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

 
  Future<void> _fetchGpsLocation() async {
    if (_isLoadingGps) return;
    setState(() {
      _isLoadingGps = true;
      _gpsStatusMessage = 'Connecting to GPS satellites...';
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingGps = false;
          _gpsStatusMessage = 'Location services are disabled.';
        });
        _showSettingsDialog(
          title: 'Location Services Disabled',
          message: 'Please enable GPS in device settings to geotag photos.',
          onOpenSettings: () => Geolocator.openLocationSettings(),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingGps = false;
            _gpsStatusMessage = 'Location permission was denied.';
          });
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingGps = false;
          _gpsStatusMessage = 'Location permission permanently denied.';
        });
        _showSettingsDialog(
          title: 'Permission Permanently Denied',
          message:
              'Open app settings and allow Location manually to tag photos.',
          onOpenSettings: () => Geolocator.openAppSettings(),
        );
        return;
      }

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 15),
          ),
        );
      } catch (_) {
        final last = kIsWeb ? null : await Geolocator.getLastKnownPosition();
        if (last == null) rethrow;
        position = last;
      }

      setState(() {
        _currentPosition = position;
        _gpsTimestamp = DateTime.now();
        _isLoadingGps = false;
        _gpsStatusMessage = 'GPS fix acquired';
      });
    } catch (e) {
      setState(() {
        _isLoadingGps = false;
        _gpsStatusMessage = 'GPS error: could not get position ($e)';
      });
    }
  }


  Future<void> _saveEntry() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _imagePath == null) {
      _showSnack('Please select a photo or enter a caption first.');
      return;
    }

    String? permanentPath = _imagePath;
    if (_imagePath != null && !kIsWeb) {
      try {
        final docsDir = await getApplicationDocumentsDirectory();
        final ext = _imagePath!.contains('.')
            ? _imagePath!.substring(_imagePath!.lastIndexOf('.'))
            : '.jpg';
        final copy = File(
            '${docsDir.path}/diary_${DateTime.now().millisecondsSinceEpoch}$ext');
        await File(_imagePath!).copy(copy.path);
        permanentPath = copy.path;
      } catch (e) {
        debugPrint('Could not copy image: $e');
      }
    }

    final entry = DiaryEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: permanentPath,
      caption: caption.isEmpty ? 'Untitled Moment' : caption,
      latitude: _currentPosition?.latitude,
      longitude: _currentPosition?.longitude,
      accuracy: _currentPosition?.accuracy,
      timestamp: _gpsTimestamp ?? DateTime.now(),
    );

    setState(() {
      _entries.insert(0, entry);
      _imagePath = null;
      _currentPosition = null;
      _gpsTimestamp = null;
      _captionController.clear();
      _gpsStatusMessage = 'GPS coordinates not acquired yet';
    });

    await _saveEntriesToStorage();
    _showSnack('💾 Entry saved to diary!', color: Colors.blue.shade800);
  }

 
  Widget _photo(String path, {double? width, double? height}) {
    final fallback = Container(
      color: Colors.grey.shade200,
      child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
    );
    if (kIsWeb) {
      return Image.network(path,
          fit: BoxFit.cover,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => fallback);
    }
    return Image.file(File(path),
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => fallback);
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF02569B)),
          const SizedBox(width: 8),
          Text('$label ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildGpsCard() {
    final pos = _currentPosition;
    return Card(
      elevation: 0,
      color: Colors.blue.shade50.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pos != null) ...[
              _infoRow(Icons.location_on, 'Latitude:',
                  pos.latitude.toStringAsFixed(6)),
              _infoRow(Icons.location_on, 'Longitude:',
                  pos.longitude.toStringAsFixed(6)),
              _infoRow(Icons.height, 'Altitude:',
                  '${pos.altitude.toStringAsFixed(1)} m'),
              _infoRow(Icons.gps_fixed, 'Accuracy:',
                  '± ${pos.accuracy.toStringAsFixed(1)} m'),
              _infoRow(Icons.access_time, 'Timestamp:',
                  formatTimestamp(_gpsTimestamp ?? DateTime.now())),
            ] else
              Row(
                children: [
                  const Icon(Icons.location_off, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _gpsStatusMessage,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoadingGps ? null : _fetchGpsLocation,
                icon: _isLoadingGps
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(_isLoadingGps
                    ? 'Locking satellites...'
                    : 'Fetch Current GPS Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF02569B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(DiaryEntry entry) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 75,
                height: 75,
                child: entry.imagePath != null
                    ? _photo(entry.imagePath!, width: 75, height: 75)
                    : Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported,
                            color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.caption,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  if (entry.latitude != null && entry.longitude != null)
                    Row(
                      children: [
                        const Icon(Icons.place,
                            size: 14, color: Colors.redAccent),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            formatCoordinates(entry.latitude!, entry.longitude!),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(formatTimestamp(entry.timestamp),
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 20),
              tooltip: 'Delete entry',
              onPressed: () => _deleteEntry(entry.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.photo_camera_back_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Narxoz Photo Journal',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF02569B),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _imagePath != null
                    ? _photo(_imagePath!, width: double.infinity)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_outlined,
                              size: 56, color: Colors.grey.shade500),
                          const SizedBox(height: 8),
                          Text('No photo captured yet',
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text('Tap Take Photo or Pick Gallery below',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 12)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02569B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Pick Gallery'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _showSourceSheet,
                icon: const Icon(Icons.more_horiz, size: 18),
                label: const Text('Choose source'),
              ),
            ),
            const SizedBox(height: 4),

            _buildGpsCard(),
            const SizedBox(height: 16),

            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption',
                hintText: 'e.g. Campus Quad at Narxoz',
                prefixIcon: const Icon(Icons.edit_note),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            FilledButton.icon(
              onPressed: _saveEntry,
              icon: const Icon(Icons.save_rounded),
              label: const Text('SAVE ENTRY TO DIARY',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF01B569),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📜 Diary Entries',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${_entries.length} entries',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const Divider(height: 20),
            if (_isLoadingStorage)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text('No entries yet. Take a photo and press Save!',
                      style: TextStyle(color: Colors.grey.shade500)),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) => _buildEntryCard(_entries[index]),
              ),
          ],
        ),
      ),
    );
  }
}
