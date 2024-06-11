import 'package:flutter/material.dart';
import 'package:flutter_application_1/model/modelos.dart';
import 'package:flutter_application_1/service/services.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CitaService _citaService = CitaService();
  final DoctorService _doctorService = DoctorService();
  final PacienteService _pacienteService = PacienteService();

  Doctor? _selectedDoctor;
  Paciente? _selectedPaciente;
  String? _selectedDoctorId;
  String? _selectedPacienteId;
  String? _estado;
  DateTime? _fecha;
  final TextEditingController _motivoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Citas'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Crear Doctor'),
              onTap: () {
                context.go('/doctor');
              },
            ),
            ListTile(
              title: Text('Crear Paciente'),
              onTap: () {
                context.go('/paciente');
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _mostrarAgregarCitaDialog(context);
                },
                child: Text('Agregar Cita'),
              ),
            ],
          ),
          Expanded(
            child: StreamBuilder<List<Cita>>(
              stream: _citaService.obtenerCitas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text('No hay citas disponibles.'),
                  );
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final cita = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        title: FutureBuilder<Doctor>(
                          future: _doctorService
                              .obtenerDoctorPorReferencia(cita.doctor),
                          builder: (context, doctorSnapshot) {
                            if (doctorSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Cargando doctor...');
                            }
                            if (doctorSnapshot.hasData) {
                              return Text(
                                  'Doctor: ${doctorSnapshot.data!.nombre}');
                            } else {
                              return Text('Doctor no encontrado');
                            }
                          },
                        ),
                        subtitle: FutureBuilder<Paciente>(
                          future: _pacienteService
                              .obtenerPacientePorReferencia(cita.paciente),
                          builder: (context, pacienteSnapshot) {
                            if (pacienteSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Text('Cargando paciente...');
                            }
                            if (pacienteSnapshot.hasData) {
                              return Text(
                                  'Paciente: ${pacienteSnapshot.data!.nombre}');
                            } else {
                              return Text('Paciente no encontrado');
                            }
                          },
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                _mostrarEditarCitaDialog(context, cita);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                _eliminarCita(context, cita);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.details),
                              onPressed: () {
                                _mostrarDetallesCitaDialog(context, cita);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String? currentValue,
    Stream<List<dynamic>> itemsStream,
    void Function(String?) onChanged,
  ) {
    return StreamBuilder<List<dynamic>>(
      stream: itemsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No hay $label disponibles.');
        }

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
          ),
          value: currentValue,
          onChanged: onChanged,
          items: snapshot.data!.map<DropdownMenuItem<String>>((item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text(item.nombre),
            );
          }).toList(),
        );
      },
    );
  }

  void _mostrarAgregarCitaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Agregar Cita'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildDropdown(
                  'Doctor',
                  _selectedDoctorId,
                  _doctorService.obtenerDoctores(),
                  (String? newValue) {
                    setState(() {
                      _selectedDoctorId = newValue;
                    });
                  },
                ),
                _buildDropdown(
                  'Paciente',
                  _selectedPacienteId,
                  _pacienteService.obtenerPacientes(),
                  (String? newValue) {
                    setState(() {
                      _selectedPacienteId = newValue;
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Estado',
                    border: OutlineInputBorder(),
                  ),
                  value: _estado,
                  onChanged: (String? newValue) {
                    setState(() {
                      _estado = newValue;
                    });
                  },
                  items: ['Pendiente', 'Confirmada', 'Cancelada']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Fecha',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _fecha = pickedDate;
                      });
                    }
                  },
                  controller: TextEditingController(
                    text: _fecha != null ? _fecha.toString().split(' ')[0] : '',
                  ),
                ),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Motivo',
                    border: OutlineInputBorder(),
                  ),
                  controller: _motivoController,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedDoctorId != null &&
                    _selectedPacienteId != null &&
                    _estado != null &&
                    _fecha != null &&
                    _motivoController.text.isNotEmpty) {
                  Cita nuevaCita = Cita(
                    doctor: FirebaseFirestore.instance
                        .doc('doctores/$_selectedDoctorId'),
                    paciente: FirebaseFirestore.instance
                        .doc('pacientes/$_selectedPacienteId'),
                    estado: _estado!,
                    fecha: _fecha!,
                    motivo: _motivoController.text,
                    id: '',
                  );
                  _citaService.agregarCita(nuevaCita);

                  setState(() {
                    _selectedDoctorId = null;
                    _selectedPacienteId = null;
                    _estado = null;
                    _fecha = null;
                    _motivoController.clear();
                  });

                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Por favor complete todos los campos.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Aceptar'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarEditarCitaDialog(BuildContext context, Cita cita) {
    _citaService.obtenerCitaPorId(cita.id).then((citaExistente) {
      if (citaExistente != null) {
        setState(() {
          _selectedDoctorId = citaExistente.doctor.id;
          _selectedPacienteId = citaExistente.paciente.id;
          _estado = citaExistente.estado;
          _fecha = citaExistente.fecha;
          _motivoController.text = citaExistente.motivo;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Editar Cita'),
              content: SingleChildScrollView(
                child: Column(
                  children: [],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Guardar'),
                ),
              ],
            );
          },
        );
      }
    });
  }

  void _eliminarCita(BuildContext context, Cita cita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Cita'),
          content: Text('¿Estás seguro de que deseas eliminar esta cita?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                _citaService.eliminarCita(cita.id);

                Navigator.of(context).pop();
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarDetallesCitaDialog(BuildContext context, Cita cita) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Cita'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FutureBuilder<Doctor>(
                  future:
                      _doctorService.obtenerDoctorPorReferencia(cita.doctor),
                  builder: (context, doctorSnapshot) {
                    if (doctorSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text('Cargando doctor...');
                    }
                    if (doctorSnapshot.hasData) {
                      return Text('Doctor: ${doctorSnapshot.data!.nombre}');
                    } else {
                      return Text('Doctor no encontrado');
                    }
                  },
                ),
                FutureBuilder<Paciente>(
                  future: _pacienteService
                      .obtenerPacientePorReferencia(cita.paciente),
                  builder: (context, pacienteSnapshot) {
                    if (pacienteSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text('Cargando paciente...');
                    }
                    if (pacienteSnapshot.hasData) {
                      return Text('Paciente: ${pacienteSnapshot.data!.nombre}');
                    } else {
                      return Text('Paciente no encontrado');
                    }
                  },
                ),
                Text('Estado: ${cita.estado}'),
                Text('Fecha: ${cita.fecha}'),
                Text('Motivo: ${cita.motivo}'),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
