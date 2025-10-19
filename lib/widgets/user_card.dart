import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../bloc/theme_cubit/theme.dart';
import '../model/user.dart';
import '../utils/colors.dart';
import 'package:cached_network_image_platform_interface/cached_network_image_platform_interface.dart';


class UserCard extends StatelessWidget {
  final VoidCallback callback;
  final bool isOnline;
  final UserData userData;

  const UserCard({
    super.key,
    required this.callback,
    required this.isOnline,
    required this.userData,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = context.watch<ThemeCubit>().state;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: AppColors.dark2.withOpacity(.4),
        highlightColor: AppColors.light.withOpacity(.4),
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        onTap: () {
          callback();
        },
        child: Ink(
          decoration: BoxDecoration(
            color: theme.isDark ? AppColors.dark.withOpacity(.8) : AppColors.light.withOpacity(.3),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          height: size.height * 0.1,
          width: size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
              ),
              Stack(
                children: [
                  // CachedNetworkImage(
                  //   imageUrl: userData.imageUrl,
                  //   placeholder: (context, url) => const CircularProgressIndicator(),
                  //   errorWidget: (context, url, error) => const Icon(Icons.error),
                  //   useOldImageOnUrlChange: true,
                  //   imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
                  //   imageBuilder: (context, imageProvider) => Container(
                  //     height: size.height * 0.08,
                  //     width: size.width * 0.15,
                  //     decoration: BoxDecoration(
                  //       color: Colors.white,
                  //       shape: BoxShape.circle,
                  //       image: DecorationImage(
                  //         image: imageProvider,
                  //         fit: BoxFit.cover,
                  //       ),
                  //     ),
                  //   ),
                  // ),

                  Container(
                    height: size.height * 0.08,
                    width: size.width * 0.15,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(

                              imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage,
                              userData.imageUrl),
                          fit: BoxFit.cover,
                        )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: size.width * 0.04,
                      height: size.width * 0.04,
                      decoration: BoxDecoration(
                        color: isOnline ? Colors.blue : AppColors.dark4,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                width: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.light,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    userData.email,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.light.withOpacity(.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
