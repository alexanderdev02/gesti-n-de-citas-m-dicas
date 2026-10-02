class Usuario {
  final String id;
  final String nombreCompleto;
  final String email;
  final String telefono;
  final String rol; // 'paciente', 'medico', 'admin'

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
    required this.telefono,
    required this.rol,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombreCompleto: json['nombreCompleto'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'paciente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombreCompleto': nombreCompleto,
      'email': email,
      'telefono': telefono,
      'rol': rol,
    };
  }
}
