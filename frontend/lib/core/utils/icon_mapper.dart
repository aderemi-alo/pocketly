import 'package:flutter/material.dart';

/// Utility class to map icon code points to constant IconData instances
/// This prevents tree-shaking issues when building for web
class IconMapper {
  // Common Material Icons used in the app
  static final Map<int, IconData> _iconMap = {
    // Food & Dining
    0xe7fd: Icons.restaurant, // restaurant
    0xe7fe: Icons.local_pizza, // local_pizza
    0xe7ff: Icons.local_cafe, // local_cafe
    0xe800: Icons.fastfood, // fastfood
    0xe801: Icons.local_dining, // local_dining
    0xe802: Icons.cake, // cake
    0xe803: Icons.local_bar, // local_bar
    // Transportation
    0xe804: Icons.directions_car, // directions_car
    0xe805: Icons.directions_bus, // directions_bus
    0xe806: Icons.train, // train
    0xe807: Icons.flight, // flight
    0xe808: Icons.directions_walk, // directions_walk
    0xe809: Icons.directions_bike, // directions_bike
    0xe80a: Icons.motorcycle, // motorcycle
    // Shopping
    0xe80b: Icons.shopping_cart, // shopping_cart
    0xe80c: Icons.shopping_bag, // shopping_bag
    0xe80d: Icons.store, // store
    0xe80e: Icons.local_grocery_store, // local_grocery_store
    0xe80f: Icons.shopping_basket, // shopping_basket
    // Entertainment
    0xe810: Icons.movie, // movie
    0xe811: Icons.music_note, // music_note
    0xe812: Icons.sports_esports, // sports_esports
    0xe813: Icons.sports_soccer, // sports_soccer
    0xe814: Icons.sports_basketball, // sports_basketball
    0xe815: Icons.sports_tennis, // sports_tennis
    0xe816: Icons.sports_volleyball, // sports_volleyball
    // Health & Medical
    0xe817: Icons.local_hospital, // local_hospital
    0xe818: Icons.medical_services, // medical_services
    0xe819: Icons.medication, // medication
    0xe81a: Icons.fitness_center, // fitness_center
    0xe81b: Icons.spa, // spa
    // Home & Utilities
    0xe81c: Icons.home, // home
    0xe81d: Icons.electrical_services, // electrical_services
    0xe81e: Icons.water_drop, // water_drop
    0xe81f: Icons.local_gas_station, // local_gas_station
    0xe820: Icons.wifi, // wifi
    0xe821: Icons.phone, // phone
    0xe822: Icons.wifi, // internet (using wifi as fallback)
    // Education
    0xe823: Icons.school, // school
    0xe824: Icons.book, // book
    0xe825: Icons.library_books, // library_books
    0xe826: Icons.computer, // computer
    // Work & Business
    0xe827: Icons.work, // work
    0xe828: Icons.business, // business
    0xe829: Icons.meeting_room, // meeting_room
    0xe82a: Icons.laptop, // laptop
    // Travel & Vacation
    0xe82b: Icons.hotel, // hotel
    0xe82c: Icons.beach_access, // beach_access
    0xe82d: Icons.landscape, // landscape
    0xe82e: Icons.camera_alt, // camera_alt
    // Personal Care
    0xe82f: Icons.face, // face
    0xe830: Icons.content_cut, // content_cut
    0xe831: Icons.cleaning_services, // cleaning_services
    0xe832: Icons.dry_cleaning, // dry_cleaning
    // Miscellaneous
    0xe833: Icons.attach_money, // attach_money
    0xe834: Icons.account_balance, // account_balance
    0xe835: Icons.credit_card, // credit_card
    0xe836: Icons.savings, // savings
    0xe837: Icons.receipt, // receipt
    0xe838: Icons.pets, // pets
    0xe839: Icons.child_care, // child_care
    0xe83a: Icons.elderly, // elderly
    0xe83b: Icons.family_restroom, // family_restroom
    // Default fallback icons
    0xe83c: Icons.category, // category
    0xe83d: Icons.label, // label
    0xe83e: Icons.tag, // tag
    0xe83f: Icons.star, // star
    0xe840: Icons.favorite, // favorite
  };

  /// Get a constant IconData instance for the given code point
  /// Falls back to a default icon if the code point is not found
  static IconData getIcon(int codePoint) {
    return _iconMap[codePoint] ?? Icons.category;
  }

  /// Get the code point for a given IconData
  static int getCodePoint(IconData iconData) {
    return iconData.codePoint;
  }

  /// Check if a code point has a predefined constant icon
  static bool hasIcon(int codePoint) {
    return _iconMap.containsKey(codePoint);
  }

  /// Get all available icon code points
  static List<int> getAvailableCodePoints() {
    return _iconMap.keys.toList();
  }
}
