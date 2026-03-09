import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import '../../widgets/listing_card.dart';
import '../listings/listing_form_screen.dart';
import '../listings/listing_detail_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  Future<bool> _confirmDelete(BuildContext context, String listingName) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Delete Listing', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Are you sure you want to delete "$listingName"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final listingsProvider = context.watch<ListingsProvider>();
    final auth = context.watch<AuthProvider>();
    final myListings = listingsProvider.myListings;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: const Text('My Listings'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ListingFormScreen()),
        ),
        backgroundColor: AppTheme.accent,
        foregroundColor: AppTheme.primaryDark,
        icon: const Icon(Icons.add),
        label: const Text('Add Listing', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: myListings.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.list_alt, color: AppTheme.textMuted, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    'No listings yet',
                    style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to add your first listing',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: myListings.length,
              itemBuilder: (ctx, i) {
                final listing = myListings[i];
                return Dismissible(
                  key: Key(listing.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return _confirmDelete(context, listing.name);
                  },
                  onDismissed: (_) async {
                    await listingsProvider.deleteListing(listing.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      ListingCard(
                        listing: listing,
                        showDistance: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: listing),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 40,
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ListingFormScreen(listing: listing),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.accent.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.edit, color: AppTheme.accent, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () async {
                            final ok = await _confirmDelete(context, listing.name);
                            if (!ok) return;
                            await listingsProvider.deleteListing(listing.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.delete, color: Colors.red, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
