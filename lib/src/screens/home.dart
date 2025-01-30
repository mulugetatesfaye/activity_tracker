import 'package:activity_tracker/constants/map_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:activity_tracker/src/models/activity.dart';
import 'package:activity_tracker/src/services/mock_service.dart';
import 'package:activity_tracker/src/widgets/activity_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  List<Activity> activities = [];
  List<Activity> filteredActivities = [];
  Activity? selectedActivity;
  LatLng? _currentLocation;
  bool _locationLoaded = false;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<Activity> _searchResults = [];

  @override
  void initState() {
    super.initState();
    activities = MockActivityService.getNearbyActivities();
    filteredActivities = List.from(activities);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
      _locationLoaded = true;
    });

    mapController.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 14),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Apply the dark theme style
    controller.setMapStyle(mapStyle);
    if (_currentLocation != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
      );
    }
  }

  void _showActivityDetails(Activity activity) {
    setState(() => selectedActivity = activity);
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPopupSurface(
        child: ActivityDetailsSheet(activity: activity),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return activities
        .map((activity) => Marker(
              markerId: MarkerId(activity.id),
              position: activity.location,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue),
              onTap: () => _showActivityDetails(activity),
            ))
        .toSet();
  }

  void _zoomToFitMarkers() {
    LatLngBounds bounds = filteredActivities.fold<LatLngBounds>(
      LatLngBounds(
        southwest: LatLng(filteredActivities.first.location.latitude,
            filteredActivities.first.location.longitude),
        northeast: LatLng(filteredActivities.first.location.latitude,
            filteredActivities.first.location.longitude),
      ),
      (previous, activity) {
        final lat = activity.location.latitude;
        final lng = activity.location.longitude;
        return LatLngBounds(
          southwest: LatLng(
            lat < previous.southwest.latitude
                ? lat
                : previous.southwest.latitude,
            lng < previous.southwest.longitude
                ? lng
                : previous.southwest.longitude,
          ),
          northeast: LatLng(
            lat > previous.northeast.latitude
                ? lat
                : previous.northeast.latitude,
            lng > previous.northeast.longitude
                ? lng
                : previous.northeast.longitude,
          ),
        );
      },
    );

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Nearby Activities'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.search),
          onPressed: () => _showSearchDialog(context),
        ),
      ),
      child: _locationLoaded
          ? Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation ?? const LatLng(9.0192, 38.7525),
                    zoom: 14.0,
                  ),
                  markers: _createMarkers(),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  onTap: (position) => setState(() => selectedActivity = null),
                  compassEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                ),
                Positioned(
                  top: 16, // Adjusted position below navigation bar
                  left: 0,
                  right: 0,
                  child: _buildActivityCards(),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: CupertinoButton(
                    color: CupertinoColors.systemBlue,
                    padding: const EdgeInsets.all(16),
                    borderRadius: BorderRadius.circular(30),
                    child: const Icon(CupertinoIcons.location_solid,
                        color: CupertinoColors.white),
                    onPressed: () {
                      mapController.animateCamera(
                        CameraUpdate.newLatLngZoom(_currentLocation!, 14),
                      );
                    },
                  ),
                ),
              ],
            )
          : const Center(
              child: CupertinoActivityIndicator(radius: 16),
            ),
    );
  }

  Widget _buildActivityCards() {
    return SizedBox(
      height: 100, // Reduced height for smaller cards
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredActivities.length,
        itemBuilder: (context, index) {
          final activity = filteredActivities[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildActivityCard(activity),
          );
        },
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return GestureDetector(
      onTap: () => _showActivityDetails(activity),
      child: Container(
        width: 200, // Reduced width for smaller cards
        decoration: BoxDecoration(
          color: CupertinoColors.systemBackground.resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: CupertinoColors.systemGrey.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on the left
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: Image.network(
                activity.imageUrl,
                width: 80, // Fixed width for the image
                height: 120, // Match the card height
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 80,
                  height: 120,
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(CupertinoIcons.photo),
                ),
              ),
            ),
            // Content on the right
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.star_fill,
                          size: 12,
                          color: CupertinoColors.systemYellow,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          activity.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.location_solid,
                          size: 12,
                          color: CupertinoColors.systemGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${calculateDistance(activity).toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.secondaryLabel
                                .resolveFrom(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                            CupertinoColors.secondaryLabel.resolveFrom(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateDistance(Activity activity) {
    if (_currentLocation == null) return 0;
    return Geolocator.distanceBetween(
          _currentLocation!.latitude,
          _currentLocation!.longitude,
          activity.location.latitude,
          activity.location.longitude,
        ) /
        1000; // Convert to kilometers
  }

  void _showSearchDialog(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoPopupSurface(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search activities...',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                    _updateSearchResults();
                  });
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _searchQuery.isEmpty
                    ? _buildRecentSearches()
                    : _buildSearchSuggestions(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateSearchResults() {
    _searchResults = activities.where((activity) {
      return activity.name.toLowerCase().contains(_searchQuery) ||
          activity.description.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  Widget _buildSearchSuggestions() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text(
          'No results found',
          style: TextStyle(
            color: CupertinoColors.secondaryLabel.resolveFrom(context),
          ),
        ),
      );
    }

    return CupertinoScrollbar(
      child: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final activity = _searchResults[index];
          return CupertinoListTile(
            title: Text(activity.name),
            subtitle: Text(
              activity.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: () {
              Navigator.pop(context);
              _showActivityDetails(activity);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Center(
      child: Text(
        'Start typing to search activities',
        style: TextStyle(
          color: CupertinoColors.secondaryLabel.resolveFrom(context),
        ),
      ),
    );
  }

  void _filterActivities() {
    setState(() {
      filteredActivities = activities.where((activity) {
        final categoryMatch = _selectedCategory == 'All' ||
            activity.category.toString().contains(_selectedCategory);
        final searchMatch =
            activity.name.toLowerCase().contains(_searchQuery) ||
                activity.description.toLowerCase().contains(_searchQuery);
        return categoryMatch && searchMatch;
      }).toList();
    });

    if (filteredActivities.isNotEmpty) {
      _zoomToFitMarkers();
    }
  }

  Widget _buildFilterOption(String category) {
    return CupertinoButton(
      child: Row(
        children: [
          Icon(
            _selectedCategory == category
                ? CupertinoIcons.checkmark_alt_circle_fill
                : CupertinoIcons.circle,
            color: _selectedCategory == category
                ? CupertinoColors.activeBlue
                : CupertinoColors.secondaryLabel,
          ),
          const SizedBox(width: 12),
          Text(category),
        ],
      ),
      onPressed: () {
        setState(() => _selectedCategory = category);
        _filterActivities();
        Navigator.pop(context);
      },
    );
  }
}
