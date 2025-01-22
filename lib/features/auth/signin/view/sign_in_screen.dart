import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:google_fonts/google_fonts.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_in/sign_in_bloc.dart';
import 'package:mafia_classic/features/auth/signup/signup.dart';

class SignInScreen extends StatefulWidget {

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;

  bool _isPasswordVisible = false;


  @override
  void initState() {
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });

    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
    
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            "assets/images/sign-in.png",
            fit: BoxFit.cover,
          ),
        ),

        Scaffold(
          resizeToAvoidBottomInset: false,

          body: BlocListener<SignInBloc, SignInState>(
            listener: (context, state) {
              if (state is SignInSuccess) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(user: state.user),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else if (state is SignInFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),              
                );
                debugPrint(state.error);
              }
            },
            
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
        
                  // TEXT:    Sign In
                  Center(
                    child: Text(
                      S.of(context).signIn,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 43,
                        color: const Color(0xFFFFB000),
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 40),
        
                  // TEXT:    Dont Have Account?
                  const Center(
                    child: Text(
                      'Don\'t have an account?', // NOTE:    Translation L10
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CenturyGothic',
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ),
                  
                  // BUTTON:    Sign Up
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: Text(
                        S.of(context).signUp, 
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'CenturyGothic',
                          color: Color(0xFFFFB000),
                        ),
                      )
                    ),
                  ),
        
                  const SizedBox(height: 30),
        
                  // INPUT:    Email
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _emailFocusNode,
                        controller: _emailController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        
                        cursorColor: const Color(0xFFFFB000),
        
                        decoration: InputDecoration(
                          hintText: _isEmailFocused ? null : S.of(context).email,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFFAAAAAA),
                          ),
        
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFFB000)),
                          )
                        ),
        
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CenturyGothic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 10),
        
                  // INPUT: Password
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
        
                        cursorColor: const Color(0xFFFFB000),
        
                        decoration: InputDecoration(
                          hintText: _isPasswordFocused ? null : S.of(context).password,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFFAAAAAA),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFFFB000)),
                          ),
        
                          // DEF:    DOING CENTERED TEXT DESPITE ICON 
                          contentPadding: const EdgeInsets.symmetric(horizontal: 50.0),
        
                          // BUTTON:    Visibility ON OFF
                          suffixIcon: GestureDetector(
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: Transform.translate(
                                offset: const Offset(10, 14),
                                child: Image.asset(
                                  _isPasswordVisible
                                    ? 'assets/images/visibility-on.png'
                                    : 'assets/images/visibility-off.png',
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
        
                        obscureText: !_isPasswordVisible,
        
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CenturyGothic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // BUTTON:    Forgot Password
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // NOTE:    Logic
                      },
                      child: const Text(
                        'Forgot Password', // NOTE:    Translation L10
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'CenturyGothic',
                          color: Color(0xFFAAAAAA),
                        ),
                      )
                    ),
                  ),
        
                  const SizedBox(height: 50),
        
                  // BUTTON:    Confirm
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D3D),
                        border: Border.all(
                          color: Colors.white,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: SizedBox(
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<SignInBloc>().add(
                                    SignInRequested(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3D3D3D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                              side: const BorderSide(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                          ),
                          
                          child: const Text(
                            'Confirm', // NOTE:    Translation L10
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
