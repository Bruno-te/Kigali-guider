import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/category_filter_row.dart';
import '../listings/listing_detail_screen.dart';

/// Default center (Kigali) when location is unavailable.
const double _kigaliLat = -1.9441;
const double _kigaliLng = 30.0619;

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchController = TextEditingController();
  double? _userLat;
  double? _userLng;
  bool _locationResolved = false;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _useKigaliCenter();
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      _useKigaliCenter();
      return;
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      if (mounted) {
        setState(() {
          _userLat = pos.latitude;
          _userLng = pos.longitude;
          _locationResolved = true;
        });
      }
    } catch (_) {
      _useKigaliCenter();
    }
  }

  void _useKigaliCenter() {
    if (mounted) {
      setState(() {
        _userLat = _kigaliLat;
        _userLng = _kigaliLng;
        _locationResolved = true;
      });
    }
  }

  List<MapEntry<Listing, double>> _sortedListingsWithDistance(
    List<Listing> list,
    double userLat,
    double userLng,
  ) {
    final withDistance = list.map((l) => MapEntry(l, l.distanceTo(userLat, userLng))).toList();
    withDistance.sort((a, b) => a.value.compareTo(b.value));
    return withDistance;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final listings = listingsProvider.filteredListings;
    final userLat = _userLat ?? _kigaliLat;
    final userLng = _userLng ?? _kigaliLng;
    // Sort by distance (nearest first) and attach distance for each card
    final sortedWithDistance = _sortedListingsWithDistance(listings, userLat, userLng);

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kigali City',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Hello, ${auth.userProfile?.displayName.split(' ').first ?? 'there'}!',
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppTheme.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        (auth.userProfile?.displayName.isNotEmpty == true
                                ? auth.userProfile!.displayName[0].toUpperCase()
                                : 'U'),
                        style: const TextStyle(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.inputText),
                onChanged: (v) => listingsProvider.setSearchQuery(v),
                decoration: InputDecoration(
                  hintText: 'Search for a service',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppTheme.textMuted),
                          onPressed: () {
                            _searchController.clear();
                            listingsProvider.setSearchQuery('');
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Category filter
            CategoryFilterRow(
              selected: listingsProvider.selectedCategory,
              categories: AppCategories.all,
              onSelected: listingsProvider.setCategory,
            ),
            const SizedBox(height: 20),
            // Section header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text(
                    'Near You',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${listings.length} ${listings.length == 1 ? 'place' : 'places'}',
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Listings list (Near You — sorted by distance)
            Expanded(
              child: listingsProvider.status == ListingsStatus.loading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
                  : sortedWithDistance.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search_off, color: AppTheme.textMuted, size: 60),
                              const SizedBox(height: 12),
                              Text(
                                listingsProvider.searchQuery.isNotEmpty
                                    ? 'No results for "${listingsProvider.searchQuery}"'
                                    : 'No listings in this category yet',
                                style: const TextStyle(color: AppTheme.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: sortedWithDistance.length,
                          itemBuilder: (ctx, i) {
                            final entry = sortedWithDistance[i];
                            final listing = entry.key;
                            final distanceKm = entry.value;
                            return ListingCard(
                              listing: listing,
                              distanceKm: distanceKm,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ListingDetailScreen(listing: listing),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
