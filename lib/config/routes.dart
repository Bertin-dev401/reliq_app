import 'package:get/get.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/welcome_screen.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/main/main_navigation_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/community/community_screen.dart';
import '../screens/community/community_detail_screen.dart';
import '../screens/community/create_post_screen.dart';
import '../screens/bible/bible_screen.dart';
import '../screens/bible/bible_reader_screen.dart';
import '../screens/bible/daily_verse_screen.dart';
import '../screens/events/events_screen.dart';
import '../screens/events/event_detail_screen.dart';
import '../screens/events/create_event_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/settings_screen.dart';
import '../screens/marketplace/marketplace_screen.dart';
import '../screens/marketplace/product_detail_screen.dart';
import '../screens/marketplace/seller_shop_screen.dart';
import '../screens/streaks/streaks_screen.dart';
import '../screens/quiz/quiz_screen.dart';
import '../screens/quiz/quiz_detail_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/donations/donations_screen.dart';
import '../screens/live/live_events_screen.dart';

class AppRoutes {
  static final routes = [
    // Auth Routes
    GetPage(
      name: '/splash',
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/welcome',
      page: () => const WelcomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: '/signin',
      page: () => const SignInScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/signup',
      page: () => const SignUpScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/forgot-password',
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/verification',
      page: () => const VerificationScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Main Navigation
    GetPage(
      name: '/main',
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
    ),
    
    // Home
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
    ),
    
    // Community
    GetPage(
      name: '/community',
      page: () => const CommunityScreen(),
    ),
    GetPage(
      name: '/community-detail',
      page: () => const CommunityDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/create-post',
      page: () => const CreatePostScreen(),
      transition: Transition.downToUp,
    ),
    
    // Bible
    GetPage(
      name: '/bible',
      page: () => const BibleScreen(),
    ),
    GetPage(
      name: '/bible-reader',
      page: () => const BibleReaderScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/daily-verse',
      page: () => const DailyVerseScreen(),
      transition: Transition.fadeIn,
    ),
    
    // Events
    GetPage(
      name: '/events',
      page: () => const EventsScreen(),
    ),
    GetPage(
      name: '/event-detail',
      page: () => const EventDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/create-event',
      page: () => const CreateEventScreen(),
      transition: Transition.downToUp,
    ),
    
    // Profile
    GetPage(
      name: '/profile',
      page: () => const ProfileScreen(),
    ),
    GetPage(
      name: '/edit-profile',
      page: () => const EditProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Marketplace
    GetPage(
      name: '/marketplace',
      page: () => const MarketplaceScreen(),
    ),
    GetPage(
      name: '/product-detail',
      page: () => const ProductDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/seller-shop',
      page: () => const SellerShopScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Streaks & Routines
    GetPage(
      name: '/streaks',
      page: () => const StreaksScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Quiz
    GetPage(
      name: '/quiz',
      page: () => const QuizScreen(),
    ),
    GetPage(
      name: '/quiz-detail',
      page: () => const QuizDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Chat
    GetPage(
      name: '/chat-list',
      page: () => const ChatListScreen(),
    ),
    GetPage(
      name: '/chat-detail',
      page: () => const ChatDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Donations
    GetPage(
      name: '/donations',
      page: () => const DonationsScreen(),
      transition: Transition.rightToLeft,
    ),
    
    // Live Events
    GetPage(
      name: '/live-events',
      page: () => const LiveEventsScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
