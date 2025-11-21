import 'package:flutter/material.dart';
import 'package:health_compass/core/themes/app_gradient.dart';
import 'package:health_compass/core/widgets/status_app_bar.dart';

class CustomScaffold extends StatelessWidget {
  /// Custom Scaffold with StatusBarGradient integrated
  /// يمكن استخدامه في جميع شاشات التطبيق
  const CustomScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.backgroundColor = Colors.transparent,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.resizeToAvoidBottomInset,
    this.showStatusBarGradient = true,
    this.gradient,
  });

  /// The primary content of the scaffold
  final Widget body;

  /// Optional app bar
  final PreferredSizeWidget? appBar;

  /// Background color of the scaffold (default: transparent)
  final Color backgroundColor;

  /// Optional floating action button
  final Widget? floatingActionButton;

  /// Location of the floating action button
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Optional drawer
  final Widget? drawer;

  /// Optional end drawer
  final Widget? endDrawer;

  /// Optional bottom navigation bar
  final Widget? bottomNavigationBar;

  /// Optional bottom sheet
  final Widget? bottomSheet;

  /// Whether to extend body behind bottom navigation bar
  final bool extendBody;

  /// Whether to extend body behind app bar
  final bool extendBodyBehindAppBar;

  /// Whether the body should resize when keyboard appears
  final bool? resizeToAvoidBottomInset;

  /// Whether to show the StatusBarGradient (default: true)
  final bool showStatusBarGradient;

  /// Optional gradient
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: showStatusBarGradient
          ? Stack(
              children: [
                const StatusBarGradient(),
                SafeArea(
                  child: Builder(
                    builder: (context) {
                      // استخدام gradient الممرر أو gradient حسب gender theme
                      AppGradient.logoGradient;

                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppGradient.logoGradient,
                        ),
                        child: body,
                      );
                    },
                  ),
                ),
              ],
            )
          : body,
    );
  }
}
