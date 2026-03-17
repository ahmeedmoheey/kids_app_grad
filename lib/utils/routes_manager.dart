
import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_child/sign_up_for_child/sign_up_for_child.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_parent/sign_up_for_parent/sign_up_for_parent.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password_varification/forget_password_varification.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/set_new_password/set_new_password.dart';
import 'package:kids_app_grad/screens/child_profile/child_profile.dart';
import 'package:kids_app_grad/screens/dashboard_screen/dashboard_screen.dart';
import 'package:kids_app_grad/screens/games_screen/mataha_games.dart';
import 'package:kids_app_grad/screens/games_screen/shape_game_screen.dart';
import 'package:kids_app_grad/screens/home_screen/home_screen.dart';
import 'package:kids_app_grad/screens/main_screen/main_screen.dart';
import 'package:kids_app_grad/screens/onBoarding/onboarding.dart';
import 'package:kids_app_grad/screens/welcome_screen/welcome_screen.dart';
import '../screens/Authentication/login_screen/login_screen.dart';
import '../screens/games_screen/shape_matching_game.dart';
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
static const kMainScreen = "/mainScreen";
static const kHomeScreen = "/homeScreen";
static const kChildProfile = "/childProfile";
static const kMatahaGames = "/matahaGames";
static const kShapeMatcher = "/shapeMatcher";
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
    builder: (context, state) => const ShapeGameScreen (),
  ),
  GoRoute(
    path: kHomeScreen,
    builder: (context, state) => const HomeScreen(),
  ),
  GoRoute(
    path: kMainScreen,
    builder: (context, state) => const MainScreen(),
  ),
  GoRoute(
    path: kChildProfile,
    builder: (context, state) => const ChildProfile(),
  ),
  GoRoute(
    path: kMatahaGames,
    builder: (context, state) => const MatahaGames(),
  ),
  GoRoute(
    path: kShapeMatcher,


    builder: (context, state) =>  ShapeMatchingGame(),
  ),



]);

}