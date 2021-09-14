import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

TextStyle appBarStyle = TextStyle(
  color: Colors.black,
);

TextStyle sheetHeaderStyle = TextStyle(fontWeight: FontWeight.bold);

Color titleColor = Colors.green.withOpacity(0.5);

class GradientColors {
  final List<Color> colors;
  GradientColors(this.colors);

  static List<Color> sky = [Color(0xFF6448FE), Color(0xFF5FC6FF)];
  static List<Color> sunset = [Color(0xFFFE6197), Color(0xFFFFB463)];
  static List<Color> sea = [Color(0xFF61A3FE), Color(0xFFBB7AF2)];
  static List<Color> mango = [Color(0xFFF4AE64), Color(0xFFFFE130)];
  static List<Color> fire = [Color(0xFFEB638A), Color(0xFFFF8484)];
}

class GradientTemplate {
  static List<GradientColors> gradientTemplate = [
    GradientColors(GradientColors.sky),
    GradientColors(GradientColors.sunset),
    GradientColors(GradientColors.sea),
    GradientColors(GradientColors.mango),
    GradientColors(GradientColors.fire),
  ];
}

List emailList = [
  '선택하세요',
  '@naver.com',
  '@hanmail.net',
  '@nate.com',
  '@daum.net',
  '@gmail.com',
  '직접 입력'
];

List<String> mbtiList = [
  "ISTJ",
  "ISFJ",
  "INFJ",
  "INTJ",
  "ISTP",
  "ISFP",
  "INFP",
  "INTP",
  "ESTP",
  "ESFP",
  "ENFP",
  "ENTP",
  "ESTJ",
  "ESFJ",
  "ENFJ",
  "ENTJ",
];
List<String> mbtiType = [
  "청렴결백한",
  "용감한",
  "선의의",
  "용의주도한",
  "만능",
  "호기심 많은",
  "열정적인",
  "논리적인",
  "모험을 즐기는",
  "자유로운 영혼의",
  "재기발랄한",
  "논쟁을 즐기는",
  "엄격한",
  "사교적인",
  "정의로운",
  "대담한",
];

List<String> mbtiType2 = [
  "논리주의자",
  "수호자",
  "옹호자",
  "전력가",
  "재주꾼",
  "예술가",
  "중재자",
  "사색가",
  "사업가",
  "연예인",
  "활동가",
  "변론가",
  "관리자",
  "외교관",
  "사회운동가",
  "통솔자",
];

// List<String> mbtiType = [
//   "논리주의자",
//   "수호자",
//   "옹호자",
//   "전력가",
//   "만능 재주꾼",
//   "호기심 많은 예술가",
//   "열정적인 중재자",
//   "논리적인 사색가",
//   "모험을 즐기는 사업가",
//   "자유로운 연예인",
//   "재기발랄한 활동가",
//   "논쟁을 즐기는 변론가",
//   "엄격한 관리자",
//   "사교적인 외교관",
//   "정의로운 사회운동가",
//   "대담한 통솔자",
// ];
