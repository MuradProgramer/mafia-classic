//? GameOver
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';

class GameOverPopup extends StatefulWidget {
  final bool isMafiaWinner;
  final int score;

  const GameOverPopup({super.key, required this.isMafiaWinner, required this.score});

  @override
  State<GameOverPopup> createState() => _GameOverPopupState();
}

class _GameOverPopupState extends State<GameOverPopup> with TickerProviderStateMixin {

  late final AnimationController _winnerLabelController;
  late final AnimationController _winnerValueController;
  late final AnimationController _scoreLabelController;
  late final AnimationController _scoreValueController;

  bool showWinnerValue = false;
  bool showScoreLabel = false;
  bool showScoreValue = false;

  @override
  void initState() {
    super.initState();

    _winnerLabelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _winnerValueController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scoreLabelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scoreValueController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 400));
    await _winnerLabelController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => showWinnerValue = true);
    await _winnerValueController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => showScoreLabel = true);
    await _scoreLabelController.forward();

    await Future.delayed(const Duration(milliseconds: 400));
    setState(() => showScoreValue = true);
    _scoreValueController.forward();
  }

  @override
  void dispose() {
    _winnerLabelController.dispose();
    _winnerValueController.dispose();
    _scoreLabelController.dispose();
    _scoreValueController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.height * 0.55,
          padding: EdgeInsets.all(5.sp),
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage(
                'assets/images/background_game_over_popup.png',
              ),
              fit: BoxFit.cover,
              alignment: Alignment(0, -0.6),
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white,
                width: 1.5.w
              ),
              borderRadius: BorderRadius.circular(16.r)
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                                
                    //BUTTON:    X
                    Padding(
                      padding: EdgeInsets.only(top: 10.h, right: 10.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              PopupManager().close('gameOverPopup');
                            },
                            child: Image.asset(
                              'assets/images/close-white-icon.png',
                              height: 30.h,
                              width: 23.w,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                                
                // TEXT:    Game Over
                Padding(
                  padding: EdgeInsets.only(top: 25.h, bottom: 10.h, left: 20.w, right: 20.w),
                  child: Text(
                    textAlign: TextAlign.center,
                    'Game Over',
                    style: TextStyle(
                      height: 0,
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF83725C),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                //? WINNER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _winnerLabelController,
                      builder: (context, child) {
                        final offset =
                            50 * (1 - _winnerLabelController.value); // slide from left
                        return Opacity(
                          opacity: _winnerLabelController.value,
                          child: Transform.translate(
                            offset: Offset(offset, 0),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        "WINNER:",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    if (showWinnerValue)
                      AnimatedBuilder(
                        animation: _winnerValueController,
                        builder: (context, child) {
                          final offset =
                              50 * (1 - _winnerValueController.value); // slide from right
                          return Opacity(
                            opacity: _winnerValueController.value,
                            child: Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          widget.isMafiaWinner ? "MAFIA": "CIVILIANS",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                  ],
                ),

                //? SCORE
                if (showScoreLabel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _scoreLabelController,
                        builder: (context, child) {
                          final offset =
                              50 * (1 - _scoreLabelController.value); // slide from left
                          return Opacity(
                            opacity: _scoreLabelController.value,
                            child: Transform.translate(
                              offset: Offset(offset, 0),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          "SCORE:",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      if (showScoreValue)
                        TweenAnimationBuilder<int>(
                          tween: IntTween(begin: 0, end: widget.score),
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeOut,
                          builder: (context, value, _) => Text(
                            "$value",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          )
        ),
      ),
    );
  }
}
