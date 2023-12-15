import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_webapp/Model/user_model.dart';
import 'package:whatsapp_webapp/res/AppColors/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginSignUpPage extends StatefulWidget {
  const LoginSignUpPage({super.key});

  @override
  State<LoginSignUpPage> createState() => _LoginSignUpPageState();
}

class _LoginSignUpPageState extends State<LoginSignUpPage> {
  bool doesUserWantsToSignUp = false;
  Uint8List? selectedImage;
  bool errorInPicture = false;
  bool errorInName = false;
  bool errorInEmail = false;
  bool errorInPassword = false;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool onLoading = false;

  chooseImage() async {
    FilePickerResult? chosenImageFile =
        await FilePicker.platform.pickFiles(type: FileType.image);
    setState(() {
      selectedImage = chosenImageFile!.files.single.bytes;
    });
  }

  uploadImageToStorage(UserModel userData) {
    if (selectedImage != null) {
      Reference imageRef =
          FirebaseStorage.instance.ref('profileImages/${userData.uid}.jpg');
      UploadTask task = imageRef.putData(selectedImage!);
      task.whenComplete(() async {
        String imageUrl = await task.snapshot.ref.getDownloadURL();
        userData.image = imageUrl;
        //3:save userData to firestore database
        FirebaseAuth.instance.currentUser!.updateDisplayName(userData.name);
        FirebaseAuth.instance.currentUser!.updatePhotoURL(imageUrl);
        final userReference =
            FirebaseFirestore.instance.collection('Users').doc(userData.uid);
        userReference.set(
          userData.tojson(

          ),).then((value){
            setState(() {
              onLoading = false ;
            });
            Navigator.pushReplacementNamed(context, '/home');
            var snackBar = const SnackBar(
              content: Text("Register Successfully"),
              backgroundColor: AppColor.primaryColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      });
    } else {
      var snackBar = const SnackBar(
        content: Text("please choose the Image first"),
        backgroundColor: AppColor.primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // 1: create a new user
  signUpUserNow(nameInput, emailInput, passwordInput) async {
    final userCreated = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailInput, password: passwordInput);
    // upload image to storage
    String? uidOfUserCreated = userCreated.user!.uid;
    if (uidOfUserCreated != null) {
      final userData = UserModel(uidOfUserCreated,nameInput,emailInput,passwordInput);
      uploadImageToStorage(userData);

    }
  }
  loginUserNow(emailInput, passwordInput) {

    FirebaseAuth.instance.signInWithEmailAndPassword(email: emailInput, password: passwordInput).then((value){
    });
    setState(() {
      onLoading = false;
    });
    Navigator.pushReplacementNamed(context, '/home');
    var snackBar = const SnackBar(
      content: Text("Login Successfully"),
      backgroundColor: AppColor.primaryColor,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  //2: check form validation
  formValidation() {
    setState(() {
      bool onLoading = true;
      bool errorInPicture = false;
      bool errorInName = false;
      bool errorInEmail = false;
      bool errorInPassword = false;
    });
    String nameInput = nameController.text.trim();
    String emailInput = emailController.text.trim();
    String passwordInput = passwordController.text.trim();
    if (emailInput.isNotEmpty && emailInput.contains('@')) {
      if (passwordInput.isNotEmpty && passwordInput.length > 7) {
        if (doesUserWantsToSignUp == true) // signup orm
        {
          if (nameInput.isNotEmpty && nameInput.length > 3) {
            signUpUserNow(nameInput, emailInput, passwordInput);
          } else {
            var snackBar = const SnackBar(
              content: Text("name is not valid"),
              backgroundColor: AppColor.primaryColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
            setState(() {
              bool onLoading = false;
            });
          }
        } else //Login form
        {
         loginUserNow(emailInput,passwordInput);
        }
      } else {
        var snackBar = const SnackBar(
          content: Text("password is not valid"),
          backgroundColor: AppColor.primaryColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        setState(() {
          bool onLoading = false;
        });
      }
    } else {
      var snackBar = const SnackBar(
        content: Text("Email is not valid"),
        backgroundColor: AppColor.primaryColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        bool onLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColor.backgroundColor,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.5,
                color: AppColor.primaryColor,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(17),
                  child: Card(
                    elevation: 16,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(45),
                      width: 500,
                      child: Column(
                        children: [
                          //ToggleButton
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text("Login"),
                              const SizedBox(
                                width: 10,
                              ),
                              Switch(
                                  value: doesUserWantsToSignUp,
                                  onChanged: (value) {
                                    setState(() {
                                      doesUserWantsToSignUp = value;
                                    });
                                  }),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text("SignUp"),
                            ],
                          ),

                          //Profile Image
                          Visibility(
                            visible: doesUserWantsToSignUp,
                            child: ClipOval(
                              child: selectedImage != null
                                  ? Image.memory(
                                      selectedImage!,
                                      width: 124,
                                      height: 124,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      "images/profile.png",
                                      width: 124,
                                      height: 124,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          //OutlinedButton to choose image
                          Visibility(
                            visible: doesUserWantsToSignUp,
                            child: OutlinedButton(
                              onPressed: () {
                                chooseImage();
                              },
                              style: errorInPicture
                                  ? OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          width: 3, color: Colors.red),
                                    )
                                  : null,
                              child: const Text("Choose Picture"),
                            ),
                          ),

                          //textForm fiield
                          Visibility(
                              visible: doesUserWantsToSignUp,
                              child: TextFormField(
                                controller: nameController,
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "Enter Your Name",
                                  label: const Text("Name"),
                                  prefixIcon:
                                      const Icon(Icons.person_2_outlined),
                                  enabledBorder: errorInName
                                      ? const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 3, color: Colors.red),
                                        )
                                      : null,
                                ),
                              )),
                          TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Enter Your Email",
                              label: const Text("Email"),
                              prefixIcon: const Icon(Icons.email_outlined),
                              enabledBorder: errorInName
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.red),
                                    )
                                  : null,
                            ),
                          ),
                          TextFormField(
                            controller: passwordController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              hintText: doesUserWantsToSignUp
                                  ? "Must have greater then 8 characters"
                                  : "Enter Your Password",
                              label: const Text("Password"),
                              prefixIcon: const Icon(Icons.lock_clock_outlined),
                              enabledBorder: errorInName
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 3, color: Colors.red),
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 30),
                          //LoginSignUp Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.primaryColor),
                              onPressed: () {
                                formValidation();
                              },
                              child: onLoading
                                  ? const SizedBox(
                                      height: 19,
                                      width: 19,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      doesUserWantsToSignUp
                                          ? "SignUp"
                                          : "Login",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
