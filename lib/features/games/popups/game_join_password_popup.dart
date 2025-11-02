import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class GameJoinPasswordPopup extends StatefulWidget {
  const GameJoinPasswordPopup({super.key});

  @override
  State<GameJoinPasswordPopup> createState() => _GameJoinPasswordPopupState();
}

class _GameJoinPasswordPopupState extends State<GameJoinPasswordPopup> {
  final _passwordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  final bool _isPasswordFocused = false;
  final bool _passwordError = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 355.w,
          height: 470.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Container(
            margin: EdgeInsets.all(10.sp),
            padding: EdgeInsets.only(top: 10.h),
            decoration: BoxDecoration(
              border: BoxBorder.all(color: const Color(0xFFFFFFFF), width: 2.w),
              borderRadius: BorderRadius.circular(75.r),
            ),
            child: Column(
              children: [
                // TEXT:    BEFORE JOINING THE ROOM
                Padding(
                  padding: EdgeInsets.only(top: 25.h, bottom: 10.h, left: 20.w, right: 20.w),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Before Joining The Room',
                    style: GoogleFonts.playfairDisplay(
                      height: 0,
                      fontSize: 36.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFFFB000),
                    ),
                  ),
                ),

                Column(
                  children: [
                    //? TEXT:    Enter the password
                    Padding(
                      padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
                      child: Text(
                        'You must enter the password',
                        textAlign: TextAlign.center,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: const Color(0xFFFFFFFF),
                          fontFamily: 'CenturyGothic',
                        ),
                      ),
                    ),

                    // INPUT:    Password
                    Center(
                      child: Stack(
                        children: [
                          Form(
                            key: formKey,
                            child: Container(
                              height: 52.h,
                              width: double.maxFinite,
                              margin: EdgeInsets.only(
                                left: 50.w,
                                right: 50.w,
                                top: 50.h,
                              ),
                              child: TextFormField(
                                focusNode: _passwordFocusNode,
                                controller: _passwordController,

                                onTapOutside: (PointerDownEvent event) {
                                  FocusScope.of(context).unfocus();
                                },

                                //keyboardType: TextInputType.number,

                                textAlign: TextAlign.center,
                                textAlignVertical: TextAlignVertical.center,

                                cursorColor: _passwordError
                                    ? const Color(0xFFBC4434)
                                    : const Color(0xFFFFFFFF),
                                cursorHeight: 18.h,

                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFF494239),
                                    ),
                                  ),
                                  hintText: _isPasswordFocused
                                      ? null
                                      : 'password',
                                  hintStyle: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: 'CenturyGothic',
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  errorStyle: const TextStyle(height: 0),
                                  counterText: '',

                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                    borderSide: BorderSide(
                                      width: 1.w,
                                      color: _passwordError
                                          ? const Color(0xFFBC4434)
                                          : const Color(0xFFFFFFFF),
                                    ),
                                  ),

                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                    borderSide: BorderSide(
                                      width: 2.w,
                                      color: _passwordError
                                          ? const Color(0xFFBC4434)
                                          : const Color(0xFFFFFFFF),
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
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //? BUTTONS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(4.sp),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.w),
                                borderRadius: BorderRadius.circular(21.r),
                              ),
                              child: SizedBox(
                                height: 37.h,
                                width: "Cancel".length > 8 ? 130.w : 120.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    popupCount = 0;

                                    Navigator.of(context, rootNavigator: true).pop(null);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFFFFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21.r),
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 1.w,
                                      ),
                                    ),
                                  ),

                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                      fontSize: 20.w,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'CenturyGothic',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.only(top: 50.h),
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(4.sp),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white, width: 1.w),
                                borderRadius: BorderRadius.circular(21.r),
                              ),
                              child: SizedBox(
                                height: 37.h,
                                width: "Join".length > 8 ? 130.w : 120.w,
                                child: ElevatedButton(
                                  onPressed: () {
                                    popupCount = 0;

                                    // if (formKey.currentState!.validate()) {
                                    //   if (!_passwordError) {}
                                    //   //return;
                                    // }
                                    log("TEXT: ${_passwordController.text}");
                                    Navigator.of(context, rootNavigator: true).pop(_passwordController.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB000),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(21.r),
                                      side: BorderSide(
                                        color: Colors.white,
                                        width: 1.w,
                                      ),
                                    ),
                                  ),

                                  child: Text(
                                    "Join",
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'CenturyGothic',
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
