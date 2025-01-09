import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';

class CustomCacheImageWithDarkFilterFull extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool? circularShape;
  final bool? allPosition;
  final double width;
  final double height;
  const CustomCacheImageWithDarkFilterFull(
      {Key? key,
      required this.imageUrl,
      required this.radius,
      required this.height,
      required this.width,
      this.circularShape,
      this.allPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
          bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
      child: Stack(
        children: [
          SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ImageNetwork(
                image: imageUrl!,
                height: height,
                width: width,
                duration: 1500,
                curve: Curves.easeIn,
                onPointer: true,
                debugPrint: false,
                backgroundColor: Colors.blue,
                fitAndroidIos: BoxFit.cover,
                fitWeb: BoxFitWeb.contain,
                // borderRadius: BorderRadius.circular(70),
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
              )),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xaa000000),
                  Color(0xaa000000),
                  Color(0xaa000000),
                  Color(0xaa000000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCacheImageWithDarkFilterTopBottom extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool? circularShape;
  final bool? allPosition;
  const CustomCacheImageWithDarkFilterTopBottom(
      {Key? key,
      required this.imageUrl,
      required this.radius,
      this.circularShape,
      this.allPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
          bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              placeholder: (context, url) => Container(color: Colors.grey[300]),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xcc000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xcc000000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomCacheImageWithDarkFilterBottom extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool? circularShape;
  final bool? allPosition;
  const CustomCacheImageWithDarkFilterBottom(
      {Key? key,
      required this.imageUrl,
      required this.radius,
      this.circularShape,
      this.allPosition})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
          bottomLeft: Radius.circular(circularShape == false ? 0 : radius),
          bottomRight: Radius.circular(circularShape == false ? 0 : radius)),
      child: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: ImageNetwork(
              image: imageUrl!,
              height: 300,
              width: 500,
              duration: 1500,
              curve: Curves.easeIn,
              onPointer: true,
              debugPrint: false,
              backgroundColor: Colors.blue,
              fitAndroidIos: BoxFit.cover,
              fitWeb: BoxFitWeb.contain,
              // borderRadius: BorderRadius.circular(70),
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
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0x00000000),
                  Color(0xcc000000),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
