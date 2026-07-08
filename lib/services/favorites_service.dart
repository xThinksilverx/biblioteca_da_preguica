import '../models/book.dart';
import 'auth_service.dart';
import 'database_service.dart';

class FavoritesService {
  static FavoritesService? _instance;
  FavoritesService._();

  static FavoritesService get instance {
    _instance ??= FavoritesService._();
    return _instance!;
  }

  Future<int?> _getCurrentUserId() async {
    final user = await AuthService.instance.getLoggedUser();
    return user?.id;
  }

  Future<List<Book>> getFavorites() async {
    final userId = await _getCurrentUserId();
    if (userId == null) return [];
    return await DatabaseService.instance.getFavorites(userId);
  }

  Future<void> addFavorite(Book book) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;
    await DatabaseService.instance.addFavorite(userId, book);
  }

  Future<void> removeFavorite(String bookKey) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return;
    await DatabaseService.instance.removeFavorite(userId, bookKey);
  }

  Future<bool> isFavorite(String bookKey) async {
    final userId = await _getCurrentUserId();
    if (userId == null) return false;
    return await DatabaseService.instance.isFavorite(userId, bookKey);
  }
}
