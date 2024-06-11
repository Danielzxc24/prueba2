import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../model/modelos.dart';
import '../service/services.dart';

class PacienteCrudPage extends StatefulWidget {
  @override
  _PacienteCrudPageState createState() => _PacienteCrudPageState();
}

class _PacienteCrudPageState extends State<PacienteCrudPage> {
  final PacienteService _pacienteService = PacienteService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _edadController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Pacientes'),
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
              title: Text('Crear Doctor'),
              onTap: () {
                context.go('/doctor');
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
              'Agregar Nuevo Paciente',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            _buildTextField('Nombre', _nombreController),
            _buildTextField('Edad', _edadController),
            _buildTextField('Descripción', _direccionController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _agregarPaciente();
              },
              child: Text('Agregar Paciente'),
            ),
            SizedBox(height: 20),
            Text(
              'Lista de Pacientes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: _buildPacienteList(),
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

  Widget _buildPacienteList() {
    return StreamBuilder<List<Paciente>>(
      stream: _pacienteService.obtenerPacientes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No hay pacientes disponibles.'),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final paciente = snapshot.data![index];
            return ListTile(
              title: Text(paciente.nombre),
              subtitle: Text('Edad: ${paciente.edad}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _mostrarEditarPacienteDialog(context, paciente);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _eliminarPaciente(paciente.id);
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

  Future<void> _agregarPaciente() async {
    final nuevoPaciente = Paciente(
      id: '',
      nombre: _nombreController.text,
      edad: int.parse(_edadController.text),
      descripcion: _direccionController.text,
    );
    await _pacienteService.agregarPaciente(nuevoPaciente);
    _limpiarCampos();
  }

  void _limpiarCampos() {
    _nombreController.clear();
    _edadController.clear();
    _direccionController.clear();
    _telefonoController.clear();
  }

  Future<void> _eliminarPaciente(String id) async {
    await _pacienteService.eliminarPaciente(id);
  }

  Future<void> _mostrarEditarPacienteDialog(
      BuildContext context, Paciente paciente) async {
    _nombreController.text = paciente.nombre;
    _edadController.text = paciente.edad.toString();
    _direccionController.text = paciente.descripcion;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Paciente'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField('Nombre', _nombreController),
                _buildTextField('Edad', _edadController),
                _buildTextField('Descripción', _direccionController)
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
                _actualizarPaciente(paciente.id);
                Navigator.of(context).pop();
              },
              child: Text('Guardar Cambios'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _actualizarPaciente(String id) async {
    final pacienteActualizado = Paciente(
        id: id,
        nombre: _nombreController.text,
        edad: int.parse(_edadController.text),
        descripcion: _direccionController.text);
    await _pacienteService.actualizarPaciente(pacienteActualizado);
    _limpiarCampos();
  }
}
