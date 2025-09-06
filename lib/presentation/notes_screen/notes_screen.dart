import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_notes_widget.dart';
import './widgets/note_card_widget.dart';
import './widgets/note_editor_widget.dart';
import './widgets/search_notes_widget.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _filteredNotes = [];
  String _searchQuery = '';
  bool _isSearchActive = false;
  bool _isLoading = true;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Mock data for demonstration
  final List<Map<String, dynamic>> _mockNotes = [
    {
      'id': 1,
      'title': 'Estratégia de Investimentos 2025',
      'content':
          'Pesquisei sobre fundos imobiliários e decidi alocar 30% da minha reserva de emergência em FIIs com foco em shoppings e galpões logísticos. O rendimento médio está em 0,8% ao mês. Preciso estudar mais sobre KNRI11 e HGLG11.',
      'category': 'investimentos',
      'date': DateTime.now().subtract(Duration(hours: 2)),
      'lastModified': DateTime.now().subtract(Duration(hours: 2)),
    },
    {
      'id': 2,
      'title': 'Análise de Gastos - Dezembro',
      'content':
          'Gastei R\$ 450 a mais que o planejado este mês. Principais vilões: delivery (R\$ 280) e roupas (R\$ 170). Para janeiro, vou estabelecer limite de R\$ 200 para delivery e pausar compras de roupas até março.',
      'category': 'orcamento',
      'date': DateTime.now().subtract(Duration(days: 1)),
      'lastModified': DateTime.now().subtract(Duration(days: 1)),
    },
    {
      'id': 3,
      'title': 'Meta: Viagem para Europa',
      'content':
          'Objetivo: R\$ 15.000 até dezembro de 2025\nJá tenho: R\$ 3.200\nPreciso poupar: R\$ 980/mês\n\nPlano:\n- Freelances extras: +R\$ 500/mês\n- Reduzir gastos supérfluos: -R\$ 300/mês\n- Vender itens não usados: R\$ 1.000 (uma vez)',
      'category': 'metas',
      'date': DateTime.now().subtract(Duration(days: 3)),
      'lastModified': DateTime.now().subtract(Duration(days: 2)),
    },
    {
      'id': 4,
      'title': 'Insight: Padrão de Gastos',
      'content':
          'Descobri que gasto 40% mais nos finais de semana. Principalmente com entretenimento e alimentação fora. Vou criar um "orçamento de fim de semana" separado para ter mais controle.',
      'category': 'insights',
      'date': DateTime.now().subtract(Duration(days: 5)),
      'lastModified': DateTime.now().subtract(Duration(days: 5)),
    },
    {
      'id': 5,
      'title': 'Reserva de Emergência',
      'content':
          'Meta: 6 meses de gastos = R\$ 18.000\nAtual: R\$ 12.500\nFaltam: R\$ 5.500\n\nEstratégia: guardar R\$ 500/mês na poupança até completar. Depois migrar tudo para CDB com liquidez diária.',
      'category': 'metas',
      'date': DateTime.now().subtract(Duration(days: 7)),
      'lastModified': DateTime.now().subtract(Duration(days: 7)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _loadNotes();
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getString('user_notes');

      if (notesJson != null) {
        final List<dynamic> notesList = json.decode(notesJson);
        _notes = notesList.map((note) {
          return {
            ...note,
            'date': DateTime.parse(note['date']),
            'lastModified': DateTime.parse(note['lastModified']),
          };
        }).toList().cast<Map<String, dynamic>>();
      } else {
        // Load mock data for first time users
        _notes = List.from(_mockNotes);
        await _saveNotes();
      }

      _notes.sort((a, b) => (b['lastModified'] as DateTime)
          .compareTo(a['lastModified'] as DateTime));
      _filteredNotes = List.from(_notes);
    } catch (e) {
      // Fallback to mock data if there's an error
      _notes = List.from(_mockNotes);
      _filteredNotes = List.from(_notes);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = json.encode(_notes.map((note) {
        return {
          ...note,
          'date': (note['date'] as DateTime).toIso8601String(),
          'lastModified': (note['lastModified'] as DateTime).toIso8601String(),
        };
      }).toList());
      await prefs.setString('user_notes', notesJson);
    } catch (e) {
      // Handle save error silently
    }
  }

  void _filterNotes(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredNotes = List.from(_notes);
      } else {
        _filteredNotes = _notes.where((note) {
          final title = (note['title'] as String? ?? '').toLowerCase();
          final content = (note['content'] as String? ?? '').toLowerCase();
          final category = (note['category'] as String? ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return title.contains(searchLower) ||
              content.contains(searchLower) ||
              category.contains(searchLower);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _filteredNotes = List.from(_notes);
      _isSearchActive = false;
    });
  }

  void _openNoteEditor({Map<String, dynamic>? note}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NoteEditorWidget(
          note: note,
          onSave: (noteData) {
            _saveNote(noteData);
          },
        ),
      ),
    );
  }

  void _saveNote(Map<String, dynamic> noteData) {
    setState(() {
      final existingIndex =
          _notes.indexWhere((note) => note['id'] == noteData['id']);

      if (existingIndex != -1) {
        _notes[existingIndex] = noteData;
      } else {
        _notes.insert(0, noteData);
      }

      _notes.sort((a, b) => (b['lastModified'] as DateTime)
          .compareTo(a['lastModified'] as DateTime));
      _filterNotes(_searchQuery);
    });

    _saveNotes();
  }

  void _deleteNote(Map<String, dynamic> note) {
    setState(() {
      _notes.removeWhere((n) => n['id'] == note['id']);
      _filterNotes(_searchQuery);
    });

    _saveNotes();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação excluída'),
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () {
            setState(() {
              _notes.add(note);
              _notes.sort((a, b) => (b['lastModified'] as DateTime)
                  .compareTo(a['lastModified'] as DateTime));
              _filterNotes(_searchQuery);
            });
            _saveNotes();
          },
        ),
      ),
    );
  }

  void _shareNote(Map<String, dynamic> note) {
    final title = note['title'] as String? ?? 'Sem título';
    final content = note['content'] as String? ?? '';
    final shareText =
        '$title\n\n$content\n\n--- Compartilhado via Planilha Mulher Rica ---';

    // Copy to clipboard as sharing functionality
    Clipboard.setData(ClipboardData(text: shareText));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação copiada para a área de transferência'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _duplicateNote(Map<String, dynamic> note) {
    final duplicatedNote = {
      ...note,
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': '${note['title']} (Cópia)',
      'date': DateTime.now(),
      'lastModified': DateTime.now(),
    };

    _saveNote(duplicatedNote);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação duplicada com sucesso'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  void _archiveNote(Map<String, dynamic> note) {
    // For now, just remove from main list (could implement archived notes later)
    _deleteNote(note);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação arquivada'),
        backgroundColor: AppTheme.getWarningColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        variant: CustomAppBarVariant.notes,
        actions: [
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() {
                _isSearchActive = !_isSearchActive;
              });
              if (!_isSearchActive) {
                _clearSearch();
              }
            },
            icon: CustomIconWidget(
              iconName: _isSearchActive ? 'close' : 'search',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: _isSearchActive ? 'Fechar busca' : 'Buscar anotações',
          ),
          IconButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _openNoteEditor();
            },
            icon: CustomIconWidget(
              iconName: 'add',
              color: colorScheme.onSurface,
              size: 24,
            ),
            tooltip: 'Nova anotação',
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: Column(
        children: [
          if (_isSearchActive)
            SearchNotesWidget(
              onSearchChanged: _filterNotes,
              onClearSearch: _clearSearch,
              currentQuery: _searchQuery,
            ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : _searchQuery.isNotEmpty
                    ? SearchResultsWidget(
                        searchResults: _filteredNotes,
                        searchQuery: _searchQuery,
                        onNoteTap: (note) => _openNoteEditor(note: note),
                      )
                    : _notes.isEmpty
                        ? EmptyNotesWidget(
                            onCreateNote: () => _openNoteEditor(),
                          )
                        : _buildNotesList(),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4, // Notes tab index
        onTap: (index) {
          // Handle navigation to other tabs
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard-screen');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/transactions-screen');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/planning-screen');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/goals-screen');
              break;
            case 4:
              // Already on notes screen
              break;
          }
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: FloatingActionButton(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _openNoteEditor();
              },
              child: CustomIconWidget(
                iconName: 'edit',
                color: colorScheme.onSecondary,
                size: 24,
              ),
              tooltip: 'Nova anotação',
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotesList() {
    return RefreshIndicator(
      onRefresh: _loadNotes,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'note',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Minhas Anotações',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_notes.length}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final note = _filteredNotes[index];
                return NoteCardWidget(
                  note: note,
                  onTap: () => _openNoteEditor(note: note),
                  onDelete: () => _deleteNote(note),
                  onEdit: () => _openNoteEditor(note: note),
                  onShare: () => _shareNote(note),
                  onDuplicate: () => _duplicateNote(note),
                  onArchive: () => _archiveNote(note),
                );
              },
              childCount: _filteredNotes.length,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 10.h), // Bottom padding for FAB
          ),
        ],
      ),
    );
  }
}