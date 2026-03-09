import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mafia_classic/features/games/game/view/game_screen.dart';
import 'package:mafia_classic/features/games/popups/game_information_popup.dart';
import 'package:mafia_classic/features/profile/roles/models/models.dart';
import 'package:mafia_classic/l10n/app_localizations.dart';

import 'role_card_popup.dart';

class RoleCard extends StatefulWidget {
  final String roleName;
  final double width;
  final double height;
  final bool isMini;
  final bool enabled;

  const RoleCard({
    super.key, 
    required this.roleName, 
    required this.width, 
    required this.height, 
    required this.isMini,
    this.enabled = true
  });

  @override
  State<RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<RoleCard> with SingleTickerProviderStateMixin {
  OverlayEntry? _overlayEntry;
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  Map<String, String> get rolesLocalizaitons => {
    'mafia': AppLocalizations.of(context)!.mafia,
    'civilian': AppLocalizations.of(context)!.civilian,
    'spy': AppLocalizations.of(context)!.spy,
    'doctor': AppLocalizations.of(context)!.doctor,
    'beauty': AppLocalizations.of(context)!.beauty,
    'bodyguard': AppLocalizations.of(context)!.bodyguard,
    'barman': AppLocalizations.of(context)!.barman,
    'informant': AppLocalizations.of(context)!.informant,
    'sheriff': AppLocalizations.of(context)!.sheriff,
    'journalist': AppLocalizations.of(context)!.journalist,
    'terrorist': AppLocalizations.of(context)!.terrorist,
    'undef': AppLocalizations.of(context)!.uknown,
    'uknown': AppLocalizations.of(context)!.uknown,
    'noname': AppLocalizations.of(context)!.uknown,
  };

  String getAssetByRole() {
    switch (widget.roleName.toLowerCase()) {
      case "mafia":
        return 'assets/images/role-card-mark-mafia.png';

      case "civilian":
        return 'assets/images/role-card-mark-civilian.png';

      case "bodyguard":
        return 'assets/images/role-card-mark-protected.png';

      case "journalist":
        return 'assets/images/role-card-mark-interviewed.png';

      case "beauty":
        return 'assets/images/role-card-mark-satisfied.png';

      case "doctor":
        return 'assets/images/role-card-mark-cured.png';
        
      case "sheriff":
        return 'assets/images/role-card-mark-investigated.png';

      case "spy":
        return 'assets/images/role-card-mark-spy.png';

      case "terrorist":
        return 'assets/images/role-card-mark-terrorist.png';

      case "informant":
        return 'assets/images/role-card-mark-revealed.png';

      case "barman":
        return 'assets/images/role-card-mark-intoxicated.png';

      default:
        return 'assets/images/role-card-mark-unknown.png';
    }
  }

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(_controller);

    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showTooltip() {
    if (_overlayEntry != null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: offset.dx + renderBox.size.width / 2 - 40,
          top: offset.dy - 40,
          child: Material(
            color: Colors.transparent,
            child: SlideTransition(
              position: _slide,
              child: ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _opacity,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.6),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Text(
                      rolesLocalizaitons[widget.roleName.toLowerCase()]!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
    _controller.forward();

    // Auto hide
    Future.delayed(const Duration(seconds: 1), () => _hideTooltip());
  }

  void _hideTooltip() async {
    if (_overlayEntry == null) return;
    await _controller.reverse();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: GestureDetector(
        onTap: () {
          if (widget.enabled) {
            if (widget.isMini) {
              PopupManager().show(
                context: context,
                id: 'informationPopup',
                builder: (_) => InformationPopup(
                  effect: widget.roleName,
                )
              );
              return;
            }
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: "Dismiss",
              barrierColor: Colors.black.withOpacity(0.7),
              transitionDuration: const Duration(milliseconds: 800),
              pageBuilder: (context, animation, secondaryAnimation) {
                return RoleCardPopup(roleName: widget.roleName, closeType: 1);
              },
              transitionBuilder: (context, animation, secondaryAnimation, child) {
                final curvedAnimation = CurvedAnimation(
                  parent: animation,
                  curve: Curves.elasticOut,
                  reverseCurve: Curves.easeInBack,
                );

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1.0, 0.0),
                    end: Offset.zero,
                  ).animate(curvedAnimation),
                  child: child,
                );
              },
            ).then((value) {
              FocusScope.of(context).unfocus();
            });
          } else {
            if (_overlayEntry != null) {
              _hideTooltip();
            } else {
              _showTooltip();
            }
          }                         
        },
        child: Image.asset(
          width: widget.width,
          height: widget.height,
          (widget.isMini) 
          ? getAssetByRole()
          : 'assets/images/role-card-${widget.roleName.toLowerCase()}.png',
          fit: BoxFit.scaleDown,
        ),
      ),
    );
  }
}