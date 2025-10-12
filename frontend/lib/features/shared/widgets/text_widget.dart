import 'package:pocketly/core/core.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color = AppColors.textPrimary,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.letterSpacing,
  });

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? letterSpacing;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      ),
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
