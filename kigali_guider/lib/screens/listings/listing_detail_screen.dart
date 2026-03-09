import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/listing.dart';
import '../../models/review.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'listing_form_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final Listing listing;

  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  GoogleMapController? _mapController;
  bool _showReviewForm = false;
  double _reviewRating = 4.0;
  final _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ListingsProvider>().subscribeToReviews(widget.listing.id);
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _launchMaps() async {
    final lat = widget.listing.latitude;
    final lng = widget.listing.longitude;
    // Use only coordinates so Maps routes to the exact listing location.
    // (destination_place_id must be a Google Place ID, not a name.)
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone() async {
    final uri = Uri.parse('tel:${widget.listing.contactNumber}');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _submitReview() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final review = Review(
      id: '',
      listingId: widget.listing.id,
      userId: auth.user!.uid,
      userName: auth.userProfile?.displayName ?? 'Anonymous',
      rating: _reviewRating,
      comment: _reviewController.text.trim(),
      createdAt: DateTime.now(),
    );

    final success = await context.read<ListingsProvider>().addReview(review);
    if (success && mounted) {
      setState(() => _showReviewForm = false);
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listingsProvider = context.watch<ListingsProvider>();
    final reviews = listingsProvider.reviews;
    final isOwner = auth.user?.uid == widget.listing.createdBy;
    final listing = widget.listing;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: CustomScrollView(
        slivers: [
          // App bar with map
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (isOwner)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: AppTheme.accent, size: 20),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ListingFormScreen(listing: listing),
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(listing.latitude, listing.longitude),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('listing'),
                    position: LatLng(listing.latitude, listing.longitude),
                    infoWindow: InfoWindow(title: listing.name),
                  ),
                },
                onMapCreated: (c) => _mapController = c,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & category
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              listing.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppTheme.accent, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  listing.category,
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                                const Text(' · ', style: TextStyle(color: AppTheme.textMuted)),
                                Text(
                                  '${listing.distanceTo(-1.9441, 30.0619).toStringAsFixed(1)} km',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.tagBackground,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          listing.category,
                          style: const TextStyle(color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      listing.description.isEmpty
                          ? 'No description available.'
                          : listing.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Info row
                  _InfoTile(icon: Icons.location_on, label: listing.address),
                  if (listing.contactNumber.isNotEmpty)
                    _InfoTile(
                      icon: Icons.phone,
                      label: listing.contactNumber,
                      onTap: _launchPhone,
                    ),

                  const SizedBox(height: 20),

                  // Navigate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _launchMaps,
                      icon: const Icon(Icons.navigation),
                      label: const Text('Get Directions'),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Reviews header
                  Row(
                    children: [
                      const Text(
                        'Reviews',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (listing.reviewCount > 0)
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppTheme.accent, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${listing.rating.toStringAsFixed(1)} · ${listing.reviewCount} reviews',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Add review button
                  if (!_showReviewForm)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _showReviewForm = true),
                      icon: const Icon(Icons.rate_review, color: AppTheme.accent),
                      label: const Text('Rate this service', style: TextStyle(color: AppTheme.accent)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                  // Review form
                  if (_showReviewForm) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardDark,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Rating', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          RatingBar.builder(
                            initialRating: _reviewRating,
                            minRating: 1,
                            itemSize: 32,
                            itemBuilder: (_, __) => const Icon(Icons.star, color: AppTheme.accent),
                            onRatingUpdate: (r) => setState(() => _reviewRating = r),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _reviewController,
                            maxLines: 3,
                            style: const TextStyle(color: AppTheme.inputText),
                            decoration: const InputDecoration(
                              hintText: 'Write your review...',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => setState(() => _showReviewForm = false),
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.textMuted)),
                                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _submitReview,
                                  child: const Text('Submit'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Reviews list
                  ...reviews.map((review) => _ReviewCard(review: review)),

                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No reviews yet. Be the first!',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _InfoTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: onTap != null ? AppTheme.accent : AppTheme.textSecondary,
                  fontSize: 14,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final dynamic review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.tagBackground,
                child: Text(
                  review.userName.isNotEmpty ? review.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review.userName,
                  style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < review.rating ? Icons.star : Icons.star_border,
                  color: AppTheme.accent,
                  size: 14,
                )),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '"${review.comment}"',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}
