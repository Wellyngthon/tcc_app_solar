import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> cadastrarUsuario({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: senha,
    );

    final user = credencial.user;

    if (user == null) {
      throw Exception('Não foi possível criar o usuário.');
    }

    await _firestore.collection('usuarios').doc(user.uid).set({
      'nome': nome,
      'email': email,
      'criadoEm': FieldValue.serverTimestamp(),
    });
  }

  Future<void> login({required String email, required String senha}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: senha);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? get usuarioAtual => _auth.currentUser;
}
