class Profesional {
  final String id;
  final String nombreCompleto;
  final String especialidadId;
  final String especialidadNombre;
  final String telefono;
  final String email;

  Profesional({
    required this.id,
    required this.nombreCompleto,
    required this.especialidadId,
    required this.especialidadNombre,
    required this.telefono,
    required this.email,
  });

  factory Profesional.fromJson(Map<String, dynamic> json) {
    return Profesional(
      id: json['id'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      especialidadId: json['especialidadId'] ?? '',
      especialidadNombre: json['especialidadNombre'] ?? '',
      telefono: json['telefono'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'especialidadId': especialidadId,
      'especialidadNombre': especialidadNombre,
      'telefono': telefono,
      'email': email,
    };
  }
}
