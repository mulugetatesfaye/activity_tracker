import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

enum ActivityCategory {
  sports,
  arts,
  education,
  swimming,
  dance,
  reading,
  cooking,
  outdoor,
  stem,
  music,
  martialArts
}

class Activity {
  final String id;
  final String name;
  final ActivityCategory category;
  final LatLng location;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final PriceInfo price;
  final AgeRange ageRange;
  final Duration duration;
  final ContactInfo contact;
  final bool isFeatured;
  final DateTime createdAt;

  Activity({
    required this.name,
    required this.category,
    required this.location,
    required this.imageUrl,
    required this.description,
    this.rating = 0.0,
    this.reviewCount = 0,
    required this.price,
    required this.ageRange,
    required this.duration,
    required this.contact,
    this.isFeatured = false,
  })  : id = const Uuid().v4(),
        createdAt = DateTime.now();

  // Factory method for mock data
  factory Activity.mock({
    required String name,
    required LatLng location,
    required String imageUrl,
    required String description,
    double rating = 0.0,
    ActivityCategory? category,
  }) {
    // Default values for mock data
    final defaultCategory = _determineCategoryFromName(name);
    final defaultPrice = PriceInfo(basePrice: 500, pricingType: 'per session');
    final defaultAgeRange = AgeRange(minAge: 5, maxAge: 12);
    const defaultDuration = Duration(hours: 1);
    final defaultContact = ContactInfo(
      phone: '+251 911 234 567',
      email: 'info@activity.com',
      website: 'https://activity.com',
      socialMedia: SocialMedia(),
    );

    return Activity(
      name: name,
      category: category ?? defaultCategory,
      location: location,
      imageUrl: imageUrl,
      description: description,
      rating: rating,
      price: defaultPrice,
      ageRange: defaultAgeRange,
      duration: defaultDuration,
      contact: defaultContact,
    );
  }

  static ActivityCategory _determineCategoryFromName(String name) {
    if (name.contains('Gym')) return ActivityCategory.sports;
    if (name.contains('Art')) return ActivityCategory.arts;
    if (name.contains('Science')) return ActivityCategory.education;
    if (name.contains('Swimming')) return ActivityCategory.swimming;
    if (name.contains('Dance')) return ActivityCategory.dance;
    if (name.contains('Library')) return ActivityCategory.reading;
    if (name.contains('Cooking')) return ActivityCategory.cooking;
    if (name.contains('Park')) return ActivityCategory.outdoor;
    if (name.contains('Robotics')) return ActivityCategory.stem;
    if (name.contains('Music')) return ActivityCategory.music;
    if (name.contains('Martial Arts')) return ActivityCategory.martialArts;
    return ActivityCategory.education;
  }
}

// Supporting Classes
class ContactInfo {
  final String phone;
  final String email;
  final String website;
  final SocialMedia socialMedia;

  ContactInfo({
    required this.phone,
    required this.email,
    required this.website,
    required this.socialMedia,
  });
}

class SocialMedia {
  final String? facebook;
  final String? instagram;
  final String? twitter;

  SocialMedia({this.facebook, this.instagram, this.twitter});
}

class PriceInfo {
  final double basePrice;
  final double? discountPrice;
  final String currency;
  final String pricingType;

  PriceInfo({
    required this.basePrice,
    this.discountPrice,
    this.currency = 'ETB',
    required this.pricingType,
  });
}

class AgeRange {
  final int minAge;
  final int maxAge;

  AgeRange({required this.minAge, required this.maxAge});
}
