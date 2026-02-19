
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_child/login_for_child/login_for_child.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_child/sign_up_for_child/sign_up_for_child.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_parent/login_for_parent/login_for_parent.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_parent/sign_up_for_parent/sign_up_for_parent.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password_varification/forget_password_varification.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/set_new_password/set_new_password.dart';
import 'package:kids_app_grad/screens/onBoarding/onboarding.dart';
import 'package:kids_app_grad/screens/welcome_screen/welcome_screen.dart';
import '../screens/splash_screen/splash_screen.dart';

class RoutesManager{
static const kLoginForParent = "/loginForParent";
static const kSignUpForParent = "/SignUpForParent";
static const kLoginForChild = "/SignUpForChild";
static const kSignUpForChild = "/SignUpForChild";
static const kOnBoarding = "/onBoarding";
static const kWelcomeScreen = "/welcomeScreen";
static const kForgetPass = "/forgetPass";
static const kForgetPassVarification = "/forgetPassVarification";
static const kSetNewPass = "/setNewPass ";
static const kDashBoard = "/dashBoard";
static const kGamesPlay = "/gamesPlay";
static const kProfileChild = "/childProfile";
static final router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: kLoginForParent,
    builder: (context, state) => const LoginForParent(),
  ),
  GoRoute(
    path: kSignUpForParent,

    builder: (context, state) => const SignUpForParent(),
  ),
  GoRoute(
    path: kLoginForChild,
    builder: (context, state) => const LoginForChild(),
  ),
  GoRoute(
    path: kSignUpForChild,
    builder: (context, state) => const SignUpForChild(),
  ),
  GoRoute(
    path: kWelcomeScreen,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: kForgetPass,
    builder: (context, state) => const ForgetPassword(),
  ),
  GoRoute(
    path: kSetNewPass,
    builder: (context, state) => const SetNewPassword(),
  ),
  GoRoute(
    path: kForgetPassVarification,
    builder: (context, state) => const ForgetPasswordVarification(),
  ),
  GoRoute(
    path: kOnBoarding,
    builder: (context, state) => const Onboarding(),
  ),



]);

}