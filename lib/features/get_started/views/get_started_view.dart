import 'package:flutter/material.dart';
import 'package:uniapp/core/widgets/app_button.dart';
import 'package:uniapp/features/auth/views/login_view.dart';

class GetStartedView extends StatelessWidget {
  const GetStartedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Spacer(),
                Image.asset('assets/icons/PhoeniTalk.png', height: 200),
                Text("Welcome to PhoeniTalk!", style: TextStyle(fontSize: 20)),
                Spacer(),
                AppButton(
                  ontap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginView()),
                    );
                  },
                  child: Text("Continue"),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
