import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserDetailsForm extends StatefulWidget {
  const UserDetailsForm({super.key});

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreComercialCtrl = TextEditingController();
  final _nombrePropietarioCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreComercialCtrl.dispose();
    _nombrePropietarioCtrl.dispose();
    _rucCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardarDatos() async {
    if (_formKey.currentState!.validate()) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Usuario no autenticado')),
        );
        return;
      }

      try {
        await FirebaseFirestore.instance.collection('users_database').doc(uid).set({
          'uid': uid,
          'nombre_comercial': _nombreComercialCtrl.text.trim(),
          'nombre_propietario': _nombrePropietarioCtrl.text.trim(),
          'ruc': _rucCtrl.text.trim(),
          'ubicacion': _ubicacionCtrl.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Datos guardados correctamente')),
        );

        // Puedes navegar a otra pantalla si lo deseas
        // context.go('/home');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datos del Negocio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreComercialCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre Comercial',
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombrePropietarioCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Propietario',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rucCtrl,
                decoration: const InputDecoration(
                  labelText: 'RUC',
                  prefixIcon: Icon(Icons.badge),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ubicación',
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _guardarDatos,
                child: const Text('Guardar Información'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
