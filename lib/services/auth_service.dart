import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/usuario.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Obtener el usuario actual autenticado
  User? get currentUser => _auth.currentUser;

  // Stream de cambios de estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 1. Iniciar sesión con Correo y Contraseña
  Future<UserCredential?> iniciarSesion({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // 2. Registrar nuevo usuario
  Future<UserCredential?> registrarUsuario({
    required String nombreCompleto,
    required String email,
    required String password,
    required String telefono,
    String rol = 'paciente',
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (userCredential.user != null) {
        // Crear objeto Usuario
        Usuario nuevoUsuario = Usuario(
          id: userCredential.user!.uid,
          nombreCompleto: nombreCompleto.trim(),
          email: email.trim(),
          telefono: telefono.trim(),
          rol: rol,
        );

        // Guardar información extendida en Firestore
        await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .set(nuevoUsuario.toJson());
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Error en el registro: $e');
    }
  }

  // 3. Iniciar sesión con Google
  Future<UserCredential?> iniciarSesionConGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // El usuario canceló el login

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Verificar si ya existe en Firestore, si no, registrarlo
      if (userCredential.user != null) {
        DocumentSnapshot doc = await _firestore
            .collection('usuarios')
            .doc(userCredential.user!.uid)
            .get();

        if (!doc.exists) {
          Usuario nuevoUsuario = Usuario(
            id: userCredential.user!.uid,
            nombreCompleto: userCredential.user!.displayName ?? 'Usuario',
            email: userCredential.user!.email ?? '',
            telefono: userCredential.user!.phoneNumber ?? '',
            rol: 'paciente',
          );
          await _firestore
              .collection('usuarios')
              .doc(userCredential.user!.uid)
              .set(nuevoUsuario.toJson());
        }
      }

      return userCredential;
    } catch (e) {
      throw Exception('Error al iniciar sesión con Google: $e');
    }
  }

  // 4. Obtener datos del usuario desde Firestore
  Future<Usuario?> obtenerDatosUsuario(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('usuarios').doc(uid).get();
      if (doc.exists) {
        return Usuario.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener datos del usuario: $e');
    }
  }

  // 5. Cerrar sesión
  Future<void> cerrarSesion() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // Manejo de errores amigables
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró ningún usuario con este correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El formato del correo electrónico es inválido.';
      default:
        return 'Ocurrió un error inesperado: ${e.message}';
    }
  }
}
