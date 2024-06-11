import 'package:cloud_firestore/cloud_firestore.dart';

class Cita {
  final String id;
  final DocumentReference doctor;
  final DocumentReference paciente;
  final DateTime fecha;
  final String motivo;
  final String estado;

  Cita({
    required this.id,
    required this.doctor,
    required this.paciente,
    required this.fecha,
    required this.motivo,
    required this.estado,
  });

  factory Cita.fromFirestore(DocumentSnapshot cita) {
    Map<String, dynamic> data = cita.data() as Map<String, dynamic>;
    return Cita(
      id: cita.id,
      doctor: data['doctor'] as DocumentReference,
      paciente: data['paciente'] as DocumentReference,
      fecha: (data['fecha'] as Timestamp).toDate(),
      motivo: data['motivo'] ?? '',
      estado: data['estado'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctor': doctor,
      'paciente': paciente,
      'fecha': fecha,
      'motivo': motivo,
      'estado': estado,
    };
  }
}

class Doctor {
  final String id;
  final String nombre;
  final String especialidad;
  final String horario;
  final String url;

  Doctor({
    required this.id,
    required this.nombre,
    required this.especialidad,
    required this.horario,
    required this.url,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doctor) {
    Map<String, dynamic> data = doctor.data() as Map<String, dynamic>;
    return Doctor(
      id: doctor.id,
      nombre: data['nombre'] ?? '',
      especialidad: data['especialidad'] ?? '',
      horario: data['horario'] ?? '',
      url: data['url'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'especialidad': especialidad,
      'horario': horario,
      'url': url,
    };
  }
}

class Paciente {
  final String id;
  final String nombre;
  final int edad;
  final String descripcion;

  Paciente({
    required this.id,
    required this.nombre,
    required this.edad,
    required this.descripcion,
  });

  factory Paciente.fromFirestore(DocumentSnapshot paciente) {
    Map<String, dynamic> data = paciente.data() as Map<String, dynamic>;
    return Paciente(
      id: paciente.id,
      nombre: data['nombre'] ?? '',
      edad: data['edad'] ?? 0,
      descripcion: data['descripcion'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nombre': nombre,
      'edad': edad,
      'descripcion': descripcion,
    };
  }
}
