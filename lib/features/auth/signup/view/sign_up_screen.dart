import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_up/sign_up_bloc.dart';
import 'package:mafia_classic/features/auth/signin/signin.dart';

class SignUpScreen extends StatelessWidget {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
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
            padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 6),
            child: Column(
              children: [
                TextField(
                  controller: _nicknameController,
                  decoration: InputDecoration(
                    labelText: S.of(context).nickname,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: S.of(context).email,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: S.of(context).password,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                TextField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: S.of(context).confirmPassword,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
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
                  child: Text(S.of(context).signUp, style: const TextStyle(color: Colors.white)),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    );
                  },
                  child: Text(S.of(context).alreadyHaveAccauntSigIn, style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
