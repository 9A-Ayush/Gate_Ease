import 'package:flutter/material.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/login_phone_screen.dart';
import 'screens/auth/admin_invite_screen.dart';
import 'screens/auth/profile_completion_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/resident/resident_home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'screens/guard/guard_home_screen.dart';
import 'screens/vendor/vendor_home_screen.dart';
import 'screens/resident/add_home_screen.dart';
import 'screens/resident/awaiting_approval_screen.dart';
import 'screens/admin/admin_pending_requests_screen.dart';
import 'screens/resident/visitor_management_screen.dart';
import 'screens/resident/complaints_screen.dart';
import 'screens/resident/amenities_screen.dart';
import 'screens/resident/payments_screen.dart';
import 'screens/resident/chat_screen.dart';
import 'screens/resident/announcements_screen.dart';
import 'screens/admin/admin_user_management_screen.dart';
import 'screens/admin/admin_announcements_screen.dart';
import 'screens/admin/admin_complaints_screen.dart';
import 'screens/admin/admin_visitor_management_screen.dart';
import 'screens/guard/guard_visitor_log_screen.dart';
import 'screens/guard/guard_preapproved_visitors_screen.dart';
import 'screens/guard/guard_all_visitors_screen.dart';
import 'screens/debug/debug_data_screen.dart';
import 'screens/debug/create_test_visitor.dart';
import 'screens/common/profile_edit_screen.dart';

import 'screens/vendor/vendor_services_screen.dart';
import 'screens/vendor/vendor_add_service_screen.dart';
import 'screens/vendor/vendor_ads_screen.dart';
import 'screens/vendor/vendor_create_ad_screen.dart';
import 'screens/vendor/vendor_chat_screen.dart';
import 'screens/admin/admin_vendor_management_screen.dart';
import 'screens/admin/admin_bill_management_screen.dart';
import 'screens/admin/admin_notifications_screen.dart';
import 'screens/admin/admin_analytics_screen.dart';
import 'screens/common/contact_selection_screen.dart';
import 'screens/common/chat_list_screen.dart';
import 'screens/common/simple_chat_screen.dart';
import 'screens/debug/test_chat_screen.dart';
import 'screens/social/social_feed_screen.dart';
import 'screens/social/create_post_screen.dart';
import 'screens/social/post_detail_screen.dart';
import 'screens/social/user_profile_screen.dart';
import 'screens/social/user_discovery_screen.dart';
import 'screens/resident/shopping/products_screen.dart';
import 'screens/resident/shopping/product_detail_screen.dart';
import 'screens/resident/shopping/cart_screen.dart';
import 'screens/resident/shopping/checkout_screen.dart';
import 'screens/vendor/vendor_products_screen.dart';
import 'screens/vendor/vendor_add_product_screen.dart';
import 'screens/vendor/vendor_edit_product_screen.dart';
import 'screens/vendor/vendor_orders_screen.dart';
import 'models/product.dart';
import 'screens/debug/debug_comments_screen.dart';
import 'models/vendor_service.dart';
import 'models/product.dart';
import 'models/cart.dart';

class RouteHelper {
  static Map<String, WidgetBuilder> getRoutes(BuildContext context) => {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/register': (context) => const RegisterScreen(),
    '/login_phone': (context) => const LoginPhoneScreen(),
    '/admin_invite': (context) => const AdminInviteScreen(),
    '/profile_completion':
        (context) => const ProfileCompletionScreen(role: 'resident'),
    '/forgot_password': (context) => const ForgotPasswordScreen(),
    '/resident_home': (context) => const ResidentHomeScreen(),
    '/admin_home': (context) => const AdminHomeScreen(),
    '/guard_home': (context) => const GuardHomeScreen(),
    '/vendor_home': (context) => const VendorHomeScreen(),
    '/add_home': (context) => const AddHomeScreen(),
    '/awaiting_approval': (context) => const AwaitingApprovalScreen(),
    '/admin_pending_requests': (context) => const AdminPendingRequestsScreen(),
    '/visitor_management': (context) => const VisitorManagementScreen(),
    '/complaints': (context) => const ComplaintsScreen(),
    '/amenities': (context) => const AmenitiesScreen(),
    '/payments': (context) => const PaymentsScreen(),
    '/chat': (context) => const ChatScreen(),
    '/announcements': (context) => const AnnouncementsScreen(),
    '/admin_user_management': (context) => const AdminUserManagementScreen(),
    '/admin_announcements': (context) => const AdminAnnouncementsScreen(),
    '/admin_complaints': (context) => const AdminComplaintsScreen(),
    '/admin_visitor_management':
        (context) => const AdminVisitorManagementScreen(),
    '/guard_visitor_log': (context) => const GuardVisitorLogScreen(),
    '/guard_preapproved_visitors':
        (context) => const GuardPreapprovedVisitorsScreen(),
    '/guard_chat': (context) => const ChatScreen(),
    '/guard_all_visitors': (context) => const GuardAllVisitorsScreen(),
    '/debug': (context) => const DebugDataScreen(),
    '/create_test_visitor': (context) => const CreateTestVisitorScreen(),
    '/profile_edit': (context) => const ProfileEditScreen(),
    '/vendor_services': (context) => const VendorServicesScreen(),
    '/vendor_add_service': (context) => const VendorAddServiceScreen(),
    '/vendor_edit_service': (context) {
      final service =
          ModalRoute.of(context)?.settings.arguments as VendorService?;
      return VendorAddServiceScreen(service: service);
    },
    '/vendor_ads': (context) => const VendorAdsScreen(),
    '/vendor_create_ad': (context) => const VendorCreateAdScreen(),
    '/vendor_chat': (context) => const VendorChatScreen(),
    '/admin_vendors': (context) => const AdminVendorManagementScreen(),
    '/admin_bills': (context) => const AdminBillManagementScreen(),
    '/admin_notifications': (context) => const AdminNotificationsScreen(),
    '/admin_analytics': (context) => const AdminAnalyticsScreen(),
    '/contact_selection': (context) => const ContactSelectionScreen(),
    '/chat_list': (context) => const ChatListScreen(),
    '/simple_chat': (context) => const SimpleChatScreen(),
    '/test_chat': (context) => const TestChatScreen(),
    '/social_feed': (context) => const SocialFeedScreen(),
    '/create_post': (context) => const CreatePostScreen(),
    '/user_discovery': (context) => const UserDiscoveryScreen(),
    '/products': (context) => const ProductsScreen(),
    '/cart': (context) => const CartScreen(),
    '/checkout': (context) => const CheckoutScreen(),
    '/vendor_products': (context) => const VendorProductsScreen(),
    '/vendor_add_product': (context) => const VendorAddProductScreen(),
    '/vendor_orders': (context) => const VendorOrdersScreen(),
  };

  // Handle dynamic routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/post_detail':
        final postId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => PostDetailScreen(postId: postId),
        );
      case '/user_profile':
        final userId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => UserProfileScreen(userId: userId),
        );
      case '/debug_comments':
        final postId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (context) => DebugCommentsScreen(postId: postId),
        );
      case '/product_detail':
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: product),
        );
      case '/vendor_edit_product':
        final product = settings.arguments as Product;
        return MaterialPageRoute(
          builder: (context) => VendorEditProductScreen(product: product),
        );

      default:
        return null;
    }
  }

  // Method to navigate to login and clear navigation stack
  static void navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (route) => false, // Remove all previous routes
    );
  }

  static void routeUser(
    BuildContext context,
    String role,
    bool profileComplete, {
    String? status,
  }) {
    // If no role is provided, user is not properly authenticated - go to login
    if (role.isEmpty) {
      navigateToLogin(context);
      return;
    }

    // Handle resident-specific routing
    if (role == 'resident') {
      if (!profileComplete) {
        // Resident needs to add home details
        Navigator.pushReplacementNamed(context, '/add_home');
        return;
      } else if (status == 'pending') {
        // Resident is waiting for admin approval
        Navigator.pushReplacementNamed(context, '/awaiting_approval');
        return;
      } else if (status == 'approved') {
        // Resident is approved - go to home
        Navigator.pushReplacementNamed(context, '/resident_home');
        return;
      } else {
        // Resident status is not set properly - go to awaiting approval
        Navigator.pushReplacementNamed(context, '/awaiting_approval');
        return;
      }
    }

    // Handle other roles (admin, guard, vendor)
    if (!profileComplete) {
      // Profile not complete - go to profile completion screen
      Navigator.pushReplacementNamed(
        context,
        '/profile_completion',
        arguments: {'role': role},
      );
      return;
    }

    // Profile is complete - route to appropriate home screen
    switch (role) {
      case 'admin':
        Navigator.pushReplacementNamed(context, '/admin_home');
        break;
      case 'guard':
        Navigator.pushReplacementNamed(context, '/guard_home');
        break;
      case 'vendor':
        Navigator.pushReplacementNamed(context, '/vendor_home');
        break;
      default:
        // Unknown role - go to login
        navigateToLogin(context);
    }
  }
}
