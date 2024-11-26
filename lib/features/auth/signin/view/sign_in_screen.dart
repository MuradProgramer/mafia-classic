import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mafia_classic/generated/l10n.dart';
import 'package:mafia_classic/mafia_classic_app.dart';
import 'package:mafia_classic/blocs/sign_in/sign_in_bloc.dart';
import 'package:mafia_classic/features/auth/signup/signup.dart';

class SignInScreen extends StatefulWidget {

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        image: DecorationImage(image: AssetImage("assets/modern-tall-buildings-1.png"), fit: BoxFit.cover, opacity: 0.4),
      ),
      child: Scaffold(
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),              
              );
              debugPrint(state.error);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 50,),
                TextFormField(
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  decoration: InputDecoration(
                    labelText: S.of(context).email,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                TextFormField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(
                    labelText: S.of(context).password,
                    labelStyle: TextStyle(color: Colors.white.withOpacity(0.7))
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<SignInBloc>().add(
                            SignInRequested(
                              _emailController.text,
                              _passwordController.text,
                            ),
                          );
                  },
                  child: Text(S.of(context).signIn, style: const TextStyle(color: Colors.white),),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpScreen()),
                    );
                  },
                  child: Text(S.of(context).dontHaveAccauntRegister, style: const TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
