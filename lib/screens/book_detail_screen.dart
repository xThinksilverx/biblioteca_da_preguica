import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;

  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  late Book _book;
  bool _loadingDetails = true;
  bool _isFavorite = false;
  bool _togglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _book = widget.book;
    _loadDetails();
    _checkFavorite();
  }

  Future<void> _loadDetails() async {
    try {
      final detailed = await ApiService.instance.fetchBookDetails(_book);
      if (mounted) {
        setState(() {
          _book = detailed;
          _loadingDetails = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingDetails = false);
    }
  }

  Future<void> _checkFavorite() async {
    final fav = await FavoritesService.instance.isFavorite(_book.key);
    if (mounted) setState(() => _isFavorite = fav);
  }

  Future<void> _toggleFavorite() async {
    setState(() => _togglingFavorite = true);
    try {
      if (_isFavorite) {
        await FavoritesService.instance.removeFavorite(_book.key);
        setState(() => _isFavorite = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Removido dos favoritos')),
          );
        }
      } else {
        await FavoritesService.instance.addFavorite(_book);
        setState(() => _isFavorite = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionado aos favoritos')),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _togglingFavorite = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(theme),
          SliverToBoxAdapter(
            child: _buildBody(theme),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _togglingFavorite ? null : _toggleFavorite,
        backgroundColor: _isFavorite
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
        foregroundColor: _isFavorite
            ? const Color(0xFFE0E0E0)
            : const Color(0xFF0A0A0A),
        icon: _togglingFavorite
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isFavorite ? Icons.bookmark : Icons.bookmark_border,
              ),
        label: Text(_isFavorite ? 'Salvo' : 'Salvar'),
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme) {
    return SliverAppBar(
      expandedHeight: _book.coverUrl.isNotEmpty ? 280 : 120,
      pinned: true,
      backgroundColor: const Color(0xFF0A0A0A),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: _book.coverUrl.isNotEmpty
            ? Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: _book.coverUrlLarge.isNotEmpty
                        ? _book.coverUrlLarge
                        : _book.coverUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: const Color(0xFF141414),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: const Color(0xFF141414),
                    ),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0A0A0A),
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              )
            : Container(color: const Color(0xFF141414)),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _book.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _book.authorsDisplay,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          _buildMetaRow(theme),
          if (_book.subjects.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSection(theme, 'Generos e assuntos', _buildSubjectChips(theme)),
          ],
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF1E1E1E)),
          const SizedBox(height: 16),
          if (_loadingDetails) ...[
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  color: Color(0xFF5A5A5A),
                  strokeWidth: 2,
                ),
              ),
            ),
          ] else if (_book.description != null &&
              _book.description!.isNotEmpty) ...[
            _buildSection(
              theme,
              'Descricao',
              Text(
                _book.description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB0B0B0),
                  height: 1.6,
                ),
              ),
            ),
          ] else if (_book.firstSentence != null &&
              _book.firstSentence!.isNotEmpty) ...[
            _buildSection(
              theme,
              'Primeira frase',
              Text(
                _book.firstSentence!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFB0B0B0),
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Text(
                'Sem descricao disponivel',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF3A3A3A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetaRow(ThemeData theme) {
    final items = <(IconData, String)>[];

    if (_book.firstPublishYear != null) {
      items.add((Icons.calendar_today_outlined, _book.firstPublishYear.toString()));
    }
    if (_book.publishers.isNotEmpty) {
      items.add((Icons.business_outlined, _book.publishers.first));
    }
    if (_book.languages.isNotEmpty) {
      items.add((Icons.language_outlined, _book.languages.first.toUpperCase()));
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items.map((item) {
        final (icon, label) = item;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF5A5A5A)),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7A7A7A),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSubjectChips(ThemeData theme) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _book.subjects
          .map((s) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Text(
                  s,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSection(ThemeData theme, String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: const Color(0xFF5A5A5A),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        content,
      ],
    );
  }
}
