import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Business%20Store/Presentation/Pages/bus_signin.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Pages/sign_in.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Widgets/email_input.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Widgets/ordivider.dart';
import 'package:lexyapp/Features/Authentication/Presentation/Widgets/social_login.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {},
        child: Center(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Log in or sign up",
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16), // Spacing after title
                    Text(
                      "Create your account or log in to book and manage your salon appointments effortlessly!",
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 16), // Spacing after text
                    const SocialLoginColumn(),
                    const SizedBox(height: 16), // Spacing before divider
                    const OrDivider(),
                    const SizedBox(height: 16), // Spacing before form
                    const EmailForm(),
                    const SizedBox(height: 16), // Spacing before form
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) {
                            return const BasicSignIn(
                              title: 'Sign In ',
                            ); // Replace with your sign-in page
                          },
                        ));
                      },
                      child: const Text(
                        "Already have an account? Sign In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple, // Deep purple text color
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 16),
                      child: Text(
                        "Have a business account?",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5, top: 8),
                      child: GestureDetector(
                        onTap: () {
                          context.read<NavBarCubit>().hideNavBar();
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) {
                              return const BusinessSignIn();
                            },
                          ));
                        },
                        child: Text(
                          "Sign in or Sign up as a professional",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
