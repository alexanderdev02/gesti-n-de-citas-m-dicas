import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cita.dart';

class CitaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'citas';

  // 1. Crear una nueva cita
  Future<void> crearCita(Cita cita) async {
    try {
      DocumentReference docRef = _firestore.collection(_collection).doc();
      Cita nuevaCita = Cita(
        id: docRef.id,
        usuarioId: cita.usuarioId,
        profesionalId: cita.profesionalId,
        especialidadId: cita.especialidadId,
        fechaHora: cita.fechaHora,
        estado: cita.estado.isEmpty ? 'pendiente' : cita.estado,
        motivo: cita.motivo,
      );
      await docRef.set(nuevaCita.toJson());
    } catch (e) {
      throw Exception('Error al agendar la cita: $e');
    }
  }

  // 2. Obtener todas las citas de un usuario específico en tiempo real
  Stream<List<Cita>> obtenerCitasPorUsuario(String usuarioId) {
    return _firestore
        .collection(_collection)
        .where('usuarioId', isEqualTo: usuarioId)
        .orderBy('fechaHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cita.fromJson(doc.data()))
            .toList());
  }

  // 3. Obtener todas las citas de un profesional médico en tiempo real
  Stream<List<Cita>> obtenerCitasPorProfesional(String profesionalId) {
    return _firestore
        .collection(_collection)
        .where('profesionalId', isEqualTo: profesionalId)
        .orderBy('fechaHora', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Cita.fromJson(doc.data()))
            .toList());
  }

  // 4. Actualizar estado de una cita (ej. 'confirmada', 'cancelada', 'completada')
  Future<void> actualizarEstadoCita(String citaId, String nuevoEstado) async {
    try {
      await _firestore.collection(_collection).doc(citaId).update({
        'estado': nuevoEstado,
      });
    } catch (e) {
      throw Exception('Error al actualizar la cita: $e');
    }
  }

  // 5. Cancelar cita
  Future<void> cancelarCita(String citaId) async {
    try {
      await actualizarEstadoCita(citaId, 'cancelada');
    } catch (e) {
      throw Exception('Error al cancelar la cita: $e');
    }
  }

  // 6. Eliminar cita permanentemente
  Future<void> eliminarCita(String citaId) async {
    try {
      await _firestore.collection(_collection).doc(citaId).delete();
    } catch (e) {
      throw Exception('Error al eliminar la cita: $e');
    }
  }
}
