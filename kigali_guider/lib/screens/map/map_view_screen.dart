import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../providers/listings_provider.dart';
import '../../models/listing.dart';
import '../../theme.dart';
import '../listings/listing_detail_screen.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _mapController;
  Listing? _selectedListing;

  static const LatLng _kigaliCenter = LatLng(-1.9441, 30.0619);

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(List<Listing> listings) {
    return listings.map((listing) {
      return Marker(
        markerId: MarkerId(listing.id),
        position: LatLng(listing.latitude, listing.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedListing?.id == listing.id
              ? BitmapDescriptor.hueOrange
              : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: listing.name,
          snippet: listing.category,
        ),
        onTap: () => setState(() => _selectedListing = listing),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>().filteredListings;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('Map View'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(_kigaliCenter, 13),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _kigaliCenter,
              zoom: 13,
            ),
            markers: _buildMarkers(listings),
            onMapCreated: (c) => _mapController = c,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: true,
            onTap: (_) => setState(() => _selectedListing = null),
          ),

          // Selected listing card
          if (_selectedListing != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListingDetailScreen(listing: _selectedListing!),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.tagBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          AppCategories.getIcon(_selectedListing!.category),
                          color: AppTheme.accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedListing!.name,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              _selectedListing!.category,
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                            Text(
                              _selectedListing!.address,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppTheme.accent, size: 16),
                    ],
                  ),
                ),
              ),
            ),

          // Listings count badge
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.place, color: AppTheme.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${listings.length} places',
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
