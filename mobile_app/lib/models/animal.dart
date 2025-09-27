class Animal {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String gender;
  final String description;
  final List<String> imageUrls;
  final String shelterId;
  final String shelterName;
  final String shelterAddress;
  final bool isAdopted;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? medicalHistory;
  final String? temperament;
  final bool isVaccinated;
  final bool isNeutered;
  final double? weight;

  const Animal({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    required this.gender,
    required this.description,
    required this.imageUrls,
    required this.shelterId,
    required this.shelterName,
    required this.shelterAddress,
    required this.isAdopted,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.isVaccinated,
    required this.isNeutered,
    this.medicalHistory,
    this.temperament,
    this.weight,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => Animal(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      description: json['description'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)?.cast<String>() ?? [],
      shelterId: json['shelter_id'] as String,
      shelterName: (json['shelters'] as Map<String, dynamic>?)?['name'] 
          as String? ?? '',
      shelterAddress: (json['shelters'] as Map<String, dynamic>?)?['address'] 
          as String? ?? '',
      isAdopted: json['is_adopted'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isVaccinated: json['is_vaccinated'] as bool? ?? false,
      isNeutered: json['is_neutered'] as bool? ?? false,
      medicalHistory: json['medical_history'] as String?,
      temperament: json['temperament'] as String?,
      weight: (json['weight'] as num?)?.toDouble(),
    );

  Animal copyWith({
    String? id,
    String? name,
    String? species,
    String? breed,
    int? age,
    String? gender,
    String? description,
    List<String>? imageUrls,
    String? shelterId,
    String? shelterName,
    String? shelterAddress,
    bool? isAdopted,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? medicalHistory,
    String? temperament,
    bool? isVaccinated,
    bool? isNeutered,
    double? weight,
  }) => Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      shelterId: shelterId ?? this.shelterId,
      shelterName: shelterName ?? this.shelterName,
      shelterAddress: shelterAddress ?? this.shelterAddress,
      isAdopted: isAdopted ?? this.isAdopted,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      temperament: temperament ?? this.temperament,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isNeutered: isNeutered ?? this.isNeutered,
      weight: weight ?? this.weight,
    );

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'age': age,
      'gender': gender,
      'description': description,
      'image_urls': imageUrls,
      'shelter_id': shelterId,
      'is_adopted': isAdopted,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'medical_history': medicalHistory,
      'temperament': temperament,
      'is_vaccinated': isVaccinated,
      'is_neutered': isNeutered,
      'weight': weight,
    };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Animal && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'Animal(id: $id, name: $name, species: $species, breed: $breed)';
}