import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
//import 'package:flutter_svg/flutter_svg.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';

import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_in/sign_in_bloc.dart';
import 'package:mafia_classic/features/auth/signup/signup.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

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
  bool _emailError = false;

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _passwordError = false;

  bool _isPasswordVisible = false;

  final formKey = GlobalKey<FormState>();
  int popupCount = 0;

  void showValidationPopup(String content, String formField) {
    switch (formField) {
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
      default:
    }

    if (popupCount == 0) {
      showBouncingPopupFromTop(
        context, 
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
      context, 
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
    String confirmationText = S.of(context).confirm;
    
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
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text(state.error)),              
                // );
                if (state.error.contains('connection timeout')) {
                  showExceptionPopup(S.of(context).sorryConnectionWithServerTimeouted);
                } else if (state.error.contains('400') || state.error.contains('401')) {
                  showExceptionPopup(S.of(context).emailOrPasswordIsInvalid);
                } else if (state.error.contains('404')) {
                  showExceptionPopup(S.of(context).userWithThisEmailDoesNotExist);
                } else {
                  showExceptionPopup(S.of(context).sorrySomethingBadHappened);
                }
                debugPrint(state.error);
              }
            },
            
            child: Padding(
              padding: EdgeInsets.all(16.sp),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                        
                    // TEXT:    Sign In
                    Center(
                      child: Text(
                        S.of(context).signIn,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 43.sp,
                          color: const Color(0xFFFFB000),
                        ),
                      ),
                    ),
                        
                    SizedBox(height: 40.h),
                        
                    // TEXT:    Dont Have Account?
                    Center(
                      child: Text(
                        S.of(context).dontHaveAnAccount,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'CenturyGothic',
                          color: const Color(0xFFAAAAAA),
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
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'CenturyGothic',
                            color: const Color(0xFFFFB000),
                          ),
                        )
                      ),
                    ),
                        
                    SizedBox(height: 30.h),
                        
                    // INPUT:    Email
                    Center(
                      child: SizedBox(
                        width: 250.w,
                        child: TextFormField(
                          focusNode: _emailFocusNode,
                          controller: _emailController,

                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
                        
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.bottom,
                          
                          cursorColor: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFB000),
                          cursorHeight: 18.h,
                        
                          decoration: InputDecoration(
                            hintText: _isEmailFocused ? null : S.of(context).email,
                            hintStyle: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: const Color(0xFFAAAAAA),
                            ),
                            errorStyle: const TextStyle(height: 0),
                        
                            contentPadding: EdgeInsets.symmetric(vertical: 5.h),

                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF))
                            ),
                        
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFB000)),
                            )
                          ),
                        
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),

                          validator: (value) {
                            if (value!.isEmpty) {
                              //return 'You must write your email';
                              showValidationPopup(S.of(context).youMustWriteYourEmail, 'email');
                              return null;
                            } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              //return 'Enter valid Email';
                              showValidationPopup(S.of(context).enterValidEmail, 'email');
                              return null;
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
                        
                    // INPUT: Password
                    Center(
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 250.w,
                            child: TextFormField(
                              focusNode: _passwordFocusNode,
                              controller: _passwordController,

                              onTapOutside: (PointerDownEvent event) {
                                FocusScope.of(context).unfocus();
                              },

                              maxLength: 14,
                            
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.bottom,
                            
                              cursorColor: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFB000),
                              cursorHeight: 18.h,
                            
                              decoration: InputDecoration(
                                hintText: _isPasswordFocused ? null : S.of(context).password,
                                hintStyle: TextStyle(
                                  fontSize: 19.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CenturyGothic',
                                  color: const Color(0xFFAAAAAA),
                                ),
                                errorStyle: const TextStyle(height: 0),
                                counterText: '',

                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF))
                                ),

                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFB000)),
                                ),
                            
                                // DEF:    DOING CENTERED TEXT DESPITE ICON 
                                contentPadding: EdgeInsets.symmetric(vertical: 5.h),
                              ),
                            
                              obscureText: !_isPasswordVisible,
                            
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'CenturyGothic',
                                color: Colors.white,
                              ),
                          
                              validator: (value) {
                                if (value!.isEmpty) {
                                  //return 'You must write your password';
                                  showValidationPopup(S.of(context).youMustWriteYourPassword, 'password');
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

                          // BUTTON:    Visibility ON OFF
                          SizedBox(
                            width: 250.w,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(),
                                
                                GestureDetector(
                                  child: SizedBox(
                                    height: 45.h,
                                    width: 45.w,
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
                              ],
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                
                    SizedBox(height: 15.h),
                
                    // BUTTON:    Forgot Password
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // NOTE:    Logic
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const SignUpScreen()),
                          );
                        },
                        child: Text(
                          S.of(context).forgotPassword,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'CenturyGothic',
                            color: const Color(0xFFAAAAAA),
                          ),
                        )
                      ),
                    ),
                        
                    SizedBox(height: 40.h),
                        
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
                          borderRadius: BorderRadius.circular(16.sp),
                        ),
                        child: SizedBox(
                          width: confirmationText.length > 8 ? 175.w : 150.w,
                          child: ElevatedButton(
                            onPressed: () {
                              //!!!!!!!!!!!!!!

                              // showBouncingPopupFromTop(
                              //   context, 
                              //   ValidationPopup(
                              //     height: 170.h, 
                              //     width: 238.w, 
                              //     popupType: 2, 
                              //     statusCode: 111, 
                              //     content: 'Sorry, connection with server timeouted...'
                              //   )
                              // );

                              popupCount = 0;

                              if (formKey.currentState!.validate()) {
                                if (!_emailError && !_passwordError) {
                                  context.read<SignInBloc>().add(
                                    SignInRequested(
                                      _emailController.text,
                                      _passwordController.text,
                                    ),
                                  );
                                }
                                //return;
                              }
                              
                              // showBouncingPopupFromTop(
                              //   context, 
                              //   ValidationPopup(
                              //     height: 105.h, 
                              //     width: 295.h, 
                              //     popupType: 1, 
                              //     statusCode: 401, 
                              //     content: 'Password Must be more than 8 character'
                              //   )
                              // );
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
                        
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
