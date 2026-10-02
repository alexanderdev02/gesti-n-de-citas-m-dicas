class Cita {
  final String id;
  final String usuarioId;
  final String profesionalId;
  final String especialidadId;
  final DateTime fechaHora;
  final String estado; // 'pendiente', 'confirmada', 'cancelada', 'completada'
  final String? motivo;

  Cita({
    required this.id,
    required this.usuarioId,
    required this.profesionalId,
    required this.especialidadId,
    required this.fechaHora,
    required this.estado,
    this.motivo,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'] ?? '',
      usuarioId: json['usuarioId'] ?? '',
      profesionalId: json['profesionalId'] ?? '',
      especialidadId: json['especialidadId'] ?? '',
      fechaHora: DateTime.parse(json['fechaHora']),
      estado: json['estado'] ?? 'pendiente',
      motivo: json['motivo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'profesionalId': profesionalId,
      'especialidadId': especialidadId,
      'fechaHora': fechaHora.toIso8601String(),
      'estado': estado,
      'motivo': motivo,
    };
  }
}
