import 'package:go_router/go_router.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_child/sign_up_for_child/sign_up_for_child.dart';
import 'package:kids_app_grad/screens/Authentication/account_for_parent/sign_up_for_parent/sign_up_for_parent.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/forget_password_varification/forget_password_varification.dart';
import 'package:kids_app_grad/screens/Authentication/forget_password/set_new_password/set_new_password.dart';
import 'package:kids_app_grad/screens/child_profile/child_profile.dart';
import 'package:kids_app_grad/screens/games_screen/find_star.dart';
import 'package:kids_app_grad/screens/games_screen/match_shapes.dart';
import 'package:kids_app_grad/screens/games_screen/shape_game_screen.dart';
import 'package:kids_app_grad/screens/home_page_parent/chat_ai/chat_ai.dart';
import 'package:kids_app_grad/screens/home_page_parent/home_page_parent.dart';
import 'package:kids_app_grad/screens/home_screen/home_screen.dart';
import 'package:kids_app_grad/screens/onBoarding/onboarding.dart';
import 'package:kids_app_grad/screens/welcome_screen/welcome_screen.dart';
import 'package:kids_app_grad/screens/home_page_parent/dashboard_screen/child_details_screen.dart';
import '../screens/Authentication/login_screen/login_screen.dart';
import '../screens/games_screen/shape_matching_game.dart';
import '../screens/home_page_parent/dashboard_screen/dashboard_screen.dart';
import '../screens/splash_screen/splash_screen.dart';

class RoutesManager {
  static const kLoginForParent = "/loginForParent";
  static const kSignUpForParent = "/SignUpForParent";
  static const kSignUpForChild = "/SignUpForChild";
  static const kOnBoarding = "/onBoarding";
  static const kWelcomeScreen = "/welcomeScreen";
  static const kForgetPass = "/forgetPass";
  static const kForgetPassVarification = "/forgetPassVarification";
  static const kSetNewPass = "/setNewPassword";
  static const kDashboardScreen = "/dashboardScreen";
  static const kChildDetails = "/childDetails";
  static const kGamesScreen = "/gamesScreen";
  static const kHomeScreen = "/homeScreen";
  static const kChildProfile = "/childProfile";
  static const kShapeMatcher = "/shapeMatcher";
  static const kMatchAnimal = "/matchAnimal";
  static const kFindStar = "/findStar";
  static const kHomePageParent = "/homePageParent";
  static const kChatAi = "/chatAi";

  static final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: kLoginForParent, builder: (context, state) => const LoginScreen()),
    GoRoute(path: kSignUpForParent, builder: (context, state) => const SignUpForParent()),
    GoRoute(path: kSignUpForChild, builder: (context, state) => const SignUpForChild(parentId: '')),
    GoRoute(path: kWelcomeScreen, builder: (context, state) => const WelcomeScreen()),
    GoRoute(path: kForgetPass, builder: (context, state) => const ForgetPassword()),
    GoRoute(path: kSetNewPass, builder: (context, state) => SetNewPassword(resetToken: state.extra as String? ?? "")),
    GoRoute(path: kForgetPassVarification, builder: (context, state) => ForgetPasswordVarification(email: state.extra as String? ?? "")),
    GoRoute(path: kOnBoarding, builder: (context, state) => const Onboarding()),
    GoRoute(path: kDashboardScreen, builder: (context, state) => const DashboardScreen()),
    GoRoute(path: kChildDetails, builder: (context, state) => ChildDetailsScreen(childId: state.extra as int)),
    GoRoute(path: kGamesScreen, builder: (context, state) => const ShapeGameScreen()),
    GoRoute(path: kHomeScreen, builder: (context, state) => const HomeScreen()),
    GoRoute(path: kChildProfile, builder: (context, state) => const ChildProfile()),
    GoRoute(path: kShapeMatcher, builder: (context, state) => ShapeMatchingGame()),
    GoRoute(path: kMatchAnimal, builder: (context, state) => MatchShapes()),
    GoRoute(path: kFindStar, builder: (context, state) => FindStar()),
    GoRoute(path: kHomePageParent, builder: (context, state) => HomePageParent()),
    GoRoute(path: kChatAi, builder: (context, state) => ChatAi()),
  ]);
}
