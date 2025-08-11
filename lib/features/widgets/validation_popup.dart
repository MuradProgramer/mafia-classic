import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ValidationPopup extends StatefulWidget {
  final double height;
  final double width;
  final int popupType;
  final int statusCode;
  final String content;

  const ValidationPopup({
    super.key, 
    required this.height, 
    required this.width, 
    required this.popupType, 
    required this.statusCode, 
    required this.content,
  });

  @override
  State<ValidationPopup> createState() => _ValidationPopupState();
}

class _ValidationPopupState extends State<ValidationPopup> {
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: EdgeInsets.only(top: 35.h),
        height: widget.height,
        width: widget.width,
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/popup_${widget.popupType}.png",
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  top: widget.popupType == 1 ? 50.h : 10.h,
                  left: widget.popupType == 1 ? 0.h : 40.w,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: widget.popupType == 1 ? 200.w : 80.w,
                    child: Text(
                      widget.content,
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CenturyGothic',
                        color: const Color(0xFF000000),
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}