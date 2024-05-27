import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notification_repository/notification_repository.dart';
import 'package:shop_repository/shop_repository.dart';
import 'package:user_repository/user_repository.dart';
import 'package:sh_app/blocs/shop_blocs/get_shop_bloc.dart';
import 'package:sh_app/blocs/my_user_bloc/my_user_bloc.dart';
import 'package:sh_app/blocs/notification_bloc/notification_bloc.dart';

import '../home/detail_screen.dart';

class Inbox extends StatefulWidget {
  const Inbox({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<Inbox> {
  @override
  void initState() {
    super.initState();
    final userId = context
        .read<MyUserBloc>()
        .state
        .user!
        .id;
    context.read<NotificationBloc>().add(GetNotificationsByUserId(userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Notifications", style: Theme
            .of(context)
            .textTheme
            .headlineMedium
            ?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold)),
        ),),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is NotificationListSuccess) {
            if (state.notifications.isEmpty) {
              return Center(child: Text('No notifications available'));
            }
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return Column(
                  children: [
                    ListTile(
                      title: Text(notification.text),
                      onTap: () {
                        if (notification.shopId != null) {
                          // fetchShopAndNavigate(notification.shopId, context);
                        }
                      },
                    ),
                    const Divider(),

                  ],
                );
              },
            );
          } else if (state is NotificationFailure) {
            return Center(child: Text(
                'Failed to load notifications: ${state.runtimeType}'));
          }
          return Center(child: Text('No notifications available'));
        },
      ),
    );
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