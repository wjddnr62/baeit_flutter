import 'package:flutter/cupertino.dart';

enum TextWeight { BOLD, MEDIUM, REGULAR, LIGHT, THIN }

const fontFamily = 'spoqahansansneo';

customTextSpan({required String text, TextStyle? style}) {
  if (style != null) {
    TextStyle textStyle = TextStyle(
      color: style.color,
      fontWeight: style.fontWeight,
      fontSize: style.fontSize,
      fontFamily: fontFamily,
      height: 1.4,
      letterSpacing: -0.02,
      decoration:
          style.decoration != null ? style.decoration : TextDecoration.none,
    );
    return TextSpan(
      text: text,
      style: textStyle,
    );
  } else {
    return TextSpan(
      text: text,
    );
  }
}

customText(String text,
    {TextStyle? style,
    TextAlign? textAlign,
    TextOverflow? overflow,
    double? height = 1.4,
    int? maxLines}) {
  if (style != null) {
    TextStyle textStyle = TextStyle(
      color: style.color,
      fontWeight: style.fontWeight,
      fontSize: style.fontSize,
      fontFamily: fontFamily,
      height: height,
      letterSpacing: -0.02,
      decoration: style.decoration ?? TextDecoration.none,
    );
    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  } else {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
    );
  }
}

weightSet({TextWeight? textWeight}) {
  switch (textWeight) {
    case TextWeight.BOLD:
      return FontWeight.w700;
    case TextWeight.MEDIUM:
      return FontWeight.w500;
    case TextWeight.REGULAR:
      return FontWeight.w400;
    case TextWeight.LIGHT:
      return FontWeight.w300;
    case TextWeight.THIN:
      return FontWeight.w100;
    default:
      return FontWeight.w500;
  }
}

enum TextSize {
  T8,
  T9,
  T10,
  T11,
  T12,
  T13,
  T14,
  T15,
  T16,
  T17,
  T18,
  T20,
  T21,
  T27
}

fontSizeSet({TextSize? textSize}) {
  switch (textSize) {
    case TextSize.T8:
      return 8.toDouble();
    case TextSize.T9:
      return 9.toDouble();
    case TextSize.T10:
      return 10.toDouble();
    case TextSize.T11:
      return 11.toDouble();
    case TextSize.T12:
      return 12.toDouble();
    case TextSize.T13:
      return 13.toDouble();
    case TextSize.T14:
      return 14.toDouble();
    case TextSize.T15:
      return 15.toDouble();
    case TextSize.T16:
      return 16.toDouble();
    case TextSize.T17:
      return 17.toDouble();
    case TextSize.T18:
      return 18.toDouble();
    case TextSize.T20:
      return 20.toDouble();
    case TextSize.T21:
      return 21.toDouble();
    case TextSize.T27:
      return 27.toDouble();
    default:
      return 12.toDouble();
  }
}
