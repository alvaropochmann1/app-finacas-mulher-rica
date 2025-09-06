import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/custom_icon_widget.dart';

class SearchNotesWidget extends StatefulWidget {
  final Function(String) onSearchChanged;
  final VoidCallback onClearSearch;
  final String currentQuery;

  const SearchNotesWidget({
    super.key,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.currentQuery,
  });

  @override
  State<SearchNotesWidget> createState() => _SearchNotesWidgetState();
}

class _SearchNotesWidgetState extends State<SearchNotesWidget>
    with SingleTickerProviderStateMixin {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.currentQuery);
    _searchFocusNode = FocusNode();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _searchFocusNode.addListener(_onFocusChanged);
    _searchController.addListener(_onSearchChanged);

    if (widget.currentQuery.isNotEmpty) {
      _isSearchActive = true;
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onFocusChanged);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    setState(() {
      _isSearchActive =
          _searchFocusNode.hasFocus || _searchController.text.isNotEmpty;
    });

    if (_isSearchActive) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _onSearchChanged() {
    widget.onSearchChanged(_searchController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isSearchActive
                      ? colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.3),
                  width: _isSearchActive ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Buscar anotações...',
                  hintStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: CustomIconWidget(
                      iconName: 'search',
                      color: _isSearchActive
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                  suffixIcon: AnimatedBuilder(
                    animation: _scaleAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: _searchController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  _searchController.clear();
                                  widget.onClearSearch();
                                  _searchFocusNode.unfocus();
                                },
                                icon: CustomIconWidget(
                                  iconName: 'clear',
                                  color: colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              )
                            : null,
                      );
                    },
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 2.h,
                  ),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  _searchFocusNode.unfocus();
                },
              ),
            ),
          ),
          if (_isSearchActive) ...[
            SizedBox(width: 2.w),
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      _searchController.clear();
                      widget.onClearSearch();
                      _searchFocusNode.unfocus();
                    },
                    child: Text(
                      'Cancelar',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class SearchResultsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> searchResults;
  final String searchQuery;
  final Function(Map<String, dynamic>) onNoteTap;

  const SearchResultsWidget({
    super.key,
    required this.searchResults,
    required this.searchQuery,
    required this.onNoteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (searchResults.isEmpty && searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'search_off',
                color: colorScheme.onSurfaceVariant,
                size: 20.w,
              ),
              SizedBox(height: 2.h),
              Text(
                'Nenhuma anotação encontrada',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                'Tente usar palavras-chave diferentes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (searchQuery.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              '${searchResults.length} resultado${searchResults.length != 1 ? 's' : ''} para "${searchQuery}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.only(bottom: 10.h),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final note = searchResults[index];
              return _buildSearchResultItem(context, note);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResultItem(
      BuildContext context, Map<String, dynamic> note) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final String title = note['title'] as String? ?? 'Sem título';
    final String content = note['content'] as String? ?? '';
    final DateTime date = note['date'] as DateTime? ?? DateTime.now();
    final String category = note['category'] as String? ?? 'geral';

    // Highlight search terms
    final highlightedTitle = _highlightSearchTerm(title, searchQuery);
    final highlightedContent = _highlightSearchTerm(
      content.length > 100 ? '${content.substring(0, 100)}...' : content,
      searchQuery,
    );

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: InkWell(
        onTap: () => onNoteTap(note),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(category, colorScheme)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _getCategoryLabel(category),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: _getCategoryColor(category, colorScheme),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    _formatDate(date),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.h),
              RichText(
                text: highlightedTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (content.isNotEmpty) ...[
                SizedBox(height: 1.h),
                RichText(
                  text: highlightedContent,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  TextSpan _highlightSearchTerm(String text, String searchTerm) {
    if (searchTerm.isEmpty) {
      return TextSpan(text: text);
    }

    final List<TextSpan> spans = [];
    final String lowerText = text.toLowerCase();
    final String lowerSearchTerm = searchTerm.toLowerCase();

    int start = 0;
    int index = lowerText.indexOf(lowerSearchTerm);

    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + searchTerm.length),
        style: TextStyle(
          backgroundColor: Colors.yellow.withValues(alpha: 0.3),
          fontWeight: FontWeight.w600,
        ),
      ));

      start = index + searchTerm.length;
      index = lowerText.indexOf(lowerSearchTerm, start);
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(children: spans);
  }

  Color _getCategoryColor(String category, ColorScheme colorScheme) {
    switch (category) {
      case 'orcamento':
        return AppTheme.getSuccessColor(
            colorScheme.brightness == Brightness.light);
      case 'investimentos':
        return AppTheme.getAccentColor(
            colorScheme.brightness == Brightness.light);
      case 'metas':
        return colorScheme.primary;
      case 'insights':
        return AppTheme.getWarningColor(
            colorScheme.brightness == Brightness.light);
      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'orcamento':
        return 'Orçamento';
      case 'investimentos':
        return 'Investimentos';
      case 'metas':
        return 'Metas';
      case 'insights':
        return 'Insights';
      default:
        return 'Geral';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoje';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }
  }
}