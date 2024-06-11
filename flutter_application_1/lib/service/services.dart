import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/repository/repositories.dart';
import '../model/modelos.dart';

class CitaService {
  final CitaRepository _repository = CitaRepository();

  Future<void> agregarCita(Cita cita) async {
    await _repository.agregarCita(cita);
  }

  Stream<List<Cita>> obtenerCitas() {
    return _repository.obtenerCitas();
  }

  Future<Cita?> obtenerCitaPorId(String id) async {
    return await _repository.obtenerCitaPorId(id);
  }

  Future<void> actualizarCita(Cita cita) async {
    await _repository.actualizarCita(cita);
  }

  Future<void> eliminarCita(String id) async {
    await _repository.eliminarCita(id);
  }
}

class DoctorService {
  final DoctorRepository _repository = DoctorRepository();

  Future<void> agregarDoctor(Doctor doctor) async {
    await _repository.agregarDoctor(doctor);
  }

  Stream<List<Doctor>> obtenerDoctores() {
    return _repository.obtenerDoctores();
  }

  Future<Doctor?> obtenerDoctorPorId(String id) async {
    return await _repository.obtenerDoctorPorId(id);
  }

  Future<void> actualizarDoctor(Doctor doctor) async {
    await _repository.actualizarDoctor(doctor);
  }

  Future<void> eliminarDoctor(String id) async {
    await _repository.eliminarDoctor(id);
  }

  Future<Doctor> obtenerDoctorPorReferencia(
      DocumentReference referencia) async {
    DocumentSnapshot doctorSnapshot = await referencia.get();

    if (doctorSnapshot.exists) {
      Doctor doctor = Doctor.fromFirestore(doctorSnapshot);
      return doctor;
    } else {
      return Doctor(id: '', nombre: '', especialidad: '', horario: '', url: '');
    }
  }
}

class PacienteService {
  final PacienteRepository _repository = PacienteRepository();

  Future<void> agregarPaciente(Paciente paciente) async {
    await _repository.agregarPaciente(paciente);
  }

  Stream<List<Paciente>> obtenerPacientes() {
    return _repository.obtenerPacientes();
  }

  Future<Paciente?> obtenerPacientePorId(String id) async {
    return await _repository.obtenerPacientePorId(id);
  }

  Future<void> actualizarPaciente(Paciente paciente) async {
    await _repository.actualizarPaciente(paciente);
  }

  Future<void> eliminarPaciente(String id) async {
    await _repository.eliminarPaciente(id);
  }

  Future<Paciente> obtenerPacientePorReferencia(
      DocumentReference referencia) async {
    String id = referencia.id;

    Paciente? paciente = await obtenerPacientePorId(id);
    return paciente ?? Paciente(id: '', nombre: '', edad: 0, descripcion: '');
  }
}
