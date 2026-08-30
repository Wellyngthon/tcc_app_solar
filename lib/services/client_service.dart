import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/client.dart';

class ClientService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _clientes {
    return _firestore.collection('usuarios').doc(_uid).collection('clientes');
  }

  // CREATE
  Future<void> cadastrar(Cliente cliente) async {
    await _clientes.add(cliente.toMap());
  }

  // READ - listar todos
  Stream<List<Cliente>> listar() {
    return _clientes.orderBy('nome').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Cliente.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  // READ - buscar por ID
  Future<Cliente?> buscar(String id) async {
    final doc = await _clientes.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return Cliente.fromMap(doc.id, doc.data()!);
  }

  // UPDATE
  Future<void> editar(Cliente cliente) async {
    await _clientes.doc(cliente.id).update(cliente.toMap());
  }

  // DELETE
  Future<void> excluir(String id) async {
    await _clientes.doc(id).delete();
  }
}
