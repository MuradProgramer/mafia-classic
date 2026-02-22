import 'dart:developer';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mafia_classic/extensions/context_extension.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';
import 'package:mafia_classic/l10n/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/services/api_service.dart';
import 'package:mafia_classic/services/locale/locale_service.dart';
import 'package:mafia_classic/services/shared_preferences/extensions/language_prefs.dart';
import 'package:mafia_classic/services/shared_preferences/shared_preferences.dart';
import 'package:mafia_classic/streams/general_stream.dart';
import 'package:mafia_classic/utils/utils.dart';
import 'package:mafia_classic/features/widgets/validation_popup.dart';
import 'package:mafia_classic/utils/popup_utils.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  //String _selectedLanguage = 'English';
  bool _soundEffectsOn = true;

  final List<Map<String, String>> languages = [
    {"code": "en", "label": "English", "flag": "🇬🇧"},
    {"code": "az", "label": "Az", "flag": "🇦🇿"},
    {"code": "ru", "label": "Русский", "flag": "🇷🇺"},
    {"code": "tr", "label": "Tr", "flag": "🇹🇷"},
  ];

  String selectedCode = "en";

  @override
  void initState() {
    selectedCode = SharedPrefsService().getSavedLanguageCode() ?? "en";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/images/background-settings.jpeg"), fit: BoxFit.cover),
      ),
      child: Scaffold(

        body: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // BUTTON:    HOME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),

                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(right: 15.w, top: 40.h),
                    child: Image.asset(
                      'assets/images/home-icon.png',
                      width: 35.w,
                      height: 35.h,
                    ),
                  ),
                ),
              ],
            ),
          
            SizedBox(height: 20.h),

            //? PAGE NAME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(),

                Container(
                  height: 60.h,
                  width: 240.w,
                  margin: EdgeInsets.only(right: 15.h),
                  decoration: BoxDecoration(
                    image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(3.sp),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, 
                        width: 2.sp
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).settings,
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.black,
                          fontSize: 32.sp
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),

            //? SETTINGS OPTIONS
            Container(
              height: 315.h,
              width: double.maxFinite,
              margin: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w),
              decoration: BoxDecoration(
                image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                margin: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, 
                    width: 2.sp
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //? AVATAR
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TEXT:    AVATAR
                        Padding(
                          padding: EdgeInsets.only(left: 25.w),
                          child: Text(
                            AppLocalizations.of(context)!.avatar,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),

                        // BUTTON:    UPLOAD
                        GestureDetector(
                          onTap: () {
                            showBouncingPopupFromLeft(
                              context,
                              const UploadAvatarPopup()
                            );
                          },
                          child: Container(
                            height: 33.h,
                            width: 115.w,
                            margin: EdgeInsets.only(right: 25.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black, 
                                width: 1.sp
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.upload,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    //? NICKNAME
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TEXT:    NICKNAME
                        Padding(
                          padding: EdgeInsets.only(left: 25.w),
                          child: Text(
                            AppLocalizations.of(context)!.nickname,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),

                        // BUTTON:    CHANGE
                        GestureDetector(
                          onTap: () {
                            showBouncingPopupFromLeft(
                              context,
                              const ChangeNicknamePopup()
                            );
                          },
                          child: Container(
                            height: 33.h,
                            width: 115.w,
                            margin: EdgeInsets.only(right: 25.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black, 
                                width: 1.sp
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.change,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    //? PASSWORD
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TEXT:    PASSWORD
                        Padding(
                          padding: EdgeInsets.only(left: 25.w),
                          child: Text(
                            AppLocalizations.of(context)!.password,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),

                        // BUTTON:    CHANGE
                        GestureDetector(
                          onTap: () {
                            showBouncingPopupFromLeft(
                              context,
                              const ChangePasswordPopup()
                            );
                          },
                          child: Container(
                            height: 33.h,
                            width: 115.w,
                            margin: EdgeInsets.only(right: 25.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black, 
                                width: 1.sp
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Text(
                                AppLocalizations.of(context)!.change,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),

                    //? LANGUAGE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // TEXT:    LANGUAGE
                        Padding(
                          padding: EdgeInsets.only(left: 25.w),
                          child: Text(
                            AppLocalizations.of(context)!.language,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),

                        //? DROPDOWN:    LANGUAGE
                        DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            value: selectedCode,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                            customButton: Container(
                              height: 33.h,
                              width: 115.w,
                              margin: EdgeInsets.only(right: 25.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                                borderRadius: BorderRadius.circular(12.r),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  languages.firstWhere((lang) => lang["code"] == selectedCode)["label"]!,
                                  style: TextStyle(
                                    fontSize: 16.w, 
                                    color: Colors.black,
                                    fontFamily: 'CenturyGothic'
                                  ),
                                ),
                              ),
                            ),
                            items: languages
                              //.where((lang) => lang["code"] != selectedCode)
                              .map((lang) {
                              return DropdownMenuItem<String>(
                                value: lang["code"],
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(lang["label"]!, style: TextStyle(fontSize: 14.sp), softWrap: true),
                                    Text(lang["flag"]!, style: TextStyle(fontSize: 20.sp), softWrap: true),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              log('value: $value');
                              if (value != null) {
                                // await SharedPrefsService().saveLanguageCode(value);

                                // GeneralStreams.languageStream.add(
                                //   L10n.locals.firstWhere((locale) => locale.languageCode == value)
                                // );
                                await LocaleService().setLocale(value);
                              }
                              setState(() {
                                selectedCode = value!;
                              });
                            },
                            dropdownStyleData: DropdownStyleData(
                              width: 115.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.white,
                                border: Border.all(color: Colors.black12),
                              ),
                            ),
                            menuItemStyleData: MenuItemStyleData(
                              height: 33.h,
                              //padding: EdgeInsets.symmetric(horizontal: 12.w),
                            ),
                          ),
                        )
                        /*
                        Container(
                          height: 33.h,
                          width: 115.w,
                          margin: EdgeInsets.only(right: 25.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              S.of(context).upload,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        )
                        */
                      ],
                    ),
                  ],
                )
              ),
            ),
          
            //? SOUND EFFECTS
            Container(
              height: 70.h,
              width: double.maxFinite,
              margin: EdgeInsets.only(top: 20.h, left: 10.w, right: 10.w),
              decoration: BoxDecoration(
                image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                margin: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, 
                    width: 2.sp
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // TEXT:    SOUND EFFECTS
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Text(
                        AppLocalizations.of(context)!.soundEffects,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19.sp,
                          fontFamily: 'CenturyGothic'
                        ),
                      ),
                    ),

                    //? RADIO BUTTONS:    SOUND EFFECTS
                    Container(
                      width: 155.w,
                      margin: EdgeInsets.only(right: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //? ON
                          Row(
                            children: [
                              // TEXT:    ON
                              Text(
                                AppLocalizations.of(context)!.onOn,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),

                              //? RADIO BUTTON:    ON
                              GestureDetector(
                                onTap: () => setState(() {
                                  _soundEffectsOn = true;
                                }),
                                child: Container(
                                  height: 23.h,
                                  width: 23.w,
                                  margin: EdgeInsets.only(left: 5.w, right: 15.w),
                                  decoration: BoxDecoration(
                                    color: _soundEffectsOn ? const Color(0xFFFFB000) : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF302B25),
                                      width: 1.sp
                                    ),
                                    borderRadius: BorderRadius.circular(6.r)
                                  ),
                                ),
                              )
                            ],
                          ),
                        
                          //? OFF
                          Row(
                            children: [
                              // TEXT:    OFF
                              Text(
                                AppLocalizations.of(context)!.offOff,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.sp,
                                  fontFamily: 'CenturyGothic'
                                ),
                              ),

                              //? RADIO BUTTON:    ON
                              GestureDetector(
                                onTap: () => setState(() {
                                  _soundEffectsOn = false;
                                }),
                                child: Container(
                                  height: 23.h,
                                  width: 23.w,
                                  margin: EdgeInsets.only(left: 5.w, right: 15.w),
                                  decoration: BoxDecoration(
                                    color: !_soundEffectsOn ? const Color(0xFFFFB000) : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF302B25),
                                      width: 1.sp
                                    ),
                                    borderRadius: BorderRadius.circular(6.r)
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                )
              ),
            ),

            //? REPORT & LOG OUT & DELETE ACCOUNT
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BUTTON:    REPORT
                      GestureDetector(
                        onTap: () {
                          showBouncingPopupFromLeft(
                            context,
                            const ReportPopup()
                          );
                        },
                        child: Container(
                          height: 40.h,
                          width: 170.w,
                          margin: EdgeInsets.only(top: 20.h, left: 10.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              S.of(context).report,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        ),
                      ),

                      // BUTTON:    LOG OUT
                      Container(
                        height: 40.h,
                        width: 170.w,
                        margin: EdgeInsets.only(top: 20.h, right: 10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          border: Border.all(
                            color: Colors.black, 
                            width: 1.sp
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            S.of(context).logOut,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
              
                    ],
                  ),

                  /*
                  // BUTTON:    DELETE ACCOUNT
                  Container(
                    height: 40.h,
                    width: 200.w,
                    margin: EdgeInsets.only(top: 15.h, left: 10.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFFFF),
                      border: Border.all(
                        color: Colors.black, 
                        width: 1.sp
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        S.of(context).deleteAccount,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontFamily: 'CenturyGothic'
                        ),
                      ),
                    ),
                  )
                  */
                ],
              ),
            )
          ],
        )
        /*
        appBar: AppBar(
          title: Text(S.of(context).settings),
          automaticallyImplyLeading: false
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).language),
                  DropdownButton<String>(
                    dropdownColor: const Color.fromARGB(255, 6, 0, 63),
                    value: _selectedLanguage,
                    items: <String>['English', 'Русский', 'Türkçe', 'Azərbaycanca']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLanguage = newValue!;
                      });
                    },
                  )
                ]
              ),
              
              const SizedBox(height: 16.0),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).password),
                  SizedBox(
                    width: 150.0,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).changePassword),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(hintText: S.of(context).oldPassword),
                                  ),
                                  TextField(
                                    obscureText: true,
                                    decoration: InputDecoration(hintText: S.of(context).newPassword),
                                  ),
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ]
              ),
              
              const SizedBox(height: 16.0),
      
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(S.of(context).nickname),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(S.of(context).changeNickname),
                              content: TextField(
                                decoration: InputDecoration(hintText: S.of(context).writeNewNickname),
                              ),
                              actions: [
                                ElevatedButton(
                                  child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Text(S.of(context).change, style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16.0),
      
              ElevatedButton(
                onPressed: () {
                  // change avatar
                },
                child: Text(S.of(context).changeAvatar, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // log out
                },
                child: Text(S.of(context).logOut, style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // delete accaunt
                },
                child: Text(S.of(context).deleteAccaunt, style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        */
      ),
    );
  }
}



class UploadAvatarPopup extends StatefulWidget {
  const UploadAvatarPopup({super.key});

  @override
  State<UploadAvatarPopup> createState() => _UploadAvatarPopupState();
}

class _UploadAvatarPopupState extends State<UploadAvatarPopup> {
  bool _uploadAnother = false;
  final String _currentAvatarUrl = SharedPrefsService.getUserAvatarUrl() ?? "https://www.w3schools.com/w3images/avatar6.png";
  XFile? pickedImage;
  
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, //! 
      child: Column(
        children: [
          // BUTTON:    CLOSE
          Padding(
            padding: EdgeInsets.only(top: 45.h),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Image.asset(
                    'assets/images/close-white-icon.png',
                    width: 25.w,
                    height: 33.h,
                  ),
                ),
              ),
            ),
          ),
      
          SizedBox(height: 20.h),
      
          //? PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
      
              Container(
                height: 60.h,
                width: 240.w,
                margin: EdgeInsets.only(right: 15.h),
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Container(
                  margin: EdgeInsets.all(3.sp),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, 
                      width: 2.sp
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.avatar,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 32.sp
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          //? UPLOAD AVATAR
          Container(
            height: 440.h,
            width: double.maxFinite,
            margin: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w),
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              margin: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, 
                  width: 2.sp
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TEXT:    CURRENT AVATAR
                  Padding(
                    padding: EdgeInsets.only(top: 35.h),
                    child: Text(
                      AppLocalizations.of(context)!.currentAvatar,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                  ),

                  //? AVATAR
                  Container(
                    height: 200.h,
                    width: 200.w,
                    margin: EdgeInsets.only(top: 35.h, bottom: 30.h),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(100.r),
                      image: DecorationImage(
                        image: pickedImage != null
                          ? FileImage(File(pickedImage!.path))
                          : NetworkImage(_currentAvatarUrl) as ImageProvider,
                        fit: BoxFit.cover
                      )
                    ),
                  ),

                  //? UPLOAD NEW | UPLOAD ANOTHER & CONFIRM
                  !_uploadAnother 
                  ? GestureDetector(
                      onTap: () async {
                        setState(() {
                          _uploadAnother = true;
                        });

                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 85,
                        );
                        if (image != null) {
                          setState(() {
                            pickedImage = image;
                          });
                        }
                      },
                      child: Container(
                        height: 35.h,
                        width: AppLocalizations.of(context)!.uploadNew.length <= 9 ? 120.w : 135.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          border: Border.all(
                            color: Colors.black, 
                            width: 1.sp
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.uploadNew,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
                    )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // BUTTON:    UPLOAD ANOTHER
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 85,
                          );
                          if (image != null) {
                            setState(() {
                              pickedImage = image;
                            });
                          }
                        },
                        child: Container(
                          height: 35.h,
                          width: 140.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.uploadAnother,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        ),
                      ),

                      // BUTTON:    CONFIRM
                      GestureDetector(
                        onTap: () async {
                          setState(() {
                            _uploadAnother = false;
                          });
                          if (pickedImage != null) {
                            String avatar = await GetIt.I<ApiService>().uploadAvatar(pickedImage!);
                            print("SETTED NEW AVATAR IN SETTINGS SCREEN: $avatar");
                            setState(() {
                              authorizedUser.avatarUrl = avatar;
                              SharedPrefsService.setAvatarUrl(avatar);
                            });
                          }
                        },
                        child: Container(
                          height: 35.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        ),
                      )
                    ]
                  )
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}



class ChangeNicknamePopup extends StatefulWidget {
  const ChangeNicknamePopup({super.key});

  @override
  State<ChangeNicknamePopup> createState() => _ChangeNicknamePopupState();
}

class _ChangeNicknamePopupState extends State<ChangeNicknamePopup> {
  final _nicknameController = TextEditingController();

  final FocusNode _nicknameFocusNode = FocusNode();
  bool _isNicknameFocused = false;
  bool _nicknameError = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {

    if (formField == 'nickname') {
      setState(() {
        _nicknameError = true;
      });
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
        _isNicknameFocused = _nicknameFocusNode.hasFocus;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();

    _nicknameFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, //! 
      child: Column(
        children: [
          // BUTTON:    CLOSE
          Padding(
            padding: EdgeInsets.only(top: 45.h),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Image.asset(
                    'assets/images/close-white-icon.png',
                    width: 25.w,
                    height: 33.h,
                  ),
                ),
              ),
            ),
          ),
      
          SizedBox(height: 20.h),
      
          //? PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
      
              Container(
                height: 60.h,
                width: 240.w,
                margin: EdgeInsets.only(right: 15.h),
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Container(
                  margin: EdgeInsets.all(3.sp),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, 
                      width: 2.sp
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.nickname,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 32.sp
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          //? CHANGE NICKNAME
          Container(
            height: 440.h,
            width: double.maxFinite,
            margin: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w),
            decoration: BoxDecoration(
              image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Container(
              margin: EdgeInsets.all(5.sp),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black, 
                  width: 2.sp
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // TEXT:    CURRENT NICKNAME
                  Padding(
                    padding: EdgeInsets.only(top: 35.h),
                    child: Text(
                      AppLocalizations.of(context)!.currentNickname,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.sp,
                        fontFamily: 'CenturyGothic'
                      ),
                    ),
                  ),

                  //? NICKNAME
                  Padding(
                    padding: EdgeInsets.only(top: 35.h),
                    child: Text(
                      'Peter Parker',
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 24.sp,
                      ),
                    ),
                  ),

                  //? DIVIDER
                  Container(
                    height: 2.h,
                    width: double.maxFinite,
                    margin: EdgeInsets.only(top: 30.h, bottom: 30.h, left: 30.w, right: 30.w),
                    color: const Color(0xFF494239),
                  ),

                  //? NEW NICKNAME
                  Center(
                    child: Stack(
                      children: [
                        Form(
                          key: formKey,
                          child: Container(
                            height: 45.h,
                            width: double.maxFinite,
                            margin: EdgeInsets.only(left: 30.w, right: 30.w, top: 30.h),
                            child: TextFormField(
                              focusNode: _nicknameFocusNode,
                              controller: _nicknameController,
                          
                              onTapOutside: (PointerDownEvent event) {
                                FocusScope.of(context).unfocus();
                              },
                          
                              maxLength: 14,

                            
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                            
                              cursorColor: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                              cursorHeight: 18.h,
                            
                              decoration: InputDecoration(
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF494239)),
                                ),
                                hintText: _isNicknameFocused ? null : AppLocalizations.of(context)!.nickname,
                                hintStyle: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'CenturyGothic',
                                  color: const Color(0xFF494239),
                                ),
                                errorStyle: const TextStyle(height: 0),
                                counterText: '',
                          
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                  borderSide: BorderSide(
                                    width: 2.sp,
                                    color: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                                  )
                                ),
                          
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15.r),
                                  borderSide: BorderSide(
                                    width: 2.sp,
                                    color: _nicknameError ? const Color(0xFFBC4434) : const Color(0xFF000000),
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
                                  //return 'You must write your nickname';
                                  showValidationPopup(S.of(context).youMustWriteYourNickname, 'nickname');
                                  //return '';
                                  return null;
                                } else if (value.length < 3) {
                                  //return 'Your nickname must contain at least 3 characters';
                                  showValidationPopup(S.of(context).yourNicknameMustContainAtLeast3Characters, 'nickname');
                                  //return '';
                                  return null;
                                } else if (!RegExp(r'^[a-zA-Z0-9._-]*$').hasMatch(value)) {
                                  //return 'Your nickname can contain, letters, numbers and . _ -';
                                  showValidationPopup(S.of(context).yourNicknameCanContainLettersNumbersAnd, 'nickname');
                                  //return '';
                                  return null;
                                } else {
                                  setState(() {
                                    _nicknameError = false;
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

                  // BUTTON:    CONFIRM
                  Container(
                    margin: EdgeInsets.only(top: 60.h),
                    child: GestureDetector(
                      onTap: () {
                        popupCount = 0;
                    
                        if (formKey.currentState!.validate()) {
                          if (!_nicknameError) {
                            
                          }
                        }
                      },
                      child: Container(
                        height: 35.h,
                        width: 120.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFFFF),
                          border: Border.all(
                            color: Colors.black, 
                            width: 1.sp
                          ),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.confirm,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontFamily: 'CenturyGothic'
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                
                ],
              ),
            )
          ),
        ],
      ),
    );
  }
}



class ChangePasswordPopup extends StatefulWidget {
  const ChangePasswordPopup({super.key});

  @override
  State<ChangePasswordPopup> createState() => _ChangePasswordPopupState();
}

class _ChangePasswordPopupState extends State<ChangePasswordPopup> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();

  final FocusNode _passwordFocusNode = FocusNode();
  bool _isPasswordFocused = false;
  bool _passwordError = false;
  
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  bool _isConfirmPasswordFocused = false;
  bool _confirmPasswordError = false;

  bool _isPasswordVisible = false;
  bool _isCurrentPasswordVisible = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {

    if (formField == 'password') {
      setState(() {
        _passwordError = true;
      });
    } else {
      setState(() {
        _confirmPasswordError = true;
      });
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
    _currentPasswordController.text = 'current_password'; // For demo purposes only

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
    return Material(
      type: MaterialType.transparency, //! 
      child: Column(
        children: [
          // BUTTON:    CLOSE
          Padding(
            padding: EdgeInsets.only(top: 45.h),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Image.asset(
                    'assets/images/close-white-icon.png',
                    width: 25.w,
                    height: 33.h,
                  ),
                ),
              ),
            ),
          ),
      
          SizedBox(height: 20.h),
      
          //? PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
      
              Container(
                height: 60.h,
                width: 240.w,
                margin: EdgeInsets.only(right: 15.h),
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Container(
                  margin: EdgeInsets.all(3.sp),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, 
                      width: 2.sp
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.password,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 32.sp
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          //? CHANGE PASSWORD
          Form(
            key: formKey,
            child: Container(
              height: 440.h,
              width: double.maxFinite,
              margin: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w),
              decoration: BoxDecoration(
                image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                margin: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, 
                    width: 2.sp
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TEXT:    CURRENT PASSWORD
                    Padding(
                      padding: EdgeInsets.only(top: 35.h, bottom: 25.h),
                      child: Text(
                        AppLocalizations.of(context)!.currentPassword,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontFamily: 'CenturyGothic'
                        ),
                      ),
                    ),
            
                    //? CURRENT PASSWORD
                    Center(
                      child: Container(
                        height: 45.h,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(left: 30.w, right: 30.w),
                        child: TextFormField(
                          controller: _currentPasswordController,
                          
                          readOnly: true,
                        
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                        
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF494239), width: 2.sp),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            hintText: _isPasswordFocused ? null : AppLocalizations.of(context)!.password,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF494239), width: 2.sp),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
            
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: const Color(0xFF494239), width: 2.sp),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
            
                            errorStyle: const TextStyle(height: 0),
                        
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
                                    _isCurrentPasswordVisible
                                      ? 'assets/images/visibility-dark-on.png'
                                      : 'assets/images/visibility-dark-off.png',
                                  ),
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                                });
                              },
                            ),
                          ),
                        
                          obscureText: !_isCurrentPasswordVisible,
                        
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            
                    //? DIVIDER
                    Container(
                      height: 2.h,
                      width: double.maxFinite,
                      margin: EdgeInsets.only(top: 30.h, bottom: 30.h, left: 30.w, right: 30.w),
                      color: const Color(0xFF494239),
                    ),
            
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
                        
                          cursorColor: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,
            
                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
            
                          maxLength: 14,
                        
                          decoration: InputDecoration(
                            hintText: _isPasswordFocused ? null : AppLocalizations.of(context)!.newPassword,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',
            
                            errorStyle: const TextStyle(height: 0),
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _passwordError ? const Color(0xFFBC4434) : const Color(0xFF494239)
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
                        
                          cursorColor: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,
            
                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
            
                          maxLength: 14,
                        
                          decoration: InputDecoration(
                            hintText: _isConfirmPasswordFocused ? null : AppLocalizations.of(context)!.confirmPassword,
                            hintStyle: const TextStyle(
                              fontSize: 19,
                              fontFamily: 'CenturyGothic',
                              color: Color(0xFF494239),
                            ),
                            counterText: '',
            
                            errorStyle: const TextStyle(height: 0),
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _confirmPasswordError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            // DEF:    DOING CENTERED TEXT DESPITE ICON 
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        
                          obscureText: true,
                        
                          style: const TextStyle(
                            fontSize: 18,
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
                    Container(
                      margin: EdgeInsets.only(top: 40.h),
                      child: GestureDetector(
                        onTap: () {
                          popupCount = 0;
                      
                          if (formKey.currentState!.validate()) {
                            if (!_passwordError && !_confirmPasswordError) {
                              
                            }
                          }
                        },
                        child: Container(
                          height: 35.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              AppLocalizations.of(context)!.confirm,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}



class ReportPopup extends StatefulWidget {
  const ReportPopup({super.key});

  @override
  State<ReportPopup> createState() => _ReportPopupState();
}

class _ReportPopupState extends State<ReportPopup> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  final FocusNode _titleFocusNode = FocusNode();
  bool _isTitleFocused = false;
  bool _titleError = false;
  
  final FocusNode _contentFocusNode = FocusNode();
  bool _isContentFocused = false;
  bool _contentError = false;

  int popupCount = 0;
  final formKey = GlobalKey<FormState>();

  void showValidationPopup(String content, String formField) {

    if (formField == 'title') {
      setState(() {
        _titleError = true;
      });
    } else {
      setState(() {
        _contentError = true;
      });
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
    _titleFocusNode.addListener(() {
      setState(() {
        _isTitleFocused = _titleFocusNode.hasFocus;
      });
    });

    _contentFocusNode.addListener(() {
      setState(() {
        _isContentFocused = _contentFocusNode.hasFocus;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();

    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency, //! 
      child: Column(
        children: [
          // BUTTON:    CLOSE
          Padding(
            padding: EdgeInsets.only(top: 45.h),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 20.w),
                  child: Image.asset(
                    'assets/images/close-white-icon.png',
                    width: 25.w,
                    height: 33.h,
                  ),
                ),
              ),
            ),
          ),
      
          SizedBox(height: 20.h),
      
          //? PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
      
              Container(
                height: 60.h,
                width: 240.w,
                margin: EdgeInsets.only(right: 15.h),
                decoration: BoxDecoration(
                  image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Container(
                  margin: EdgeInsets.all(3.sp),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black, 
                      width: 2.sp
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)!.report,
                      style: GoogleFonts.playfairDisplay(
                        color: Colors.black,
                        fontSize: 30.sp
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),

          //? REPORT
          Form(
            key: formKey,
            child: Container(
              height: 440.h,
              width: double.maxFinite,
              margin: EdgeInsets.only(top: 60.h, left: 10.w, right: 10.w),
              decoration: BoxDecoration(
                image: const DecorationImage(image: AssetImage("assets/images/background_player_info_popup.png"), fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Container(
                margin: EdgeInsets.all(5.sp),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black, 
                    width: 2.sp
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // TEXT:    In case of any problem, please notify us
                    Padding(
                      padding: EdgeInsets.only(top: 25.h, bottom: 15.h, left: 30.w, right: 30.w),
                      child: Text(
                        AppLocalizations.of(context)!.inCaseOfAnyProblemPleaseNotifyUs,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 19.sp,
                          fontFamily: 'CenturyGothic',
                        ),
                        softWrap: true,
                        maxLines: 2,
                      ),
                    ),

                    // INPUT:     TITLE
                    Center(
                      child: Container(
                        height: 45.h,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(left: 30.w, right: 30.w),
                        child: TextFormField(
                          focusNode: _titleFocusNode,
                          controller: _titleController,
                        
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.center,
                        
                          cursorColor: _titleError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,
            
                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
                        
                          decoration: InputDecoration(
                            hintText: _isTitleFocused ? null : AppLocalizations.of(context)!.title,
                            hintStyle: TextStyle(
                              fontSize: 19.sp,
                              fontFamily: 'CenturyGothic',
                              color: const Color(0xFF494239),
                            ),
                            counterText: '',
            
                            errorStyle: const TextStyle(height: 0),
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _titleError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _titleError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            // DEF:    DOING CENTERED TEXT DESPITE ICON 
                            contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
                          ),
                        
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),
            
                          validator: (value) {
                            if (value!.isEmpty) {
                              showValidationPopup(AppLocalizations.of(context)!.youMustWriteATitleOfTheReport, 'title');
                              return null;
                            } else {
                              setState(() {
                                _titleError = false;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    ),

                    // INPUT:     CONTENT
                    Center(
                      child: Container(
                        height: 180.h,
                        width: double.maxFinite,
                        margin: EdgeInsets.only(left: 30.w, right: 30.w, top: 10.h),
                        child: TextFormField(
                          focusNode: _contentFocusNode,
                          controller: _contentController,
                          keyboardType: TextInputType.multiline,

                          maxLines: null,
                          expands: true,
                        
                          textAlign: TextAlign.start,
                          textAlignVertical: TextAlignVertical.top,
                        
                          cursorColor: _contentError ? const Color(0xFFBC4434) : const Color(0xFF494239),
                          cursorHeight: 18.h,
            
                          onTapOutside: (PointerDownEvent event) {
                            FocusScope.of(context).unfocus();
                          },
                        
                          decoration: InputDecoration(
                            hintText: _isContentFocused ? null : AppLocalizations.of(context)!.typeHere,
                            hintStyle: TextStyle(
                              fontSize: 19.sp,
                              fontFamily: 'CenturyGothic',
                              color: const Color(0xFF494239),
                            ),
                            counterText: '',
            
                            errorStyle: const TextStyle(height: 0),
            
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _contentError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.sp,
                                color: _contentError ? const Color(0xFFBC4434) : const Color(0xFF494239)
                              ),
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                        
                            // DEF:    DOING CENTERED TEXT DESPITE ICON 
                            contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                          ),
                        
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'CenturyGothic',
                            color: Colors.white,
                          ),
            
                          validator: (value) {
                            if (value!.isEmpty) {
                              showValidationPopup(AppLocalizations.of(context)!.youMustWriteYourReport, 'content');
                              return null;
                            } else {
                              setState(() {
                                _contentError = false;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    ),

                    // BUTTON:    SEND
                    Container(
                      margin: EdgeInsets.only(top: 30.h),
                      child: GestureDetector(
                        onTap: () {
                          popupCount = 0;
                      
                          if (formKey.currentState!.validate()) {
                            if (!_titleError && !_contentError) {
                              
                            }
                          }
                        },
                        child: Container(
                          height: 35.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF),
                            border: Border.all(
                              color: Colors.black, 
                              width: 1.sp
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              S.of(context).confirm,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.sp,
                                fontFamily: 'CenturyGothic'
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}