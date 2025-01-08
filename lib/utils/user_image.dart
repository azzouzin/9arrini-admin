import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../configs/config.dart';


class GetUserAvatar extends StatelessWidget {
  const GetUserAvatar({Key? key, this.imageUrl, this.assetString, this.cirlceSize}) : super(key: key);

  final String? imageUrl;
  final String? assetString;
  final double? cirlceSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      height: cirlceSize ?? 30,
      width: cirlceSize ?? 30,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green[100],
          image: DecorationImage(
            fit: imageUrl != null ? BoxFit.cover : BoxFit.scaleDown,
            image: imageUrl != null
                ? CachedNetworkImageProvider(imageUrl.toString())
                : AssetImage(assetString ?? Config.defaultAvatarString) as ImageProvider<Object>,
          )),
    );
  }
}
