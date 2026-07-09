import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final bool showFavoriteButton;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.showFavoriteButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCover(context),
            Expanded(child: _buildInfo(context)),
            if (showFavoriteButton) _buildFavoriteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
      ),
      child: SizedBox(
        width: 80,
        height: 120,
        child: book.coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: book.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => _coverPlaceholder(),
                errorWidget: (context, url, error) => _coverPlaceholder(),
              )
            : _coverPlaceholder(),
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: const Icon(
        Icons.menu_book,
        color: Color(0xFF3A3A3A),
        size: 36,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final theme = Theme.of(context);
    final summary = book.firstSentence ?? book.description;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            book.title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            book.authorsDisplay,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (book.firstPublishYear != null) ...[
            const SizedBox(height: 4),
            Text(
              book.firstPublishYear.toString(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5A5A5A),
                fontSize: 11,
              ),
            ),
          ],
          if (summary != null && summary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7A7A7A),
                fontSize: 11,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (book.subjects.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: book.subjects
                  .take(2)
                  .map((s) => _buildSubjectChip(context, s))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectChip(BuildContext context, String subject) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Text(
        subject,
        style: const TextStyle(
          fontSize: 10,
          color: Color(0xFF7A7A7A),
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, right: 8),
      child: IconButton(
        onPressed: onFavorite,
        icon: Icon(
          isFavorite ? Icons.bookmark : Icons.bookmark_border,
          color: isFavorite
              ? Colors.white
              : const Color(0xFF5A5A5A),
          size: 22,
        ),
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}
