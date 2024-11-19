import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:social_auth_btn_kit/social_auth_btn_kit.dart';
import 'package:social_auth_btn_kit/social_auth_btn_variants.dart';

class SocialLoginColumn extends StatelessWidget {
  const SocialLoginColumn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SocialAuthBtn.apple(
            variant: AppleTypeVariants.outlined,
            onPressed: () {
              debugPrint("DEBUG: Apple Btn Pressed");
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SocialAuthBtn.facebook(
            variant: FacebookTypeVariants.outlined,
            theme: FacebookThemeVariants.light,
            onPressed: () {
              debugPrint("DEBUG: Facebook Btn Pressed");
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SocialAuthBtn.google(
            theme: GoogleThemeVariants.light,
            onPressed: () {
              context
                  .read<AuthCubit>()
                  .signInWithGoogle(context)
                  .whenComplete(() {
                BlocProvider.of<HomePageCubit>(context).initializeListeners();
                Navigator.of(context).pop();
              });
            },
          ),
        ),
      ],
    );
  }
}
