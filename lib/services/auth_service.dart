import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Initialize auth service with persistence
  Future<void> initialize() async {
    try {
      // Set auth persistence to LOCAL (persists across app restarts)
      await _auth.setPersistence(Persistence.LOCAL);

      // Initialize Google Sign-In
      await _googleSignIn.initialize();
    } catch (e) {
      debugPrint('Auth persistence setup failed: $e');
      // Continue anyway as this might not be supported on all platforms
    }
  }

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get AppUser from Firestore
  Future<AppUser?> getAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.data()!, user.uid);
  }

  // Email/Password Sign In
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Email/Password Register
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Phone Sign In (OTP flow)
  Future<void> signInWithPhone(
    String phone,
    Function(String, int?) codeSent,
    Function(String) verificationFailed,
  ) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      codeSent: codeSent,
      verificationFailed:
          (e) => verificationFailed(e.message ?? 'Verification failed'),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
      },
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  // Google Sign-In
  Future<UserCredential?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        clientId: '155438760432-adeamb330sjbrj10md7g8ge884s3gasp.apps.googleusercontent.com',
        serverClientId: '155438760432-adeamb330sjbrj10md7g8ge884s3gasp.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In error: $e');
      return null;
    }
  }

  // Google Sign-Up for Registration
  Future<UserCredential?> registerWithGoogle({required String role}) async {
    try {
      await _googleSignIn.initialize(
        clientId: '155438760432-adeamb330sjbrj10md7g8ge884s3gasp.apps.googleusercontent.com',
        serverClientId: '155438760432-adeamb330sjbrj10md7g8ge884s3gasp.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Extract first 4 letters from Google display name
      String extractedName = 'User';
      if (user.displayName != null && user.displayName!.isNotEmpty) {
        final cleanName = user.displayName!.replaceAll(
          RegExp(r'[^a-zA-Z]'),
          '',
        );
        extractedName =
            cleanName.length >= 4 ? cleanName.substring(0, 4) : cleanName;
      }

      // Create AppUser with Google account info
      final appUser = AppUser(
        uid: user.uid,
        name: extractedName,
        email: user.email ?? '',
        phone: '', // No phone for Google sign-up
        role: role,
        flatNo: '',
        societyId: '',
        status: role == 'resident' ? 'pending' : 'active',
        profileComplete:
            role != 'resident', // Residents need to complete profile
        profileImageUrl: user.photoURL,
      );

      await createOrUpdateUser(appUser);
      return userCredential;
    } catch (e) {
      throw Exception('Google registration failed: $e');
    }
  }

  // Create/Update user in Firestore
  Future<void> createOrUpdateUser(AppUser user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  // Admin-invite registration (pre-filled)
  Future<UserCredential> registerWithAdminInvite({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String inviteCode,
  }) async {
    try {
      // Verify invite code (you can add validation logic here)
      // For now, we'll just create the user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = AppUser(
        uid: credential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: 'admin',
        flatNo: '',
        societyId: '',
        status: 'active',
        profileComplete: true,
        profileImageUrl: '',
      );

      await _db.collection('users').doc(user.uid).set(user.toMap());
      return credential;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Self-signup registration
  Future<UserCredential> registerWithSelfSignup({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
    required String flatNo,
    required String societyId,
  }) async {
    final cred = await registerWithEmail(email, password);
    final appUser = AppUser(
      uid: cred.user!.uid,
      name: name,
      email: email,
      phone: phone,
      role: role,
      flatNo: flatNo,
      societyId: societyId,
      status: 'pending',
      profileComplete: false,
      profileImageUrl: null,
    );
    await createOrUpdateUser(appUser);
    return cred;
  }

  // Update profile completion
  Future<void> completeProfile(
    String uid,
    Map<String, dynamic> extraData,
  ) async {
    await _db.collection('users').doc(uid).update({
      ...extraData,
      'profileComplete': true,
    });
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Debug method to check auth state
  void debugAuthState() {
    final user = _auth.currentUser;
    debugPrint('=== AUTH DEBUG ===');
    debugPrint('Current user: ${user?.uid}');
    debugPrint('Email: ${user?.email}');
    debugPrint('Email verified: ${user?.emailVerified}');
    debugPrint('Is anonymous: ${user?.isAnonymous}');
    debugPrint('Provider data: ${user?.providerData.map((p) => p.providerId)}');
    debugPrint('==================');
  }
}
