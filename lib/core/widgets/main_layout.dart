// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:kid_flix_app/core/core.dart';
// import 'package:kid_flix_app/core/utils/extensions.dart';
// import 'package:kid_flix_app/core/utils/time_restriction_helper.dart';
// import 'package:kid_flix_app/features/auth/presentation/screen/time_restriction_screen.dart';
// import 'package:kid_flix_app/features/categories/presentation/screen/all_categories_grid_screen.dart';
// import 'package:kid_flix_app/features/categories/presentation/screen/categories_screen.dart';
// import 'package:kid_flix_app/features/profile/presentation/screen/profile_screen.dart';

// import '../../features/profile/presentation/cubit/profile/profile_cubit.dart';
// import '../../features/profile/presentation/cubit/logout/logout_cubit.dart';
// import '../../features/profile/presentation/cubit/policy/policy_cubit.dart';

// class MainLayout extends StatefulWidget {
//   final int initialIndex;
//   const MainLayout({super.key, this.initialIndex = 0});

//   @override
//   State<MainLayout> createState() => _MainLayoutState();
// }

// class _MainLayoutState extends State<MainLayout> {
//   late int _currentIndex;
//   late final List<Widget> _screens;
//   bool _accessGranted = false;
//   bool _isBottomNavBarVisible = true;
//   double _lastScrollOffset = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _currentIndex = widget.initialIndex;
//     // Load profile on init to check time restrictions
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         final profileCubit = context.read<ProfileCubit>();
//         profileCubit.getProfile();
//       }
//     });
//     _screens = [
//       const CategoriesScreen(), // Home
//       const AllCategoriesGridScreen(), // Categories
//       MultiBlocProvider(
//         providers: [
//           BlocProvider(create: (_) => sl<ProfileCubit>()..getProfile()),
//           BlocProvider(create: (_) => sl<LogoutCubit>()),
//           BlocProvider(create: (_) => sl<PolicyCubit>()),
//         ],
//         child: const ProfileScreen(),
//       ), // Settings
//     ];
//   }

//   void _onNavTap(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//   }

//   void _grantAccess() {
//     setState(() {
//       _accessGranted = true;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Try to get ProfileCubit if available, otherwise show normal layout
//     ProfileCubit? profileCubit;
//     // try {
//     profileCubit = context.read<ProfileCubit>();
//     // } catch (e) {
//     //   // ProfileCubit not available, show normal layout
//     //   return Scaffold(
//     //     extendBody: true,
//     //     backgroundColor: AppColors.pinkBackground,
//     //     body: IndexedStack(index: _currentIndex, children: _screens),
//     //     bottomNavigationBar: SafeArea(
//     //       top: false,
//     //       child: BottomNavBar(currentIndex: _currentIndex, onTap: _onNavTap),
//     //     ),
//     //   );
//     // }

//     return BlocBuilder<ProfileCubit, ProfileState>(
//       bloc: profileCubit,
//       builder: (context, profileState) {
//         // Check time restrictions if profile is loaded
//         if (profileState is ProfileLoaded && !_accessGranted) {
//           final profileData = profileState.response.data?.isNotEmpty == true
//               ? profileState.response.data!.first
//               : null;
//           final timeActiveList = profileData?.userTimeActive;

//           if (timeActiveList != null && timeActiveList.isNotEmpty) {
//             final isAllowed = TimeRestrictionHelper.isTimeAllowed(
//               timeActiveList,
//             );

//             if (!isAllowed) {
//               return TimeRestrictionScreen(
//                 timeActiveList: timeActiveList,
//                 onAccessGranted: _grantAccess,
//               );
//             }
//           }
//         }

//         return Builder(
//           builder: (context) {
//             // استخدام نفس أول لون من gradient حسب gender theme
//             final backgroundColor = context.isGirlTheme
//                 ? const Color(0xFFFFF5F8) // وردي فاتح للبنت
//                 : const Color(0xFFE3F2FD); // أزرق فاتح للولد

//             return Scaffold(
//               extendBody: true,
//               backgroundColor:
//                   backgroundColor, // إضافة لون خلفية لمنع اللون الأسود
//               body: NotificationListener<ScrollUpdateNotification>(
//                 onNotification: (notification) {
//                   // تتبع اتجاه الـ scroll
//                   final currentOffset = notification.metrics.pixels;
//                   final scrollDelta = currentOffset - _lastScrollOffset;

//                   // إذا كان المستخدم يسحب لأعلى (scrollDelta > 0) وأكثر من 10 pixels
//                   if (scrollDelta > 10 && _isBottomNavBarVisible) {
//                     setState(() {
//                       _isBottomNavBarVisible = false;
//                     });
//                   }
//                   // إذا كان المستخدم يسحب لأسفل (scrollDelta < 0) وأكثر من 10 pixels
//                   else if (scrollDelta < -10 && !_isBottomNavBarVisible) {
//                     setState(() {
//                       _isBottomNavBarVisible = true;
//                     });
//                   }

//                   _lastScrollOffset = currentOffset;
//                   return false; // للسماح للـ notification بالانتشار
//                 },
//                 child: IndexedStack(index: _currentIndex, children: _screens),
//               ),
//               floatingActionButtonLocation:
//                   FloatingActionButtonLocation.centerDocked,
//               floatingActionButton: AnimatedSlide(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOut,
//                 offset: _isBottomNavBarVisible
//                     ? Offset.zero
//                     : const Offset(0, 2), // إخفاء للأسفل
//                 child: IgnorePointer(
//                   ignoring: !_isBottomNavBarVisible,
//                   child: AnimatedOpacity(
//                     duration: const Duration(milliseconds: 300),
//                     opacity: _isBottomNavBarVisible ? 1.0 : 0.0,
//                     child: BottomNavBar(
//                       currentIndex: _currentIndex,
//                       onTap: _onNavTap,
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
