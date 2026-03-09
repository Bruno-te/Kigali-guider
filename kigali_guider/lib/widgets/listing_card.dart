import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../theme.dart';

class ListingCard extends StatelessWidget {
  final Listing listing;
  final VoidCallback onTap;
  final double? distanceKm;
  final bool showDistance;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.distanceKm,
    this.showDistance = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.tagBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                AppCategories.getIcon(listing.category),
                color: AppTheme.accent,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    listing.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (listing.rating > 0) ...[
                        Text(
                          listing.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _StarRating(rating: listing.rating, size: 14),
                        const SizedBox(width: 8),
                      ],
                      if (showDistance && distanceKm != null)
                        Text(
                          '${distanceKm!.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                  if (listing.address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      listing.address,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({required this.rating, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return Icon(Icons.star, color: AppTheme.accent, size: size);
        } else if (i < rating) {
          return Icon(Icons.star_half, color: AppTheme.accent, size: size);
        } else {
          return Icon(Icons.star_border, color: AppTheme.textMuted, size: size);
        }
      }),
    );
  }
}
