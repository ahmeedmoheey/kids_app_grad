
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_child/sign_up_for_child/sign_up_for_child.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_parent/sign_up_for_parent/sign_up_for_parent.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password_varification/forget_password_varification.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/set_new_password/set_new_password.dart';
import 'package:kids_app_grad/screens/dashboard_screen/dashboard_screen.dart';
import 'package:kids_app_grad/screens/games_screen/games_screen.dart';
import 'package:kids_app_grad/screens/onBoarding/onboarding.dart';
import 'package:kids_app_grad/screens/welcome_screen/welcome_screen.dart';
import '../screens/Authentication/login_screen/login_screen.dart';
import '../screens/splash_screen/splash_screen.dart';

class RoutesManager{
static const kLoginForParent = "/loginForParent";
static const kSignUpForParent = "/SignUpForParent";
static const kSignUpForChild = "/SignUpForChild";
static const kOnBoarding = "/onBoarding";
static const kWelcomeScreen = "/welcomeScreen";
static const kForgetPass = "/forgetPass";
static const kForgetPassVarification = "/forgetPassVarification";
static const kSetNewPass = "/setNewPassword";
static const kProfileChild = "/childProfile";
static const kDashboardScreen = "/dashboardScreen";
static const kGamesScreen = "/gamesScreen";
static final router = GoRouter(routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    path: kLoginForParent,

    builder: (context, state) => const LoginScreen(),
  ),
  GoRoute(
    path: kSignUpForParent,

    builder: (context, state) =>  SignUpForParent(),
  ),
  GoRoute(
    path: kSignUpForChild,
    builder: (context, state) => const SignUpForChild(parentId: '',),
  ),
  GoRoute(
    path: kWelcomeScreen,
    builder: (context, state) => const WelcomeScreen(),
  ),
  GoRoute(
    path: kForgetPass,
    builder: (context, state) => const ForgetPassword(),
  ),
  GoRoute(path: kSetNewPass,
  builder: (context, state) => const SetNewPassword(),),

  GoRoute(
    path: kForgetPassVarification,
    builder: (context, state) => const ForgetPasswordVarification(),
  ),
  GoRoute(
    path: kOnBoarding,
    builder: (context, state) => const Onboarding(),
  ),
  GoRoute(
    path: kDashboardScreen,
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    path: kGamesScreen,
    builder: (context, state) => const GamesScreen(),
  ),



]);

}