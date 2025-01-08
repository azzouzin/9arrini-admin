import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_network/image_network.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class CustomCacheImage extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool? circularShape;
  const CustomCacheImage(
      {Key? key,
      required this.imageUrl,
      required this.radius,
      this.circularShape})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
            bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
        child: ImageNetwork(
          image: imageUrl!,
          height: 50.0,
          width: 50.0,
          duration: 1500,
          curve: Curves.easeIn,
          onPointer: true,
          debugPrint: false,
          backgroundColor: Colors.blue,
          fitAndroidIos: BoxFit.cover,
          fitWeb: BoxFitWeb.contain,
          borderRadius: BorderRadius.circular(70),
          onLoading: const CircularProgressIndicator(
            color: Colors.indigoAccent,
          ),
          onError: const Icon(
            Icons.error,
            color: Colors.red,
          ),
          onTap: () {
            debugPrint("©gabriel_patrick_souza");
          },
        )
        // CachedNetworkImage(
        //   //httpHeaders: {'crossOrigin': 'anonymous'},
        //   imageRenderMethodForWeb: ImageRenderMethodForWeb.HttpGet,
        //   imageUrl: imageUrl!,
        //   fit: BoxFit.fill,
        //   width: double.infinity,
        //   height: MediaQuery.of(context).size.height,
        //   placeholder: (context, url) => Container(color: Colors.grey[300]),
        //   errorWidget: (context, url, error) {
        //     Logger().e(error);
        //     return Container(
        //       color: Colors.grey[300],
        //       child: const Icon(Icons.error),
        //     );
        //   },
        // ),
        );
  }
}
