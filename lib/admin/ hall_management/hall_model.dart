class Hall {
  final String id;
  final String name;
  final int capacity;
  final String location;
  final double pricePerHour;
  final bool available;

  Hall({
    required this.id,
    required this.name,
    required this.capacity,
    required this.location,
    required this.pricePerHour,
    required this.available,
  });

  factory Hall.fromMap(String id, Map<String, dynamic> data) {
    return Hall(
      id: id,
      name: data['name'],
      capacity: data['capacity'],
      location: data['location'],
      pricePerHour: data['pricePerHour'].toDouble(),
      available: data['available'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'capacity': capacity,
      'location': location,
      'pricePerHour': pricePerHour,
      'available': available,
    };
  }
}
