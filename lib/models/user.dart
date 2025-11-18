// Models for authentication: User and Address
// Generated minimal, dependency-free model classes with JSON (de)serialization

class Address {
  final String line;
  final String city;
  final String postcode;

  const Address({
    required this.line,
    required this.city,
    required this.postcode,
  });

  Address copyWith({String? line, String? city, String? postcode}) {
    return Address(
      line: line ?? this.line,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      line: json['line'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'line': line,
    'city': city,
    'postcode': postcode,
  };

  @override
  String toString() => 'Address(line: $line, city: $city, postcode: $postcode)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Address &&
          runtimeType == other.runtimeType &&
          line == other.line &&
          city == other.city &&
          postcode == other.postcode;

  @override
  int get hashCode => line.hashCode ^ city.hashCode ^ postcode.hashCode;
}

class User {
  final String id;
  final String name;
  final String email;
  final Address? address;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.address,
  });

  User copyWith({String? id, String? name, String? email, Address? address}) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      address:
          json['address'] != null && json['address'] is Map<String, dynamic>
          ? Address.fromJson(Map<String, dynamic>.from(json['address']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    if (address != null) 'address': address!.toJson(),
  };

  @override
  String toString() =>
      'User(id: $id, name: $name, email: $email, address: $address)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          email == other.email &&
          address == other.address;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ email.hashCode ^ (address?.hashCode ?? 0);
}
