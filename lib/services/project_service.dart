import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/project.dart';

class ProjectService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Usuário não autenticado.');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _projetos {
    return _firestore.collection('usuarios').doc(_uid).collection('projetos');
  }

  Future<void> cadastrar(ProjetoFotovoltaico projeto) async {
    await _projetos.add(projeto.toMap());
  }

  Stream<List<ProjetoFotovoltaico>> listar() {
    return _projetos.orderBy('localizacao').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProjetoFotovoltaico.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<ProjetoFotovoltaico?> buscar(String id) async {
    final doc = await _projetos.doc(id).get();

    if (!doc.exists) {
      return null;
    }

    return ProjetoFotovoltaico.fromMap(doc.id, doc.data()!);
  }

  Future<void> editar(ProjetoFotovoltaico projeto) async {
    await _projetos.doc(projeto.id).update(projeto.toMap());
  }

  Future<void> excluir(String id) async {
    await _projetos.doc(id).delete();
  }
}