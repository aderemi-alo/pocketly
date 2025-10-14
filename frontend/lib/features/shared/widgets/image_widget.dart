import 'package:flutter_svg/svg.dart';
import 'package:pocketly/core/core.dart';
import 'package:extended_image/extended_image.dart';

class ImageWidget extends StatelessWidget {
  const ImageWidget({
    super.key,
    required this.url,
    this.fit = BoxFit.contain,
    this.height,
    this.width,
    this.color,
    this.scale,
    this.blendMode,
  });

  final String url;
  final BoxFit fit;
  final double? scale;
  final double? height;
  final double? width;
  final Color? color;
  final BlendMode? blendMode;

  @override
  Widget build(BuildContext context) {
    final imageType = url._detectImageType();

    return switch (imageType) {
      _ImageType.pngAsset => ExtendedImage.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale,
        colorBlendMode: blendMode,
      ),
      _ImageType.svgAsset => SvgPicture.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => const Icon(Icons.error),
      ),
      _ImageType.svgNetwork => SvgPicture.network(
        url,
        height: height,
        width: width,
        fit: fit,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
        placeholderBuilder: (context) => const Icon(Icons.error),
      ),
      _ImageType.pngNetwork => ExtendedImage.network(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale ?? 1,
        colorBlendMode: blendMode,
      ),
      _ImageType.jpgAsset => ExtendedImage.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale,
        colorBlendMode: blendMode,
      ),
      _ImageType.jpgNetwork => ExtendedImage.network(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale ?? 1,
        colorBlendMode: blendMode,
      ),
      _ImageType.webpNetwork => ExtendedImage.network(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale ?? 1,
        colorBlendMode: blendMode,
      ),
      _ImageType.webpAsset => ExtendedImage.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        color: color,
        scale: scale,
        colorBlendMode: blendMode,
      ),
      _ImageType.unknown => const SizedBox.shrink(),
    };
  }
}

enum _ImageType {
  svgNetwork,
  svgAsset,
  pngNetwork,
  pngAsset,
  jpgNetwork,
  jpgAsset,
  webpNetwork,
  webpAsset,
  unknown,
}

extension _ImageTypeDetector on String {
  _ImageType _detectImageType() {
    final urlPattern = RegExp(
      r'^(https?:\/\/)?'
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|'
      r'((\d{1,3}\.){3}\d{1,3})|'
      r'res\.cloudinary\.com)'
      r'(:\d+)?'
      r'(\/[-a-z\d%_.~+]*)*'
      r'(\?[;&a-z\d%_.~+=-]*)?'
      r'(\#[-a-z\d_]*)?$',
      caseSensitive: false,
    );

    final assetPattern = RegExp(
      r'^assets\/.*\.(svg|png|jpg|jpeg|webp)$',
      caseSensitive: false,
    );

    final lower = toLowerCase();

    if (urlPattern.hasMatch(this)) {
      if (lower.endsWith('.svg')) {
        return _ImageType.svgNetwork;
      } else if (lower.endsWith('.png') || contains('res.cloudinary.com')) {
        return _ImageType.pngNetwork;
      } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
        return _ImageType.jpgNetwork;
      } else if (lower.endsWith('.webp')) {
        return _ImageType.webpNetwork;
      }
    } else if (assetPattern.hasMatch(this) ||
        lower.endsWith('.svg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      if (lower.endsWith('.svg')) {
        return _ImageType.svgAsset;
      } else if (lower.endsWith('.png')) {
        return _ImageType.pngAsset;
      } else if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
        return _ImageType.jpgAsset;
      } else if (lower.endsWith('.webp')) {
        return _ImageType.webpAsset;
      }
    }

    return _ImageType.unknown;
  }
}
