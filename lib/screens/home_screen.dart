import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/favorites_service.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state_widget.dart';
import 'book_detail_screen.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  int _selectedIndex = 0;
  User? _currentUser;
  List<Book> _results = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  String _lastQuery = '';
  SearchType _searchType = SearchType.general;
  int _currentPage = 1;
  bool _hasMore = true;
  Set<String> _favoriteKeys = {};

  @override
  void initState() {
    super.initState();
    _loadUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.instance.getLoggedUser();
    if (mounted) setState(() => _currentUser = user);
    await _loadFavoriteKeys();
  }

  Future<void> _loadFavoriteKeys() async {
    final favorites = await FavoritesService.instance.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteKeys = favorites.map((b) => b.key).toSet();
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore &&
        _hasMore &&
        _lastQuery.isNotEmpty) {
      _loadMore();
    }
  }

  Future<void> _search({bool reset = true}) async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _error = null;
        _lastQuery = '';
      });
      return;
    }

    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _results = [];
        _currentPage = 1;
        _hasMore = true;
        _lastQuery = query;
      });
    }

    try {
      final books = await ApiService.instance.searchBooks(
        query,
        type: _searchType,
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _results = reset ? books : [..._results, ...books];
        _hasMore = books.length == 20;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Erro na busca. Verifique sua conexao e tente novamente.';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    setState(() {
      _loadingMore = true;
      _currentPage++;
    });
    await _search(reset: false);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _error = null;
      _lastQuery = '';
      _currentPage = 1;
      _hasMore = true;
    });
  }

  Future<void> _toggleFavorite(Book book) async {
    final isFav = _favoriteKeys.contains(book.key);
    if (isFav) {
      await FavoritesService.instance.removeFavorite(book.key);
      setState(() => _favoriteKeys.remove(book.key));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removido dos favoritos')),
        );
      }
    } else {
      await FavoritesService.instance.addFavorite(book);
      setState(() => _favoriteKeys.add(book.key));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicionado aos favoritos')),
        );
      }
    }
  }

  void _openDetail(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookDetailScreen(book: book),
      ),
    ).then((_) => _loadFavoriteKeys());
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141414),
        title: const Text('Sair da conta'),
        content: const Text('Deseja encerrar a sessao?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildSearchTab(theme),
          FavoritesScreen(
            onFavoritesChanged: _loadFavoriteKeys,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF1E1E1E)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            setState(() => _selectedIndex = i);
            if (i == 1) _loadFavoriteKeys();
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Busca',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTab(ThemeData theme) {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(theme),
          _buildSearchBar(theme),
          _buildFilterChips(theme),
          const Divider(height: 1),
          Expanded(child: _buildContent(theme)),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/preguica.jpg',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Biblioteca da Preguica',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
          if (_currentUser != null) ...[
            Text(
              _currentUser!.username,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.logout, size: 20),
              onPressed: _logout,
              color: const Color(0xFF5A5A5A),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onSubmitted: (_) => _search(),
        decoration: InputDecoration(
          hintText: 'Buscar livros...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                )
              : IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
        ),
        onChanged: (v) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final types = [
      (SearchType.general, 'Geral'),
      (SearchType.title, 'Titulo'),
      (SearchType.author, 'Autor'),
      (SearchType.subject, 'Genero'),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (type, label) = types[i];
          final selected = _searchType == type;
          return FilterChip(
            label: Text(label),
            selected: selected,
            onSelected: (_) {
              setState(() => _searchType = type);
              if (_lastQuery.isNotEmpty) _search();
            },
            labelStyle: TextStyle(
              color: selected ? const Color(0xFF0A0A0A) : const Color(0xFF9E9E9E),
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 12,
            ),
          );
        },
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

    if (_error != null) {
      return EmptyStateWidget(
        icon: Icons.wifi_off,
        title: 'Falha na conexao',
        subtitle: _error!,
        action: ElevatedButton(
          onPressed: _search,
          child: const Text('Tentar novamente'),
        ),
      );
    }

    if (_lastQuery.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search,
        title: 'Busque por livros',
        subtitle: 'Digite um titulo, autor ou genero para comecar',
      );
    }

    if (_results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.menu_book,
        title: 'Nenhum resultado',
        subtitle: 'Nao encontramos livros para "$_lastQuery"',
        action: OutlinedButton(
          onPressed: _clearSearch,
          child: const Text('Limpar busca'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _search(),
      color: const Color(0xFFE0E0E0),
      backgroundColor: const Color(0xFF1E1E1E),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _results.length + (_loadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == _results.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF5A5A5A),
                  ),
                ),
              ),
            );
          }
          final book = _results[i];
          return BookCard(
            book: book,
            onTap: () => _openDetail(book),
            onFavorite: () => _toggleFavorite(book),
            isFavorite: _favoriteKeys.contains(book.key),
          );
        },
      ),
    );
  }
}
