import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shop_repository/shop_repository.dart';

class DetailScreen extends StatelessWidget {
  final MyShop shop;

  const DetailScreen({required this.shop, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(shop.name, style: Theme.of(context).textTheme.displayMedium, ),
        leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.red,
                child: isValidPicture(shop.picture)
                    ? Image.network(
                  shop.picture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(CupertinoIcons.photo, size: 100),
                )
                    : Icon(CupertinoIcons.photo, size: 100),
              ),
              SizedBox(height: 16.0),

              Text(
                'Rating: ${shop.rating}',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              Text(
                "${(shop.openTime / 100).toInt().toString().padLeft(2, '0')}:${(shop.openTime % 100).toString().padLeft(2, '0')} - ${(shop.closeTime / 100).toInt().toString().padLeft(2, '0')}:${(shop.closeTime % 100).toString().padLeft(2, '0')}",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: 8.0),
              if(shop.nextDrop == DateTime.now())
                const Text(
                  'Next Drop: TODAY',
                  style: TextStyle(fontSize: 16.0),
                ),
              if (shop.nextDrop != null)
                Text(
                  'Next Drop: ${shop.nextDrop?.day}.${shop.nextDrop?.month}.${shop.nextDrop?.year}',
                  style: TextStyle(fontSize: 16.0),
                ),
              if (shop.lastDrop != null)
                Text(
                  'Last Drop: ${shop.lastDrop?.day}.${shop.lastDrop?.month}.${shop.lastDrop?.year}',
                  style: TextStyle(fontSize: 16.0),
                ),
              SizedBox(height: 8.0),

              SizedBox(height: 16.0),
              // Add more details as needed
            ],
          ),
        ),
      ),
    );
  }
  bool isValidPicture(String? url) {
    return url != null && url.isNotEmpty && Uri.tryParse(url)?.hasAbsolutePath == true;
  }
}

