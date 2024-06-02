import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:sh_app/blocs/notification_bloc/notification_bloc.dart';

import '../../components/rainbow.dart';
import '../home/detail_screen.dart';
class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  late final String userId;
  final FirebaseShopRepo _shopRepo = FirebaseShopRepo();

  @override
  void initState() {
    super.initState();
    // We assume MyUserBloc is provided above this in the widget tree.
    userId = context.read<MyUserBloc>().state.user!.id;
    // Triggering the event to start listening to the notifications.
    // context.read<NotificationBloc>().add(LoadNotifications(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Notifications",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          log(state.toString());
          if (state is NotificationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            log(state.notifications.toString());
            if (state.notifications.isEmpty) {
              return Center(child: Text('No notifications available'));
            }
            return ListView.builder (
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        tileColor: Colors.white,
                          leading: FutureBuilder<Widget>(
                            future: getIconBasedOnText(notification), // Assume this is an async function returning IconData
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                if (snapshot.hasData) {
                                  return Container(child: snapshot.data);
                                } else {
                                  // Default icon if no data is found or error
                                  return Icon(Icons.error);
                                }
                              } else {
                                // Show loading indicator while waiting
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.text),
                            Text(timeAgo(notification.time), style: TextStyle(fontSize: 14)),
                          ],
                        ),
                          onTap: () async {
                            if (notification.shopId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("No shop ID found for this notification")),
                              );
                              return;
                            }

                            print("Fetching details for shop ID: ${notification.shopId}");  // Debugging statement
                            MyShop? shop = await _shopRepo.getShopById(notification.shopId);
                            if (shop != null) {
                              print("Shop details fetched, navigating to detail screen.");  // Debugging statement
                              MyUserState userState = context.read<MyUserBloc>().state;
                                  if (userState.user != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailScreen(shop: shop, user: userState.user!),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text(
                                          "User information not available")),
                                    );
                                  }


                            }
                          }
                      ),
                    ),
                  ],
                );
              },
            );

          } else if (state is NotificationFailure) {
            return Center(
              child: Text('Failed to load notifications'),
            );
          }
          return Center(child: Text('No notifications available'));
        },
      ),
    );
  }

  String timeAgo(DateTime notificationTime) {
    final Duration difference = DateTime.now().difference(notificationTime);

    if (difference.inDays >= 1) {
      return '${difference.inDays} day${difference.inDays == 1 ? "" : "s"} ago';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} hour${difference.inHours == 1 ? "" : "s"} ago';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? "" : "s"} ago';
    } else if (difference.inSeconds >= 1) {
      return '${difference.inSeconds} second${difference.inSeconds == 1 ? "" : "s"} ago';
    } else {
      return 'Just now';
    }
  }

  Future<Widget> getIconBasedOnText(MyNotification notification) async {
    RegExp regex = RegExp(r"stars|favourites|tomorrow|TODAY", caseSensitive: false);
    Match? match = regex.firstMatch(notification.text);
    MyShop? shop = await _shopRepo.getShopById(notification.shopId);
    if (match != null) {
      if (match.group(0)!.toLowerCase() == "stars") {
        return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black87), shape: BoxShape.circle, color: CupertinoColors.systemYellow,),
            child:const Icon(
                Icons.star_border_rounded,
                color: Colors.black,
                size: 25));
      } else if (match.group(0)!.toLowerCase() == "favourites") {
        return Container(
            width: 40,
            height: 70,
            decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black87), shape: BoxShape.circle, color: Colors.red,),
            child:const Icon(
                Icons.favorite_border_rounded,
                color: Colors.black,
                size: 25));
    } else if (match.group(0)!.toLowerCase() == "tomorrow") {

        return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black87), color: Colors.purple.shade400,),
            child:Container(
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: isValidPicture(shop?.picture)
                      ? NetworkImage(shop!.picture!)
                      : const AssetImage('assets/images/default_shop.jpg') as ImageProvider,
                ),
              ),
            ),);
    } else if (match.group(0)!.toLowerCase() == "TODAY") {
        return Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black87), shape: BoxShape.circle, color: Colors.purple, gradient: RainbowGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const <Color>[
                Color(0xFFFF0064),
                Color(0xFFFF7600),
                Color(0xFFFFD500),
                Color(0xFF8CFE00),
                Color(0xFF00E86C),
                Color(0xFF00F4F2),
                Color(0xFF00CCFF),
                Color(0xFF70A2FF),
                Color(0xFFA96CFF),
              ],
            ),),
            child:const Icon(
                Icons.notification_important_rounded,
                color: Colors.black,
                size: 25,));}
    }
    return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(border: Border.all(width: 2, color: Colors.black87),shape: BoxShape.circle, color: Colors.grey.shade300),
        child:const Icon(
          Icons.notifications_rounded,
          color: Colors.black,
          size: 25,));
  }

  bool isValidPicture(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }
//   void fetchShopAndNavigate(String shopId, BuildContext context) {
//     final getShopBloc = BlocProvider.of<GetShopBloc>(context);
//
//     // Listen only to the next state after dispatching the event
//     final subscription = getShopBloc.stream.listen((shopState) {
//       if (shopState is GetShopSuccess && shopState.shops.isNotEmpty) {
//         final shop = shopState.shops.first;
//         final user = context.read<MyUserBloc>().state.user;
//         if (user != null) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => DetailScreen(shop: shop, user: user)),
//           );
//           subscription.cancel();  // Important to cancel subscription after navigation
//         }
//       }
//     });
//
//     getShopBloc.add(GetShopById(shopId)); // Trigger fetching the shop
//   }
// }
}