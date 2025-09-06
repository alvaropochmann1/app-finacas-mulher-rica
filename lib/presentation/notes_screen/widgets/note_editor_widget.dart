import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NoteEditorWidget extends StatefulWidget {
  final Map<String, dynamic>? note;
  final Function(Map<String, dynamic>) onSave;

  const NoteEditorWidget({
    super.key,
    this.note,
    required this.onSave,
  });

  @override
  State<NoteEditorWidget> createState() => _NoteEditorWidgetState();
}

class _NoteEditorWidgetState extends State<NoteEditorWidget> {
  late TextEditingController _titleController;
  late QuillController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  String _selectedCategory = 'geral';
  bool _hasUnsavedChanges = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'geral', 'label': 'Geral', 'icon': 'note'},
    {
      'key': 'orcamento',
      'label': 'Orçamento',
      'icon': 'account_balance_wallet'
    },
    {'key': 'investimentos', 'label': 'Investimentos', 'icon': 'trending_up'},
    {'key': 'metas', 'label': 'Metas', 'icon': 'flag'},
    {'key': 'insights', 'label': 'Insights', 'icon': 'lightbulb'},
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?['title'] ?? '');
    _contentController = QuillController.basic();
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();

    if (widget.note != null) {
      _selectedCategory = widget.note!['category'] ?? 'geral';
      if (widget.note!['content'] != null &&
          (widget.note!['content'] as String).isNotEmpty) {
        _contentController.document =
            Document.fromJson([
              {'insert': widget.note!['content']}
            ]);
      }
    }

    _titleController.addListener(_onContentChanged);
    _contentController.addListener(_onContentChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onContentChanged);
    _contentController.removeListener(_onContentChanged);
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onContentChanged() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && _hasUnsavedChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            onPressed: () async {
              if (_hasUnsavedChanges) {
                final shouldPop = await _showUnsavedChangesDialog();
                if (shouldPop == true && context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            icon: CustomIconWidget(
              iconName: 'arrow_back_ios',
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          title: Text(
            widget.note == null ? 'Nova Anotação' : 'Editar Anotação',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_hasUnsavedChanges)
              TextButton(
                onPressed: _saveNote,
                child: Text(
                  'Salvar',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            SizedBox(width: 2.w),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Título da anotação',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) {
                      _contentFocusNode.requestFocus();
                    },
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'category',
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Categoria:',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((category) {
                              final isSelected =
                                  _selectedCategory == category['key'];
                              return Padding(
                                padding: EdgeInsets.only(right: 2.w),
                                child: FilterChip(
                                  selected: isSelected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CustomIconWidget(
                                        iconName: category['icon'],
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onSurfaceVariant,
                                        size: 16,
                                      ),
                                      SizedBox(width: 1.w),
                                      Text(category['label']),
                                    ],
                                  ),
                                  onSelected: (selected) {
                                    if (selected) {
                                      setState(() {
                                        _selectedCategory = category['key'];
                                        _hasUnsavedChanges = true;
                                      });
                                    }
                                  },
                                  selectedColor: colorScheme.primary,
                                  checkmarkColor: colorScheme.onPrimary,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(
                  bottom: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
              ),
              child: QuillSimpleToolbar(
                controller: _contentController,
                config: const QuillSimpleToolbarConfig(
                  showBoldButton: true,
                  showItalicButton: true,
                  showUnderLineButton: true,
                  showStrikeThrough: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showBackgroundColorButton: false,
                  showClearFormat: true,
                  showAlignmentButtons: false,
                  showLeftAlignment: false,
                  showCenterAlignment: false,
                  showRightAlignment: false,
                  showJustifyAlignment: false,
                  showHeaderStyle: false,
                  showListNumbers: true,
                  showListBullets: true,
                  showListCheck: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showLink: false,
                  showUndo: true,
                  showRedo: true,
                  showDirection: false,
                  showSearchButton: false,
                  showSubscript: false,
                  showSuperscript: false,
                  showFontFamily: false,
                  showFontSize: false,
                  multiRowsDisplay: false,
                ),
              ),
            ),
            _buildFinancialSymbolsToolbar(context),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4.w),
                child: QuillEditor.basic(
                  controller: _contentController,
                  focusNode: _contentFocusNode,
                  config: QuillEditorConfig(
                    placeholder: 'Comece a escrever sua anotação...',
                    padding: EdgeInsets.zero,
                    autoFocus: widget.note == null,
                    expands: true,
                    scrollable: true,
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _hasUnsavedChanges
            ? FloatingActionButton(
                onPressed: _saveNote,
                child: CustomIconWidget(
                  iconName: 'save',
                  color: theme.colorScheme.onSecondary,
                  size: 24,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildFinancialSymbolsToolbar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final symbols = ['R\$', '%', '+', '-', '=', '×', '÷', '€', '£'];

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'functions',
            color: colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: symbols.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: InkWell(
                    onTap: () {
                      _insertSymbol(symbols[index]);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        symbols[index],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _insertSymbol(String symbol) {
    final selection = _contentController.selection;
    _contentController.replaceText(
      selection.baseOffset,
      selection.extentOffset - selection.baseOffset,
      symbol,
      TextSelection.collapsed(offset: selection.baseOffset + symbol.length),
    );
    _contentFocusNode.requestFocus();
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text(
            'Alterações não salvas',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Você tem alterações não salvas. Deseja sair sem salvar?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                'Sair sem salvar',
                style: TextStyle(
                  color: AppTheme.getErrorColor(
                      theme.brightness == Brightness.light),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                _saveNote();
              },
              child: Text('Salvar e sair'),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.document.toPlainText().trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Adicione um título ou conteúdo para salvar a anotação'),
          backgroundColor: AppTheme.getWarningColor(
              Theme.of(context).brightness == Brightness.light),
        ),
      );
      return;
    }

    final noteData = {
      'id': widget.note?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'title': title.isEmpty ? 'Sem título' : title,
      'content': content,
      'category': _selectedCategory,
      'date': widget.note?['date'] ?? DateTime.now(),
      'lastModified': DateTime.now(),
    };

    widget.onSave(noteData);

    setState(() {
      _hasUnsavedChanges = false;
    });

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Anotação salva com sucesso!'),
        backgroundColor: AppTheme.getSuccessColor(
            Theme.of(context).brightness == Brightness.light),
      ),
    );

    Navigator.of(context).pop();
  }
}