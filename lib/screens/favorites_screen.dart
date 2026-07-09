import 'package:flutter/material.dart';
import '../models/book.dart';
import '../services/favorites_service.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state_widget.dart';
import 'book_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final VoidCallback? onFavoritesChanged;

  const FavoritesScreen({super.key, this.onFavoritesChanged});

  @override
  State<FavoritesScreen> createState() => FavoritesScreenState();
}

class FavoritesScreenState extends State<FavoritesScreen> {
  List<Book> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void reload() => _loadFavorites();

  Future<void> _loadFavorites() async {
    setState(() => _loading = true);
    final favorites = await FavoritesService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favorites = favorites;
        _loading = false;
      });
    }
  }

  Future<void> _removeFavorite(Book book) async {
    await FavoritesService.instance.removeFavorite(book.key);
    setState(() => _favorites.removeWhere((b) => b.key == book.key));
    widget.onFavoritesChanged?.call();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${book.title} removido dos favoritos'),
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () async {
              await FavoritesService.instance.addFavorite(book);
              await _loadFavorites();
              widget.onFavoritesChanged?.call();
            },
          ),
        ),
      );
    }
  }

  Future<bool> _confirmRemove(Book book) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Remover favorito'),
        content: Text('Deseja remover "${book.title}" dos favoritos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Remover',
              style: TextStyle(color: Color(0xFFCF6679)),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Text(
                  'Favoritos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (_favorites.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _favorites.length.toString(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFFE0E0E0),
          strokeWidth: 2,
        ),
      );
    }

    if (_favorites.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.bookmark_border,
        title: 'Sem favoritos ainda',
        subtitle: 'Busque por livros e salve seus favoritos aqui',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: const Color(0xFFE0E0E0),
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _favorites.length,
        itemBuilder: (context, i) {
          final book = _favorites[i];
          return Dismissible(
            key: ValueKey(book.key),
            direction: DismissDirection.endToStart,
            confirmDismiss: (_) => _confirmRemove(book),
            onDismissed: (_) => _removeFavorite(book),
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1218),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Color(0xFFCF6679),
              ),
            ),
            child: BookCard(
              book: book,
              onTap: () => Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book),
                    ),
                  )
                  .then((_) => _loadFavorites()),
              onFavorite: () => _removeFavorite(book),
              isFavorite: true,
            ),
          );
        },
      ),
    );
  }
}
