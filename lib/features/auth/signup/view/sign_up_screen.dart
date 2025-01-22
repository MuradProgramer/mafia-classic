import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_up/sign_up_bloc.dart';
import 'package:mafia_classic/features/auth/signin/signin.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpScreen extends StatefulWidget {

  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _nicknameFocusNode = FocusNode();
  bool _isNickameFocused = false;

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;
  
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isConfirmPasswordFocused = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    _nicknameFocusNode.addListener(() {
      setState(() {
        _isNickameFocused = _nicknameFocusNode.hasFocus;
      });
    });

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

    _confirmPasswordFocusNode.addListener(() {
      setState(() {
        _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _nicknameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            "assets/images/sign-up.png",
            fit: BoxFit.cover,
          ),
        ),

        Scaffold(
          resizeToAvoidBottomInset: false,

          body: BlocListener<SignUpBloc, SignUpState>(
            listener: (context, state) {
              if (state is SignUpSuccess) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(user: state.user),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else if (state is SignUpFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.error)),
                );
              }
            },
        
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  // TEXT:    Sign Up
                  Center(
                    child: Text(
                      S.of(context).signUp,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 43,
                        color: const Color(0xFF494239),
                      ),
                    ),
                  ),
        
                  const SizedBox(height: 30),

                  // TEXT:    Already have an account?
                  const Center(
                    child: Text(
                      'Already have an account?', // NOTE:    Translation L10
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'CenturyGothic',
                        color: Color(0xFF494239),
                      ),
                    ),
                  ),

                  // BUTTON:    Sign In
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignInScreen()),
                        );
                      },
                      child: Text(
                        S.of(context).signIn, 
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'CenturyGothic',
                          color: Colors.white,
                        ),
                      )
                    ),
                  ),

                  // INPUT:    Nickname
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _nicknameFocusNode,
                        controller: _nicknameController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        
                        cursorColor: const Color(0xFF494239),
        
                        decoration: InputDecoration(
                          
                          hintText: _isNickameFocused ? null : S.of(context).nickname,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFF494239)
                          ),
        
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF494239)),
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

                  // INPUT:    Email
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _emailFocusNode,
                        controller: _emailController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
                        
                        cursorColor: const Color(0xFF494239),
        
                        decoration: InputDecoration(
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF494239)),
                          ),
                          hintText: _isEmailFocused ? null : S.of(context).email,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFF494239)
                          ),
        
                          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF494239)),
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

                  // INPUT:     Password
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _passwordFocusNode,
                        controller: _passwordController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
        
                        cursorColor: const Color(0xFF494239),
        
                        decoration: InputDecoration(
                          hintText: _isPasswordFocused ? null : S.of(context).password,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFF494239),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF494239)),
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

                  const SizedBox(height: 10),

                  // INPUT:     Confirm Password
                  Center(
                    child: SizedBox(
                      width: 250,
                      child: TextFormField(
                        focusNode: _confirmPasswordFocusNode,
                        controller: _confirmPasswordController,
        
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.bottom,
        
                        cursorColor: const Color(0xFF494239),
        
                        decoration: InputDecoration(
                          hintText: _isConfirmPasswordFocused ? null : S.of(context).password,
                          hintStyle: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Color(0xFF494239),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF494239)),
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
                                  _isConfirmPasswordVisible
                                    ? 'assets/images/visibility-on.png'
                                    : 'assets/images/visibility-off.png',
                                ),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                        ),
        
                        obscureText: !_isConfirmPasswordVisible,
        
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'CenturyGothic',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BUTTON:    Confirm
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFBF73),
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
                            if (_passwordController.text != _confirmPasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(S.of(context).passwordsDoNotMatch)),
                              );
                            } else {
                              context.read<SignUpBloc>().add(
                                    SignUpRequested(
                                      _nicknameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFBF73),
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

                  const SizedBox(height: 20)
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
