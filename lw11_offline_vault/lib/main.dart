import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Ключи хранилища (SharedPreferences)
const String kDarkModeKey = 'app_theme_dark_mode';
const String kUserNameKey = 'user_display_name';
const String kNotesKey = 'saved_notes';

// ============================================================================
// 0. ТОЧКА ВХОДА: ПРЕДЗАГРУЗКА НАСТРОЕК ДО runApp() (без мерцания темы)
// ============================================================================
Future<void> main() async {
  // Нужно, чтобы вызывать платформенные плагины до runApp()
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  // ?? false: при первом запуске ключа ещё нет, getBool вернёт null
  final isDark = prefs.getBool(kDarkModeKey) ?? false;

  runApp(OfflineVaultApp(prefs: prefs, initialDark: isDark));
}

class OfflineVaultApp extends StatefulWidget {
  final SharedPreferences prefs;
  final bool initialDark;

  const OfflineVaultApp({
    super.key,
    required this.prefs,
    required this.initialDark,
  });

  @override
  State<OfflineVaultApp> createState() => _OfflineVaultAppState();
}

class _OfflineVaultAppState extends State<OfflineVaultApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    // Тема уже известна к первому кадру, поэтому экран не "моргает" белым
    _isDark = widget.initialDark;
  }

  Future<void> _setDark(bool value) async {
    setState(() => _isDark = value);
    await widget.prefs.setBool(kDarkModeKey, value);
  }

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF02569B);

    return MaterialApp(
      title: 'Offline Notes & Settings Vault',
      debugShowCheckedModeBanner: false,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      home: VaultScreen(
        prefs: widget.prefs,
        isDark: _isDark,
        onThemeChanged: _setDark,
      ),
    );
  }
}

// ============================================================================
// 1. МОДЕЛЬ ЗАМЕТКИ + JSON СЕРИАЛИЗАЦИЯ
// ============================================================================
class NoteItem {
  final String id;
  final String title;
  final String dateText;
  final bool isCompleted;

  const NoteItem({
    required this.id,
    required this.title,
    required this.dateText,
    required this.isCompleted,
  });

  // Model -> Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'dateText': dateText,
        'isCompleted': isCompleted,
      };

  // Map -> Model (с безопасными значениями по умолчанию)
  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      id: json['id'] as String? ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Untitled',
      dateText: json['dateText'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  NoteItem copyWith({bool? isCompleted}) {
    return NoteItem(
      id: id,
      title: title,
      dateText: dateText,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

// ============================================================================
// 2. ЕДИНСТВЕННЫЙ ЭКРАН: ПРОФИЛЬ + ТЕМА + ЗАМЕТКИ
// ============================================================================
class VaultScreen extends StatefulWidget {
  final SharedPreferences prefs;
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const VaultScreen({
    super.key,
    required this.prefs,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _displayName = 'Guest User';
  List<NoteItem> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadFromDisk();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // ЧТЕНИЕ С ДИСКА (при запуске приложения)
  // ==========================================================================
  void _loadFromDisk() {
    final prefs = widget.prefs;

    // Имя пользователя с fallback
    final savedName = prefs.getString(kUserNameKey);
    _displayName = (savedName == null || savedName.trim().isEmpty)
        ? 'Guest User'
        : savedName;
    _nameController.text = savedName ?? '';

    // Заметки: JSON-строка -> List<NoteItem>
    final rawJson = prefs.getString(kNotesKey);
    if (rawJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson);
        _notes = decoded
            .map((item) => NoteItem.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        // Повреждённый JSON не должен ронять приложение
        _notes = [];
      }
    }
  }

  // ==========================================================================
  // ЗАПИСЬ НА ДИСК
  // ==========================================================================
  Future<void> _saveNotes() async {
    final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await widget.prefs.setString(kNotesKey, jsonString);
  }

  Future<void> _saveUsername() async {
    final name = _nameController.text.trim();
    FocusScope.of(context).unfocus();

    if (name.isEmpty) {
      await widget.prefs.remove(kUserNameKey);
    } else {
      await widget.prefs.setString(kUserNameKey, name);
    }

    if (!mounted) return;
    setState(() => _displayName = name.isEmpty ? 'Guest User' : name);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          name.isEmpty ? 'Name cleared. Using Guest User.' : 'Name saved: $name',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================================
  // CRUD ЗАМЕТОК
  // ==========================================================================
  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatNow() {
    final d = DateTime.now();
    return '${_two(d.day)}.${_two(d.month)}.${d.year} ${_two(d.hour)}:${_two(d.minute)}';
  }

  Future<void> _addNote() async {
    final title = _noteController.text.trim();
    if (title.isEmpty) return;

    final note = NoteItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      dateText: _formatNow(),
      isCompleted: false,
    );

    setState(() {
      _notes.insert(0, note); // новая заметка в начало списка
      _noteController.clear();
    });
    await _saveNotes();
  }

  Future<void> _toggleNote(NoteItem note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index == -1) return;

    setState(() {
      _notes[index] = note.copyWith(isCompleted: !note.isCompleted);
    });
    await _saveNotes();
  }

  Future<void> _deleteNote(NoteItem note) async {
    setState(() => _notes.removeWhere((n) => n.id == note.id));
    await _saveNotes();
  }

  // ==========================================================================
  // UI
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Offline Vault',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode, size: 20),
          Switch(
            value: widget.isDark,
            onChanged: widget.onThemeChanged,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок с именем из хранилища
              Text(
                'Hello, $_displayName!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                'Everything here is saved on your device.',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Профиль: TextField + Save
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _saveUsername(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                        labelText: 'Username',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _saveUsername,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 8),

              // Добавление заметки
              const Text(
                'My Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _addNote(),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_note),
                        labelText: 'New note',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _addNote,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Список заметок
              Expanded(
                child: _notes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sticky_note_2_outlined,
                              size: 56,
                              color: scheme.outline,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No notes yet',
                              style: TextStyle(color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _notes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: note.isCompleted,
                                onChanged: (_) => _toggleNote(note),
                              ),
                              title: Text(
                                note.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  decoration: note.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: note.isCompleted
                                      ? scheme.onSurfaceVariant
                                      : null,
                                ),
                              ),
                              subtitle: Text(note.dateText),
                              trailing: IconButton(
                                tooltip: 'Delete',
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () => _deleteNote(note),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}