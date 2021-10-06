import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:training_firebase/main.dart';


class AuthController extends GetxController {
  static AuthController instance = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  var _firebaseUser = Rxn<User>();
 
  User? get user => _firebaseUser.value;
 
  @override
  void onReady()async {
    super.onReady();
    _firebaseUser.bindStream(auth.authStateChanges());
    //ever(_firebaseUser, _setInitialScreen);
  }





  void signOut() async {
    auth.signOut().whenComplete(() {
      Get.offAll(ControlPage());

    });
  }
  


   signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    return await auth.signInWithCredential(credential).whenComplete(() {
      FirebaseFirestore.instance.doc('users/${user!.uid}').set({
        'uid': user!.uid,
        'image':googleUser.photoUrl,
        'name':googleUser.displayName,
        'email':googleUser.email
      });
    });
  }

 

}