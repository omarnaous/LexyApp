import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lexyapp/Features/Authentication/Business%20Logic/auth_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/cubit/home_page_cubit.dart';
import 'package:lexyapp/Features/Home%20Features/Logic/nav_cubit.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/edit_profile.dart';
import 'package:lexyapp/Features/User%20Profile%20Management/Presentation/Pages/profile.dart';
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
              context
                  .read<AuthCubit>()
                  .signInWithApple(context)
                  .whenComplete(() async {
                // ignore: use_build_context_synchronously
                BlocProvider.of<HomePageCubit>(context).initializeListeners();
                // ignore: use_build_context_synchronously
                await Future.delayed(const Duration(milliseconds: 1));

                Navigator.of(context).pop();

                await Future.delayed(const Duration(milliseconds: 1));

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const EditProfilePage();
                  },
                ));
              });
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
                  .whenComplete(() async {
                // ignore: use_build_context_synchronously
                BlocProvider.of<HomePageCubit>(context).initializeListeners();
                // ignore: use_build_context_synchronously
                await Future.delayed(const Duration(milliseconds: 1));

                Navigator.of(context).pop();

                await Future.delayed(const Duration(milliseconds: 1));

                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) {
                    return const EditProfilePage();
                  },
                ));
              });
            },
          ),
        ),
      ],
    );
  }
}
