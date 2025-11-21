// import 'dart:math' show sin;

// import 'package:flutter/material.dart';
// import 'package:kid_flix_app/core/themes/font_weight_helper.dart';

// import '../core.dart';

// class ModernLoadingIndicator extends StatefulWidget {
//   final String? message;
//   final List<Color>? gradientColors;
//   final double? size;
//   final LoadingType type;
//   final double? containerSize;
//   final bool showPulse;
//   final Duration? animationDuration;

//   const ModernLoadingIndicator({
//     super.key,
//     this.message,
//     this.gradientColors,
//     this.size = 50,
//     this.type = LoadingType.circular,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   });

//   // Pre-built loading states for common scenarios
//   const ModernLoadingIndicator.fetching({
//     super.key,
//     this.message = 'Fetching data...',
//     this.gradientColors,
//     this.size = 50,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   }) : type = LoadingType.circular;

//   const ModernLoadingIndicator.uploading({
//     super.key,
//     this.message = 'Uploading...',
//     this.gradientColors,
//     this.size = 50,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   }) : type = LoadingType.progress;

//   const ModernLoadingIndicator.processing({
//     super.key,
//     this.message = 'Processing...',
//     this.gradientColors,
//     this.size = 50,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   }) : type = LoadingType.dots;

//   const ModernLoadingIndicator.saving({
//     super.key,
//     this.message = 'Saving...',
//     this.gradientColors,
//     this.size = 50,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   }) : type = LoadingType.pulse;

//   const ModernLoadingIndicator.connecting({
//     super.key,
//     this.message = 'Connecting...',
//     this.gradientColors,
//     this.size = 50,
//     this.containerSize = 120,
//     this.showPulse = true,
//     this.animationDuration,
//   }) : type = LoadingType.wave;

//   @override
//   State<ModernLoadingIndicator> createState() => _ModernLoadingIndicatorState();
// }

// enum LoadingType { circular, dots, pulse, wave, progress }

// class _ModernLoadingIndicatorState extends State<ModernLoadingIndicator>
//     with TickerProviderStateMixin {
//   late AnimationController _controller;
//   late AnimationController _pulseController;
//   late Animation<double> _animation;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       duration: widget.animationDuration ?? const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();

//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat();

//     _animation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _pulseController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final defaultGradient =
//         widget.gradientColors ?? [AppColors.primary, AppColors.primaryPurple];

//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Animated Container with Loading Indicator
//             AnimatedBuilder(
//               animation: widget.showPulse ? _pulseAnimation : _animation,
//               builder: (context, child) {
//                 return Transform.scale(
//                   scale: widget.showPulse ? _pulseAnimation.value : 1.0,
//                   child: Container(
//                     width: widget.containerSize,
//                     height: widget.containerSize,
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: defaultGradient,
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(
//                         widget.containerSize! / 2,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: defaultGradient.first.withValues(alpha: 0.3),
//                           blurRadius: 20,
//                           offset: const Offset(0, 10),
//                         ),
//                       ],
//                     ),
//                     child: Center(
//                       child: _buildLoadingIndicator(defaultGradient),
//                     ),
//                   ),
//                 );
//               },
//             ),

//             if (widget.message != null) ...[
//               const SizedBox(height: 32),
//               AnimatedBuilder(
//                 animation: _animation,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: 0.7 + (_animation.value * 0.3),
//                     child: Text(
//                       widget.message!,
//                       textAlign: TextAlign.center,
//                       style: AppTextStyling.fontFamilySTCForward.copyWith(
//                         fontSize: 16,
//                         color: context.isDarkMode
//                             ? AppColors.white
//                             : AppColors.textDark,
//                         fontWeight: FontWeightHelper.medium,
//                         height: 1.4,
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLoadingIndicator(List<Color> colors) {
//     switch (widget.type) {
//       case LoadingType.circular:
//         return _buildCircularIndicator();
//       case LoadingType.dots:
//         return _buildDotsIndicator(colors);
//       case LoadingType.pulse:
//         return _buildPulseIndicator();
//       case LoadingType.wave:
//         return _buildWaveIndicator(colors);
//       case LoadingType.progress:
//         return _buildProgressIndicator();
//     }
//   }

//   Widget _buildCircularIndicator() {
//     return SizedBox(
//       width: widget.size,
//       height: widget.size,
//       child: CircularProgressIndicator(
//         strokeWidth: 3,
//         valueColor: const AlwaysStoppedAnimation(Colors.white),
//         backgroundColor: Colors.white.withValues(alpha: 0.3),
//       ),
//     );
//   }

//   Widget _buildDotsIndicator(List<Color> colors) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(3, (index) {
//             final delay = index * 0.2;
//             final animationValue = (_animation.value + delay) % 1.0;
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               width: 8,
//               height: 8,
//               decoration: BoxDecoration(
//                 color: Colors.white.withValues(
//                   alpha: 0.3 + (animationValue * 0.7),
//                 ),
//                 borderRadius: BorderRadius.circular(4),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }

//   Widget _buildPulseIndicator() {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: 20 + (_animation.value * 10),
//           height: 20 + (_animation.value * 10),
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 1 - _animation.value),
//             borderRadius: BorderRadius.circular(15),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildWaveIndicator(List<Color> colors) {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Row(
//           mainAxisSize: MainAxisSize.min,
//           children: List.generate(4, (index) {
//             final waveOffset = (index * 0.25) % 1.0;
//             final waveValue =
//                 (sin((_animation.value + waveOffset) * 2 * 3.14159) + 1) / 2;
//             return Container(
//               margin: const EdgeInsets.symmetric(horizontal: 1),
//               width: 3,
//               height: 15 + (waveValue * 15),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }

//   Widget _buildProgressIndicator() {
//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: widget.size,
//           height: 6,
//           decoration: BoxDecoration(
//             color: Colors.white.withValues(alpha: 0.3),
//             borderRadius: BorderRadius.circular(3),
//           ),
//           child: FractionallySizedBox(
//             alignment: Alignment.centerLeft,
//             widthFactor: _animation.value,
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(3),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// // Loading Overlay Widget for full screen loading
// class ModernLoadingOverlay extends StatelessWidget {
//   final Widget child;
//   final bool isLoading;
//   final String? loadingMessage;
//   final Color? overlayColor;
//   final LoadingType loadingType;
//   final List<Color>? gradientColors;
//   final bool blurBackground;

//   const ModernLoadingOverlay({
//     super.key,
//     required this.child,
//     required this.isLoading,
//     this.loadingMessage,
//     this.overlayColor,
//     this.loadingType = LoadingType.circular,
//     this.gradientColors,
//     this.blurBackground = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         child,
//         if (isLoading)
//           Container(
//             color: overlayColor ?? Colors.black.withValues(alpha: 0.5),
//             child: ModernLoadingIndicator(
//               message: loadingMessage ?? 'Loading...',
//               type: loadingType,
//               gradientColors: gradientColors,
//             ),
//           ),
//       ],
//     );
//   }
// }

// // Button Loading State
// class ModernLoadingButton extends StatelessWidget {
//   final String text;
//   final String? loadingText;
//   final VoidCallback? onPressed;
//   final bool isLoading;
//   final List<Color>? gradientColors;
//   final double? width;
//   final double? height;
//   final IconData? icon;

//   const ModernLoadingButton({
//     super.key,
//     required this.text,
//     this.loadingText,
//     this.onPressed,
//     this.isLoading = false,
//     this.gradientColors,
//     this.width,
//     this.height = 50,
//     this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final defaultGradient =
//         gradientColors ?? [AppColors.primary, AppColors.primaryPurple];

//     return GestureDetector(
//       onTap: isLoading ? null : onPressed,
//       child: Container(
//         width: width,
//         height: height,
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: isLoading
//                 ? [Colors.grey[400]!, Colors.grey[500]!]
//                 : defaultGradient,
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(25),
//           boxShadow: [
//             BoxShadow(
//               color: defaultGradient.first.withValues(alpha: 0.3),
//               blurRadius: 10,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (isLoading) ...[
//               const SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation(Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 loadingText ?? 'Loading...',
//                 style: AppTextStyling.fontFamilySTCForward.copyWith(
//                   color: AppColors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeightHelper.semiBold,
//                 ),
//               ),
//             ] else ...[
//               if (icon != null) ...[
//                 Icon(icon, color: Colors.white, size: 18),
//                 const SizedBox(width: 8),
//               ],
//               Text(
//                 text,
//                 style: AppTextStyling.fontFamilySTCForward.copyWith(
//                   color: AppColors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeightHelper.semiBold,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Skeleton Loading Widget
// class ModernSkeleton extends StatefulWidget {
//   final double? width;
//   final double? height;
//   final BorderRadius? borderRadius;
//   final bool isLoading;
//   final Widget? child;

//   const ModernSkeleton({
//     super.key,
//     this.width,
//     this.height,
//     this.borderRadius,
//     this.isLoading = true,
//     this.child,
//   });

//   @override
//   State<ModernSkeleton> createState() => _ModernSkeletonState();
// }

// class _ModernSkeletonState extends State<ModernSkeleton>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat();
//     _animation = Tween<double>(
//       begin: -1.0,
//       end: 2.0,
//     ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isLoading && widget.child != null) {
//       return widget.child!;
//     }

//     return AnimatedBuilder(
//       animation: _animation,
//       builder: (context, child) {
//         return Container(
//           width: widget.width,
//           height: widget.height,
//           decoration: BoxDecoration(
//             borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
//             gradient: LinearGradient(
//               begin: Alignment.centerLeft,
//               end: Alignment.centerRight,
//               colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
//               stops: [
//                 (_animation.value - 0.5).clamp(0.0, 1.0),
//                 _animation.value.clamp(0.0, 1.0),
//                 (_animation.value + 0.5).clamp(0.0, 1.0),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// /*
// Usage Examples:

// // Basic Loading
// ModernLoadingIndicator(
//   message: 'Loading your data...',
//   type: LoadingType.circular,
// )

// // Predefined Loading States
// ModernLoadingIndicator.fetching()
// ModernLoadingIndicator.uploading()
// ModernLoadingIndicator.processing()

// // Loading Overlay
// ModernLoadingOverlay(
//   isLoading: _isLoading,
//   loadingMessage: 'Please wait...',
//   child: YourContentWidget(),
// )

// // Loading Button
// ModernLoadingButton(
//   text: 'Submit',
//   loadingText: 'Submitting...',
//   isLoading: _isSubmitting,
//   onPressed: () => _submit(),
// )

// // Skeleton Loading
// ModernSkeleton(
//   width: 200,
//   height: 20,
//   isLoading: _isLoading,
//   child: Text('Your content here'),
// )
// */
