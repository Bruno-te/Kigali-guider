import 'dart:async';
import 'package:flutter/material.dart';
import '../models/listing.dart';
import '../models/review.dart';
import '../services/listings_service.dart';

enum ListingsStatus { initial, loading, loaded, error }

class ListingsProvider extends ChangeNotifier {
  final ListingsService _service = ListingsService();

  ListingsStatus _status = ListingsStatus.initial;
  List<Listing> _allListings = [];
  List<Listing> _filteredListings = [];
  List<Listing> _myListings = [];
  List<Review> _reviews = [];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  String? _errorMessage;
  bool _isSubmitting = false;

  StreamSubscription<List<Listing>>? _listingsSubscription;
  StreamSubscription<List<Listing>>? _myListingsSubscription;
  StreamSubscription<List<Review>>? _reviewsSubscription;

  ListingsStatus get status => _status;
  List<Listing> get filteredListings => _filteredListings;
  List<Listing> get myListings => _myListings;
  List<Review> get reviews => _reviews;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get isSubmitting => _isSubmitting;

  void init(String? uid) {
    _subscribeToListings();
    if (uid != null) _subscribeToMyListings(uid);
  }

  void _subscribeToListings() {
    _listingsSubscription?.cancel();
    _status = ListingsStatus.loading;
    notifyListeners();

    _listingsSubscription = _service.getListings().listen(
      (listings) {
        _allListings = listings;
        _applyFilters();
        _status = ListingsStatus.loaded;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _status = ListingsStatus.error;
        notifyListeners();
      },
    );
  }

  void _subscribeToMyListings(String uid) {
    _myListingsSubscription?.cancel();
    _myListingsSubscription = _service.getMyListings(uid).listen(
      (listings) {
        _myListings = listings;
        notifyListeners();
      },
    );
  }

  void subscribeToReviews(String listingId) {
    _reviewsSubscription?.cancel();
    _reviewsSubscription = _service.getReviewsForListing(listingId).listen(
      (reviews) {
        _reviews = reviews;
        notifyListeners();
      },
    );
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var filtered = List<Listing>.from(_allListings);

    if (_selectedCategory != 'All') {
      filtered = filtered.where((l) => l.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered
          .where((l) =>
              l.name.toLowerCase().contains(q) ||
              l.category.toLowerCase().contains(q) ||
              l.address.toLowerCase().contains(q) ||
              l.description.toLowerCase().contains(q))
          .toList();
    }

    _filteredListings = filtered;
  }

  Future<bool> createListing(Listing listing) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.createListing(listing);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateListing(Listing listing) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.updateListing(listing);
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteListing(String id) async {
    try {
      await _service.deleteListing(id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addReview(Review review) async {
    try {
      await _service.addReview(review);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _listingsSubscription?.cancel();
    _myListingsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    super.dispose();
  }
}
