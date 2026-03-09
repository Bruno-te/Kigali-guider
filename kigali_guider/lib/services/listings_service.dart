import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing.dart';
import '../models/review.dart';

class ListingsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _listingsRef => _firestore.collection('listings');
  CollectionReference get _reviewsRef => _firestore.collection('reviews');

  // Stream of all listings (real-time)
  Stream<List<Listing>> getListings() {
    return _listingsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Listing.fromFirestore(d)).toList());
  }

  // Stream of listings by category
  Stream<List<Listing>> getListingsByCategory(String category) {
    if (category == 'All') return getListings();
    return _listingsRef
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Listing.fromFirestore(d)).toList());
  }

  // Stream of listings by current user
  Stream<List<Listing>> getMyListings(String uid) {
    return _listingsRef
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map((d) => Listing.fromFirestore(d)).toList();
          // Sort client-side to avoid requiring a composite Firestore index.
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Create a listing
  Future<String> createListing(Listing listing) async {
    final doc = await _listingsRef.add(listing.toFirestore());
    return doc.id;
  }

  // Update a listing
  Future<void> updateListing(Listing listing) async {
    await _listingsRef.doc(listing.id).update(listing.toFirestore());
  }

  // Delete a listing
  Future<void> deleteListing(String id) async {
    await _listingsRef.doc(id).delete();
    // Also delete associated reviews
    final reviewsSnap = await _reviewsRef.where('listingId', isEqualTo: id).get();
    for (final doc in reviewsSnap.docs) {
      await doc.reference.delete();
    }
  }

  // Get listing by ID (one-time)
  Future<Listing?> getListingById(String id) async {
    final doc = await _listingsRef.doc(id).get();
    if (doc.exists) return Listing.fromFirestore(doc);
    return null;
  }

  // Reviews
  Stream<List<Review>> getReviewsForListing(String listingId) {
    return _reviewsRef
        .where('listingId', isEqualTo: listingId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Review.fromFirestore(d)).toList());
  }

  Future<void> addReview(Review review) async {
    await _reviewsRef.add(review.toFirestore());

    // Update listing's average rating
    final reviewsSnap = await _reviewsRef
        .where('listingId', isEqualTo: review.listingId)
        .get();
    final reviews = reviewsSnap.docs.map((d) => Review.fromFirestore(d)).toList();
    final avgRating = reviews.isEmpty
        ? 0.0
        : reviews.fold(0.0, (sum, r) => sum + r.rating) / reviews.length;

    await _listingsRef.doc(review.listingId).update({
      'rating': avgRating,
      'reviewCount': reviews.length,
    });
  }

  // Search listings by name (client-side filtering on stream)
  Stream<List<Listing>> searchListings(String query) {
    return getListings().map((listings) => listings
        .where((l) => l.name.toLowerCase().contains(query.toLowerCase()) ||
            l.category.toLowerCase().contains(query.toLowerCase()) ||
            l.address.toLowerCase().contains(query.toLowerCase()))
        .toList());
  }
}
