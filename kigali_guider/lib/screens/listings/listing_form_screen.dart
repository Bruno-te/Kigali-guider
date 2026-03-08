import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/listing.dart';
import '../../providers/listings_provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';

class ListingFormScreen extends StatefulWidget {
  final Listing? listing; // null = create, non-null = edit

  const ListingFormScreen({super.key, this.listing});

  @override
  State<ListingFormScreen> createState() => _ListingFormScreenState();
}

class _ListingFormScreenState extends State<ListingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  String _selectedCategory = 'Café';

  bool get _isEditing => widget.listing != null;

  @override
  void initState() {
    super.initState();
    final l = widget.listing;
    _nameController = TextEditingController(text: l?.name ?? '');
    _addressController = TextEditingController(text: l?.address ?? '');
    _contactController = TextEditingController(text: l?.contactNumber ?? '');
    _descController = TextEditingController(text: l?.description ?? '');
    _latController = TextEditingController(text: l?.latitude.toString() ?? '-1.9441');
    _lngController = TextEditingController(text: l?.longitude.toString() ?? '30.0619');
    _selectedCategory = l?.category ?? 'Café';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    if (auth.user == null) return;

    final listing = Listing(
      id: widget.listing?.id ?? '',
      name: _nameController.text.trim(),
      category: _selectedCategory,
      address: _addressController.text.trim(),
      contactNumber: _contactController.text.trim(),
      description: _descController.text.trim(),
      latitude: double.tryParse(_latController.text) ?? -1.9441,
      longitude: double.tryParse(_lngController.text) ?? 30.0619,
      createdBy: auth.user!.uid,
      createdAt: widget.listing?.createdAt ?? DateTime.now(),
      rating: widget.listing?.rating ?? 0.0,
      reviewCount: widget.listing?.reviewCount ?? 0,
    );

    final provider = context.read<ListingsProvider>();
    final success = _isEditing
        ? await provider.updateListing(listing)
        : await provider.createListing(listing);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Listing updated!' : 'Listing created!'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Something went wrong'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.watch<ListingsProvider>().isSubmitting;

    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Listing' : 'Add Listing'),
        actions: [
          if (isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionLabel('Basic Information'),
            const SizedBox(height: 12),

            _buildField(
              controller: _nameController,
              hint: 'Place / Service Name',
              icon: Icons.business,
              validator: (v) => v == null || v.isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Category dropdown
            Container(
              decoration: BoxDecoration(
                color: AppTheme.inputBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppTheme.cardDark,
                style: const TextStyle(color: AppTheme.inputText),
                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.category, color: AppTheme.textMuted),
                  hintText: 'Category',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.inputBackground,
                ),
                items: AppCategories.all
                    .where((c) => c != 'All')
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(color: AppTheme.inputText)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategory = v!),
              ),
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _addressController,
              hint: 'Address',
              icon: Icons.location_on,
              validator: (v) => v == null || v.isEmpty ? 'Address is required' : null,
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _contactController,
              hint: 'Contact Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _buildField(
              controller: _descController,
              hint: 'Description',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            _SectionLabel('Location Coordinates'),
            const SizedBox(height: 4),
            const Text(
              'Enter the GPS coordinates of the location (Kigali center: -1.9441, 30.0619)',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    controller: _latController,
                    hint: 'Latitude',
                    icon: Icons.my_location,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _lngController,
                    hint: 'Longitude',
                    icon: Icons.my_location,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _handleSubmit,
                child: Text(_isEditing ? 'Save Changes' : 'Create Listing'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.inputText),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.textMuted),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
