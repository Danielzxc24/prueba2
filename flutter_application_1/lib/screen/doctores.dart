import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/modelos.dart';
import '../service/services.dart';

class DoctorCrudPage extends StatefulWidget {
  @override
  _DoctorCrudPageState createState() => _DoctorCrudPageState();
}

class _DoctorCrudPageState extends State<DoctorCrudPage> {
  final DoctorService _doctorService = DoctorService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especialidadController = TextEditingController();
  final TextEditingController _horarioController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Doctores'),
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
              title: Text('Inicio'),
              onTap: () {
                context.go('/HomePage');
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
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agregar Nuevo Doctor',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildTextField('Nombre', _nombreController),
            _buildTextField('Especialidad', _especialidadController),
            _buildTextField('Horario', _horarioController),
            _buildTextField('URL', _urlController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _agregarDoctor();
              },
              child: Text('Agregar Doctor'),
            ),
            SizedBox(height: 20),
            Text(
              'Lista de Doctores',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildDoctorList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDoctorList() {
    return StreamBuilder<List<Doctor>>(
      stream: _doctorService.obtenerDoctores(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No hay doctores disponibles.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final doctor = snapshot.data![index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(doctor.url),
              ),
              title: Text(doctor.nombre),
              subtitle: Text(doctor.especialidad),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _mostrarEditarDoctorDialog(context, doctor);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _eliminarDoctor(doctor.id);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _agregarDoctor() async {
    final nuevoDoctor = Doctor(
      id: '',
      nombre: _nombreController.text,
      especialidad: _especialidadController.text,
      horario: _horarioController.text,
      url: _urlController.text,
    );
    await _doctorService.agregarDoctor(nuevoDoctor);
    _limpiarCampos();
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _especialidadController.clear();
    _horarioController.clear();
    _urlController.clear();
  }

  Future<void> _eliminarDoctor(String id) async {
    await _doctorService.eliminarDoctor(id);
  }

  Future<void> _mostrarEditarDoctorDialog(
      BuildContext context, Doctor doctor) async {
    _nombreController.text = doctor.nombre;
    _especialidadController.text = doctor.especialidad;
    _horarioController.text = doctor.horario;
    _urlController.text = doctor.url;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Doctor'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Nombre', _nombreController),
                _buildTextField('Especialidad', _especialidadController),
                _buildTextField('Horario', _horarioController),
                _buildTextField('URL', _urlController),
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
                _actualizarDoctor(doctor.id);
                Navigator.of(context).pop();
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actualizarDoctor(String id) async {
    final doctorActualizado = Doctor(
      id: id,
      nombre: _nombreController.text,
      especialidad: _especialidadController.text,
      horario: _horarioController.text,
      url: _urlController.text,
    );
    await _doctorService.actualizarDoctor(doctorActualizado);
    _limpiarCampos();
  }
}
