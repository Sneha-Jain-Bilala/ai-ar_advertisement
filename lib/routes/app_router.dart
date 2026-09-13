import 'package:go_router/go_router.dart';
import '../ui/screens/admin/admin_dashboard_screen.dart';
import '../ui/screens/advertiser/advertiser_dashboard_screen.dart';
import '../ui/screens/advertiser/campaign_detail_screen.dart';
import '../ui/screens/advertiser/create_campaign_screen.dart';
import '../ui/screens/advertiser/manage_products_screen.dart';
import '../ui/screens/advertiser/qr_export_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/consumer/ar_viewer_screen.dart';
import '../ui/screens/consumer/consumer_main_nav.dart';
import '../ui/screens/consumer/product_detail_screen.dart';
import '../ui/screens/consumer/qr_scanner_screen.dart';
import '../ui/screens/splash/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Consumer Main App (with bottom nav)
      GoRoute(
        path: '/home',
        builder: (context, state) => const ConsumerMainNav(initialIndex: 0),
      ),
      GoRoute(
        path: '/explore',
        builder: (context, state) => const ConsumerMainNav(initialIndex: 1),
      ),
      GoRoute(
        path: '/saved',
        builder: (context, state) => const ConsumerMainNav(initialIndex: 2),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ConsumerMainNav(initialIndex: 3),
      ),

      // QR Scanner
      GoRoute(
        path: '/scanner',
        builder: (context, state) => const QrScannerScreen(),
      ),

      // AR Viewer
      GoRoute(
        path: '/ar-view/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId'] ?? '';
          return ArViewerScreen(campaignId: campaignId);
        },
      ),

      // Product Detail & AI Assistant
      GoRoute(
        path: '/product/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId'] ?? '';
          return ProductDetailScreen(campaignId: campaignId);
        },
      ),

      // Advertiser Hub
      GoRoute(
        path: '/advertiser',
        builder: (context, state) => const AdvertiserDashboardScreen(),
      ),
      GoRoute(
        path: '/advertiser/create-campaign',
        builder: (context, state) => const CreateCampaignScreen(),
      ),
      GoRoute(
        path: '/advertiser/campaign-detail/:campaignId',
        builder: (context, state) {
          final campaignId = state.pathParameters['campaignId'] ?? '';
          return CampaignDetailScreen(campaignId: campaignId);
        },
      ),
      GoRoute(
        path: '/advertiser/products',
        builder: (context, state) => const ManageProductsScreen(),
      ),
      GoRoute(
        path: '/advertiser/qr-export',
        builder: (context, state) => const QrExportScreen(),
      ),

      // Admin Console
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
    ],
  );
}
