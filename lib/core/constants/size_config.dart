import 'package:flutter/material.dart';

class SizeConfig {
  // Singleton pattern
  static final SizeConfig _instance = SizeConfig._internal();
  factory SizeConfig() => _instance;

  SizeConfig._internal();

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double designHeight;
  static late double designWidth;
  static late Orientation orientation;
  static late double pixelRatio;

  // Initialization method with designHeight and designWidth from the user
  void init(
    BuildContext context, {
    double? designHeightFromInit,
    double? designWidthFromInit,
  }) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;
    pixelRatio = _mediaQueryData.devicePixelRatio;

    // Default to 375x812 unless provided
    designHeight = designHeightFromInit ?? 812.0;
    designWidth = designWidthFromInit ?? 375.0;
  }
}

// Get the proportionate height as per screen size
double getProportionateScreenHeight(double inputHeight) {
  double screenHeight = SizeConfig.screenHeight;
  double designHeight = SizeConfig.designHeight;
  return (inputHeight / designHeight) * screenHeight;
}

// Get the proportionate width as per screen size
double getProportionateScreenWidth(double inputWidth) {
  double screenWidth = SizeConfig.screenWidth;
  double designWidth = SizeConfig.designWidth;
  return (inputWidth / designWidth) * screenWidth;
}

// Get proportionate text size based on the screen width
double getProportionateTextSize(double inputTextSize) =>
    getProportionateScreenWidth(inputTextSize);

// Get proportionate padding or margin
double getProportionatePadding(double inputPadding) =>
    getProportionateScreenWidth(inputPadding);

// Check if the device is in portrait mode
bool isPortrait() => SizeConfig.orientation == Orientation.portrait;

// Check if the device is in landscape mode
bool isLandscape() => SizeConfig.orientation == Orientation.landscape;
