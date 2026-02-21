import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_up/sign_up_bloc.dart';
import 'package:mafia_classic/features/auth/signin/signin.dart';
import 'package:mafia_classic/utils/utils.dart';

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
  bool _nicknameError = false;

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _emailError = false;
  
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _passwordError = false;
  
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isConfirmPasswordFocused = false;
  bool _confirmPasswordError = false;

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  final formKey = GlobalKey<FormState>();
  int popupCount = 0;

  void showValidationPopup(String content, String formField) {
    switch (formField) {
      case 'nickname':
        setState(() {
          _nicknameError = true;
        });
        break;
      case 'email':
        setState(() {
          _emailError = true;
        });
        break;
      case 'password':
        setState(() {
          _passwordError = true;
        });
        break;
      case 'confirm password':
        setState(() {
          _confirmPasswordError = true;
        });
        break;
      default:
    }

    if (popupCount == 0) {
      showBouncingPopupFromTop(
        ValidationPopup(
          height: 105.h, 
          width: 295.w, 
          popupType: 1, 
          statusCode: 111, 
          content: content
        )
      );

      popupCount = 1;
    }
  }

  void showExceptionPopup(String content) {
    showBouncingPopupFromTop(
      ValidationPopup(
        height: 170.h, 
        width: 270.w, 
        popupType: 2, 
        statusCode: 111, 
        content: content
      )
    );
  }

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
    String confirmationText = S.of(context).confirm;

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
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(state.error)),
                // );
                if (state.error.contains('connection timeout')) {
                  showExceptionPopup(S.of(context).sorryConnectionWithServerTimeouted);
                } else if (state.error.contains('400') && state.error.contains('email')) {
                  showExceptionPopup(S.of(context).playerWithThisEmailAlreadyExist);
                } else if (state.error.contains('400') && state.error.contains('nickname')) {
                  showExceptionPopup(S.of(context).playerWithThisNicknameAlreadyExist);
                } else {
                  showExceptionPopup(S.of(context).sorrySomethingBadHappened);
                }
                debugPrint(state.error);
              }
            },
        
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
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
                    Center(
                      child: Text(
                        S.of(context).alreadyHaveAnAccount,
                        style: const TextStyle(
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
                        width: 250.w,
                        child: TextFormField(
                          focusNode: _nicknameFocusNode,
                          controller: _nicknameController,
                        
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          
                          cursorColor: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,

                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },

                          maxLength: 14,
                        
                          decoration: InputDecoration(
                            hintText: _isNickameFocused ? null : S.of(context).nickname,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',
                            errorStyle: const TextStyle(height: 0),
                            
                            contentPadding: EdgeInsets.symmetric(vertical: 5.h),

                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF494239))
                            ),
                        
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF494239)),
                            )
                          ),
                        
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              //return 'You must write your nickname';
                              showValidationPopup(S.of(context).youMustWriteYourNickname, 'nickname');
                              //return '';
                            } else if (value.length < 3) {
                              //return 'Your nickname must contain at least 3 characters';
                              showValidationPopup(S.of(context).yourNicknameMustContainAtLeast3Characters, 'nickname');
                              //return '';
                            } else if (!RegExp(r'^[a-zA-Z0-9._-]*$').hasMatch(value)) {
                              //return 'Your nickname can contain, letters, numbers and . _ -';
                              showValidationPopup(S.of(context).yourNicknameCanContainLettersNumbersAnd, 'nickname');
                              //return '';
                            } else {
                              setState(() {
                                _nicknameError = false;
                              });
                              return null;
                            }
                            return '';
                          },
                        ),
                      ),
                    ),
                
                    SizedBox(height: 10.h),
                
                    // INPUT:    Email
                    Center(
                      child: SizedBox(
                        width: 250,
                        child: TextFormField(
                          focusNode: _emailFocusNode,
                          controller: _emailController,
                        
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          
                          cursorColor: _emailError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,

                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
                        
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
                        
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _emailError ? const Color(0xFFBC4434) : const Color(0xFF494239))
                            ),
                        
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _emailError ? const Color(0xFFBC4434) : const Color(0xFF494239)),
                            )
                          ),
                        
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              //return 'You must write your email';
                              showValidationPopup(S.of(context).youMustWriteYourEmail, 'email');
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              //return 'Enter valid Email';
                              showValidationPopup(S.of(context).enterValidEmail, 'email');
                            } else {
                              setState(() {
                                _emailError = false;
                              });
                              return null;
                            }
                          },
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
                        
                          cursorColor: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,

                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },

                          maxLength: 14,
                        
                          decoration: InputDecoration(
                            hintText: _isPasswordFocused ? null : S.of(context).password,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',

                            errorStyle: const TextStyle(height: 0),

                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239))
                            ),
                        
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239)),
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
                                      ? 'assets/images/visibility-dark-on.png'
                                      : 'assets/images/visibility-dark-off.png',
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

                          validator: (value) {
                            if (value!.isEmpty) {
                              //return 'You must write your password';
                              showValidationPopup(S.of(context).youMustWriteYourPassword, 'password');
                              return null;
                            } else if (value.length < 6) {
                              //return 'Your password must contain at least 8 characters';
                              showValidationPopup(S.of(context).yourPasswordMustContainAtLeast6Characters, 'password');
                              return null;
                            } else {
                              setState(() {
                                _passwordError = false;
                              });
                              return null;
                            }
                          },
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
                        
                          cursorColor: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,

                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },

                          maxLength: 14,
                        
                          decoration: InputDecoration(
                            hintText: _isConfirmPasswordFocused ? null : S.of(context).password,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',

                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239))
                            ),
                        
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239)),
                            ),
                        
                            // DEF:    DOING CENTERED TEXT DESPITE ICON 
                            contentPadding: EdgeInsets.symmetric(horizontal: 50.0.w),
                        
                            // BUTTON:    Visibility ON OFF
                            suffixIcon: GestureDetector(
                              child: SizedBox(
                                height: 20.h,
                                width: 20.w,
                                child: Transform.translate(
                                  offset: const Offset(10, 14),
                                  child: Image.asset(
                                    _isConfirmPasswordVisible
                                      ? 'assets/images/visibility-dark-on.png'
                                      : 'assets/images/visibility-dark-off.png',
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
                        
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              //return 'You must confirm your password';
                              showValidationPopup(S.of(context).youMustConfirmYourPassword, 'confirm password');
                              return null;
                            } else if (value != _passwordController.text) {
                              //return 'Passwords are not matching';
                              showValidationPopup(S.of(context).passwordsAreNotMatching, 'confirm password');
                              return null;
                            } else {
                              setState(() {
                                _confirmPasswordError = false;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                
                    SizedBox(height: 40.h),
                
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
                          width: confirmationText.length > 8 ? 175.w : 150.w,
                          child: ElevatedButton(
                            onPressed: () {
                              popupCount = 0;

                              if (formKey.currentState!.validate()) {
                                if (!_emailError && !_nicknameError && !_passwordError && !_confirmPasswordError) {
                                  context.read<SignUpBloc>().add(
                                    SignUpRequested(
                                      _nicknameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                                }
                                //return;
                              }

                              /*
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
                              */
                              
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
                            
                            child: Text(
                              confirmationText,
                              style: TextStyle(
                                fontSize: 25.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                
                    SizedBox(height: 20.h)
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
