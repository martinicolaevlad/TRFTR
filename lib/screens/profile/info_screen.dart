import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: Text('Info', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'About TRFTR',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'TRFTR is a mobile application designed by Nicolae-Vlad Marti as part of his '
                    'Bachelor\'s thesis at Babeş-Bolyai University, Cluj-Napoca, under the supervision '
                    'of Lect. Dr. Dan Cojocar. The thesis is titled "Empowering Sustainable Economies '
                    'by Digitalizing Access to Local Thrift Stores" and focuses on enhancing the '
                    'visibility and interaction of local second-hand clothing stores through digital solutions.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Purpose:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'The primary goal of TRFTR is to modernize the interaction between thrift shoppers '
                    'and thrift stores, making it easier for users to find and engage with local second-hand '
                    'clothing outlets. By digitalizing this process, TRFTR aims to support sustainable '
                    'consumption practices and oppose the fast-fashion industry, promoting a more '
                    'environmentally conscious approach to shopping.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Key Features:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'TRFTR integrates advanced mobile application features to facilitate a user-friendly '
                    'interface for both shop owners and customers. Shop owners can register and manage '
                    'their store listings, providing essential information such as shop name, location, '
                    'and business hours. Users can discover shops easily on a map, get updates on new '
                    'stock, and engage with the community through reviews and ratings.',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              Text(
                'Technological Backbone:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Developed using Flutter and Dart, TRFTR leverages a robust framework to ensure a '
                    'seamless and efficient user experience across multiple platforms. The app\'s '
                    'architecture is designed for scalability and responsiveness, utilizing Firebase for '
                    'real-time database management and user authentication.',
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
