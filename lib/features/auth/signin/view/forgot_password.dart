import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/theme/theme.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final int tabIndex = 2; // 0 - Write Email, 1 - SMS Code, 2 - New Password

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [

        Positioned.fill(
          child: Image.asset(
            "assets/images/background-forgot-password.jpg",
            fit: BoxFit.cover,
            opacity: const AlwaysStoppedAnimation<double>(0.7),
          ),
        ),

        Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              width: 355.w,
              height: 495.h,
              margin: EdgeInsets.symmetric(horizontal: 10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                margin: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  border: BoxBorder.all(
                    color: const Color(0xFFFFFFFF),
                    width: 2.w
                  ),
                  borderRadius: BorderRadius.circular(75.r),
                ),
                child: Column(
                  children: [
                    // TEXT:    RECOVER PASSWORD
                    Padding(
                      padding: EdgeInsets.only(top: 25.h, bottom: 10.h),
                      child: Text(
                        textAlign: TextAlign.center,
                        '${S.of(context).recover}\n${S.of(context).password}',
                        style: GoogleFonts.playfairDisplay(
                          height: 0,
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFFB000),
                        ),
                      ),
                    ),

                    //? TABS
                    (tabIndex == 0) 
                    ? const WriteEmailTab()
                    : (tabIndex == 1)
                    ? const SmsCodeTab()
                    : const NewPasswordTab()
                  ],
                ),
              ),
            )
          ),
        ),
      ],
    );
  }
}

//? WRITE EMAIL TAB
class WriteEmailTab extends StatefulWidget {
  const WriteEmailTab({super.key});

  @override
  State<WriteEmailTab> createState() => _WriteEmailTabState();
}

class _WriteEmailTabState extends State<WriteEmailTab> {
  final _emailController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _emailError = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {
    switch (formField) {
      case 'email':
        setState(() {
          _emailError = true;
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

    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();

    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    String nextText = S.of(context).next;
    String backText = S.of(context).back;

    return Column(
      children: [
        //? TEXT:    Write down the email to get a code
        Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
          child: Text(
            S.of(context).writeDownTheEmailToGetACode,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFFFFFFFF),
              fontFamily: 'CenturyGothic'
            ),
          ),
        ),

        // INPUT:    Email
        Center(
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Container(
                  height: 52.h,
                  width: double.maxFinite,
                  margin: EdgeInsets.only(left: 20.w, right: 20.w, top: 50.h),
                  child: TextFormField(
                    focusNode: _emailFocusNode,
                    controller: _emailController,
                
                    onTapOutside: (PointerDownEvent event) {
                      FocusScope.of(context).unfocus();
                    },

                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                  
                    cursorColor: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                    cursorHeight: 18.h,
                  
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF494239)),
                      ),
                      hintText: _isEmailFocused ? null : S.of(context).email,
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'CenturyGothic',
                        color: const Color(0xFF494239),
                      ),
                      errorStyle: const TextStyle(height: 0),
                      counterText: '',
                
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          width: 1.sp,
                          color: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                        )
                      ),
                
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          width: 2.sp,
                          color: _emailError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                        ),
                      ),
                  
                      // DEF:    DOING CENTERED TEXT DESPITE ICON 
                      contentPadding: EdgeInsets.only(top: 6.h),
                    ),
                  
                    style: TextStyle(
                      fontSize: 16.sp,
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
            ],
          ),
        ),
      
        //? BUTTONS
        Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // BUTTON:    BACK
              Container(
                padding: EdgeInsets.all(3.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(21.r),
                ),
                child: SizedBox(
                  height: 37.h,
                  width: backText.length > 8 ? 130.w : 105.w,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21.r),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                    
                    child: Text(
                      backText,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'CenturyGothic',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),   
             
              // BUTTON:    NEXT
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1.w,
                  ),
                  borderRadius: BorderRadius.circular(21.r),
                ),
                child: SizedBox(
                  height: 37.h,
                  width: nextText.length > 8 ? 130.w : 105.w,
                  child: ElevatedButton(
                    onPressed: () {
                      popupCount = 0;
              
                      if (formKey.currentState!.validate()) {
                        if (!_emailError) {
                          
                        }
                        //return;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(21.r),
                        side: const BorderSide(
                          color: Colors.white,
                          width: 1,
                        ),
                      ),
                    ),
                    
                    child: Text(
                      nextText,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'CenturyGothic',
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),   
            ],
          ),
        )
      ],
    );
  }

}



//? SMS CODE TAB
class SmsCodeTab extends StatefulWidget {
  const SmsCodeTab({super.key});

  @override
  State<SmsCodeTab> createState() => _SmsCodeTabState();
}

class _SmsCodeTabState extends State<SmsCodeTab> {
  final _smsController = TextEditingController();

  final FocusNode _smsFocusNode = FocusNode();
  bool _isSmsFocused = false;
  bool _smsError = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {
    switch (formField) {
      case 'sms':
        setState(() {
          _smsError = true;
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
  Widget build(BuildContext context) {
    String nextText = S.of(context).next;

    return Column(
      children: [
        //? TEXT:    Write down the SMS code
        Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
          child: Text(
            'Write down the SMS code',
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFFFFFFFF),
              fontFamily: 'CenturyGothic'
            ),
          ),
        ),

        // INPUT:    SMS CODE
        Center(
          child: Stack(
            children: [
              Form(
                key: formKey,
                child: Container(
                  height: 52.h,
                  width: double.maxFinite,
                  margin: EdgeInsets.only(left: 100.w, right: 100.w, top: 50.h),
                  child: TextFormField(
                    focusNode: _smsFocusNode,
                    controller: _smsController,
                
                    onTapOutside: (PointerDownEvent event) {
                      FocusScope.of(context).unfocus();
                    },

                    keyboardType: TextInputType.number,

                    maxLength: 6,

                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                  
                    cursorColor: _smsError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                    cursorHeight: 18.h,
                  
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF494239)),
                      ),
                      hintText: _isSmsFocused ? null : S.of(context).sms,
                      hintStyle: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'CenturyGothic',
                        color: const Color(0xFF494239),
                      ),
                      errorStyle: const TextStyle(height: 0),
                      counterText: '',
                
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          width: 1.sp,
                          color: _smsError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                        )
                      ),
                
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.r),
                        borderSide: BorderSide(
                          width: 2.sp,
                          color: _smsError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
                        ),
                      ),
                  
                      // DEF:    DOING CENTERED TEXT DESPITE ICON 
                      contentPadding: EdgeInsets.only(top: 6.h),
                    ),

                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'CenturyGothic',
                      color: Colors.white,
                    ),
                
                    validator: (value) {
                      if (value!.isEmpty) {
                        //return 'You must write your email';
                        showValidationPopup(S.of(context).youMustWriteTheSmsCode, 'sms');
                      } else if (int.tryParse(value) == null) {
                        //return 'Enter valid Email';
                        showValidationPopup(S.of(context).codeMustBeNumeric, 'sms');
                      } else if (value.length < 6) {
                        //return 'Enter valid Email';
                        showValidationPopup(S.of(context).codeMustBe6Charactes, 'sms');
                      } else {
                        setState(() {
                          _smsError = false;
                        });
                        return null;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      
        //? BUTTONS
        Padding(
          padding: EdgeInsets.only(top: 60.h),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(21.r),
              ),
              child: SizedBox(
                height: 37.h,
                width: nextText.length > 8 ? 130.w : 105.w,
                child: ElevatedButton(
                  onPressed: () {
                    popupCount = 0;
            
                    if (formKey.currentState!.validate()) {
                      if (!_smsError) {
                        
                      }
                      //return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.r),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  
                  child: Text(
                    nextText,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'CenturyGothic',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}



//? NEW PASSWORD TAB
class NewPasswordTab extends StatefulWidget {
  const NewPasswordTab({super.key});

  @override
  State<NewPasswordTab> createState() => _NewPasswordTabState();
}

class _NewPasswordTabState extends State<NewPasswordTab> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _passwordError = false;
  
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isConfirmPasswordFocused = false;
  bool _confirmPasswordError = false;

  bool _isPasswordVisible = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {
    switch (formField) {
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    String nextText = S.of(context).confirm;

    return Column(
      children: [
        //? TEXT:    Write down the email to get a code
        Padding(
          padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
          child: Text(
            S.of(context).writeDownTheEmailToGetACode,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              fontSize: 16.sp,
              color: const Color(0xFFFFFFFF),
              fontFamily: 'CenturyGothic'
            ),
          ),
        ),

        SizedBox(height: 30.h),

        // INPUT:     New Password
        Center(
          child: Container(
            height: 45.h,
            width: double.maxFinite,
            margin: EdgeInsets.only(left: 30.w, right: 30.w),
            child: TextFormField(
              focusNode: _passwordFocusNode,
              controller: _passwordController,
            
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
            
              cursorColor: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
              cursorHeight: 18.h,

              onTapOutside: (PointerDownEvent event) {
                FocusScope.of(context).unfocus();
              },

              maxLength: 14,
            
              decoration: InputDecoration(
                hintText: _isPasswordFocused ? null : S.of(context).newPassword,
                hintStyle: const TextStyle(
                  fontSize: 19,
                  fontFamily: 'CenturyGothic',
                  color: Color(0xFF9E9E9E),
                ),
                counterText: '',

                errorStyle: const TextStyle(height: 0),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.sp,
                    color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF)
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
            
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.sp,
                    color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF)
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
            
                // DEF:    DOING CENTERED TEXT DESPITE ICON 
                contentPadding: const EdgeInsets.symmetric(horizontal: 50.0),
            
                // BUTTON:    Visibility ON OFF
                suffixIcon: GestureDetector(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: Transform.translate(
                      offset: const Offset(5, 5),
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
      
        SizedBox(height: 20.h),

        // INPUT:     Confirm Password
        Center(
          child: Container(
            height: 45.h,
            width: double.maxFinite,
            margin: EdgeInsets.only(left: 30.w, right: 30.w),
            child: TextFormField(
              focusNode: _confirmPasswordFocusNode,
              controller: _confirmPasswordController,
            
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
            
              cursorColor: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF),
              cursorHeight: 18.h,

              onTapOutside: (PointerDownEvent event) {
                FocusScope.of(context).unfocus();
              },

              maxLength: 14,
            
              decoration: InputDecoration(
                hintText: _isConfirmPasswordFocused ? null : S.of(context).confirmPassword,
                hintStyle: TextStyle(
                  fontSize: 19.sp,
                  fontFamily: 'CenturyGothic',
                  color: const Color(0xFF9E9E9E),
                ),
                counterText: '',

                errorStyle: const TextStyle(height: 0),

                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.sp,
                    color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF)
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
            
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.sp,
                    color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFFFFFFFF)
                  ),
                  borderRadius: BorderRadius.circular(15.r),
                ),
            
                // DEF:    DOING CENTERED TEXT DESPITE ICON 
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
            
              obscureText: true,
            
              style: TextStyle(
                fontSize: 18.sp,
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
                  
        // BUTTON:    CONFIRM
        Padding(
          padding: EdgeInsets.only(top: 40.h),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 1.w,
                ),
                borderRadius: BorderRadius.circular(21.r),
              ),
              child: SizedBox(
                height: 37.h,
                width: nextText.length > 8 ? 170.w : 125.w,
                child: ElevatedButton(
                  onPressed: () {
                    popupCount = 0;
            
                    if (formKey.currentState!.validate()) {
                      if (!_passwordError && !_confirmPasswordError) {
                        
                      }
                      //return;
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(21.r),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  
                  child: Text(
                    nextText,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'CenturyGothic',
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}