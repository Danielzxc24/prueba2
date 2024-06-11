import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/modelos.dart';

class CitaRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarCita(Cita cita) async {
    await _db.collection('cita').add(cita.toFirestore());
  }

  Stream<List<Cita>> obtenerCitas() {
    return _db.collection('cita').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Cita.fromFirestore(doc)).toList());
  }

  Future<Cita?> obtenerCitaPorId(String id) async {
    final doc = await _db.collection('cita').doc(id).get();
    if (doc.exists) {
      return Cita.fromFirestore(doc);
    }
    return null;
  }

  Future<void> actualizarCita(Cita cita) async {
    await _db.collection('cita').doc(cita.id).update(cita.toFirestore());
  }

  Future<void> eliminarCita(String id) async {
    await _db.collection('cita').doc(id).delete();
  }
}

class DoctorRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarDoctor(Doctor doctor) async {
    await _db.collection('doctor').add(doctor.toFirestore());
  }

  Stream<List<Doctor>> obtenerDoctores() {
    return _db.collection('doctor').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Doctor.fromFirestore(doc)).toList());
  }

  Future<Doctor?> obtenerDoctorPorId(String id) async {
    final doc = await _db.collection('doctor').doc(id).get();
    if (doc.exists) {
      return Doctor.fromFirestore(doc);
    }
    return null;
  }

  Future<void> actualizarDoctor(Doctor doctor) async {
    await _db.collection('doctor').doc(doctor.id).update(doctor.toFirestore());
  }

  Future<void> eliminarDoctor(String id) async {
    await _db.collection('doctor').doc(id).delete();
  }
}

class PacienteRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> agregarPaciente(Paciente paciente) async {
    await _db.collection('paciente').add(paciente.toFirestore());
  }

  Stream<List<Paciente>> obtenerPacientes() {
    return _db.collection('paciente').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Paciente.fromFirestore(doc)).toList());
  }

  Future<Paciente?> obtenerPacientePorId(String id) async {
    final doc = await _db.collection('paciente').doc(id).get();
    if (doc.exists) {
      return Paciente.fromFirestore(doc);
    }
    return null;
  }

  Future<void> actualizarPaciente(Paciente paciente) async {
    await _db
        .collection('paciente')
        .doc(paciente.id)
        .update(paciente.toFirestore());
  }

  Future<void> eliminarPaciente(String id) async {
    await _db.collection('paciente').doc(id).delete();
  }
}
