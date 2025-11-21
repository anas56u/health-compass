import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'font_weight_helper.dart';

class AppTextStyling {
  AppTextStyling._();

  // font Family poppins
  static TextStyle fontFamilyTajawal = GoogleFonts.tajawal(
    textStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeightHelper.medium,
      height: 1,
      letterSpacing: 0.1,
      // color: AppColors.text,
    ),
  );
  // font Family Inter
  static TextStyle fontFamilyInter = GoogleFonts.inter(
    textStyle: TextStyle(
      fontSize: 10,
      fontWeight: FontWeightHelper.regular,
      // color: AppColors.text,
    ),
  );
  // font Family Roboto
  static TextStyle fontFamilyRoboto = GoogleFonts.roboto(
    textStyle: TextStyle(
      fontSize: 10,
      fontWeight: FontWeightHelper.regular,
      // color: AppColors.text,
    ),
  );

  // font Family Sakkal Majalla
  static TextStyle fontFamilySakkalMajalla = TextStyle(
    fontFamily: 'SakkalMajalla',
    fontSize: 10,
    fontWeight: FontWeightHelper.regular,
    // color: AppColors.text,
  );

  // font Family STC Forward
  static TextStyle fontFamilySTCForward = TextStyle(
    fontFamily: 'STCForward',
    fontSize: 14,
    fontWeight: FontWeightHelper.regular,

    // color: AppColors.text,
  );
}
