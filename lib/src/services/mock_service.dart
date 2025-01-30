import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/activity.dart';

class MockActivityService {
  static List<Activity> getNearbyActivities() {
    return [
      // Bole
      Activity.mock(
        name: 'Bole Kids Swimming Academy',
        rating: 4.5,
        location: const LatLng(8.9967, 38.7991), // Bole area
        imageUrl: 'assets/swimming.jpg',
        description: 'Swimming lessons for all ages in a safe environment',
      ),
      Activity.mock(
        name: 'Bole Creative Arts Center',
        rating: 4.6,
        location: const LatLng(8.9900, 38.7900),
        imageUrl: 'assets/art_studio.jpg',
        description: 'Art and craft workshops for children',
      ),

      // Kazanchis
      Activity.mock(
        name: 'Kazanchis Science Hub',
        rating: 4.7,
        location: const LatLng(9.0253, 38.7638), // Kazanchis area
        imageUrl: 'assets/science_center.jpg',
        description: 'Interactive science exhibits and workshops',
      ),

      // Piassa
      Activity.mock(
        name: 'Piassa Cultural Center',
        rating: 4.4,
        location: const LatLng(9.0301, 38.7589), // Piassa area
        imageUrl: 'assets/library.jpg',
        description: 'Cultural activities and reading programs',
      ),

      // Kirkos
      Activity.mock(
        name: 'Kirkos Martial Arts Dojo',
        rating: 4.4,
        location: const LatLng(9.0163, 38.7689), // Kirkos area
        imageUrl: 'assets/martial_arts.jpg',
        description: 'Traditional martial arts training',
      ),

      // Nifas Silk
      Activity.mock(
        name: 'Nifas Silk Playground',
        rating: 4.6,
        location: const LatLng(9.0189, 38.7724), // Nifas Silk area
        imageUrl: 'assets/kids_park.jpg',
        description: 'Outdoor playground with modern equipment',
      ),

      // Arada
      Activity.mock(
        name: 'Arada Music Academy',
        rating: 4.5,
        location: const LatLng(9.0248, 38.7493), // Arada area
        imageUrl: 'assets/music_academy.jpg',
        description: 'Music lessons for all ages',
      ),

      // Yeka
      Activity.mock(
        name: 'Yeka Robotics Lab',
        rating: 4.7,
        location: const LatLng(9.0087, 38.7556), // Yeka area
        imageUrl: 'assets/robotics.jpg',
        description: 'STEM and robotics workshops',
      ),

      // Gullele
      Activity.mock(
        name: 'Gullele Nature Explorers',
        rating: 4.8,
        location: const LatLng(9.0192, 38.7525), // Gullele area
        imageUrl: 'assets/gym.jpg',
        description: 'Outdoor activities and nature exploration',
      ),

      // Kolfe Keranio
      Activity.mock(
        name: 'Kolfe Dance Studio',
        rating: 4.4,
        location: const LatLng(9.0124, 38.7612), // Kolfe area
        imageUrl: 'assets/dance_school.jpg',
        description: 'Dance classes including traditional styles',
      ),

      // Akaki Kality
      Activity.mock(
        name: 'Akaki Sports Complex',
        rating: 4.3,
        location: const LatLng(8.9000, 38.7000), // Akaki area
        imageUrl: 'assets/cooking_school.jpg',
        description: 'Sports training and activities',
      ),

      // Lideta
      Activity.mock(
        name: 'Lideta Creative Hub',
        rating: 4.5,
        location: const LatLng(9.0225, 38.7467), // Lideta area
        imageUrl: 'assets/art_studio.jpg',
        description: 'Creative workshops and art classes',
      ),
    ];
  }
}
