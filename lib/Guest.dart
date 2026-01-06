import 'Login.dart';
import 'package:flutter/material.dart';
import 'ExhibitionGuest.dart';
import 'package:url_launcher/url_launcher.dart'; // 3rd party package url_laucher



class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar:AppBar(
        toolbarHeight: 69,
        backgroundColor: Colors.blueGrey,
        title:  const Text('Berjaya Convention'),


//Account Icon
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage()));
            },
          ),
        ],
      ),
//Create Drawer
      drawer:Drawer(
          child:Container( color:Colors.blueGrey.shade200 ,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: 100,
                  child: DrawerHeader(decoration: BoxDecoration(color: Colors.blueGrey.shade500),
                    child: const Text('Explore More Our Service',
                      style: TextStyle(color: Colors.white),
                    ),

                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_events),
                  title: const Text('Exhibition'),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ExhibitionGuest()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Login/Register'),
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage()));
                  },
                ),
              ],
            ),
          )
      ),
      body:SingleChildScrollView(
        child: Column( //Header
          children: [
            Container(
              width: double.infinity,  // This makes it full width
              height: 130,
              padding:const EdgeInsets.all(24) ,
              decoration:const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:[Color(0xFF2563eb),
                        Color(0xFF1e40af),] )
              ) ,
              child: const Text('Welcome to \nBerjaya International Convention Center',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),


            // "Current Event" Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: Colors.blueGrey,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Event',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ExhibitionGuest()));
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //Current Card
            const SizedBox(height: 20),

            const CurentCard(),

            const SizedBox(height: 20),
            const CurentCard2(),



            const SizedBox(height: 40),// gap

            //Upcoming Event
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: Colors.blueGrey,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Upcoming Event',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const ExhibitionGuest()));
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            //Current Card
            const UpcomingCard(),
            const SizedBox(height: 20),
            const UpcomingCard2(),

            const SizedBox(height: 40),// gap

// Booth Layout Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.map_outlined,
                    color: Colors.blueGrey,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Booth Layout',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20),
            const LayoutCard(),
            const SizedBox(height: 20,),
            const BookButton(),
            const NoticeText(),
            const SizedBox(height: 40,),

            //Contact us title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.contact_mail,
                    color: Colors.blueGrey,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey,
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 20,),
            const ContactCard(),




          ],
        ),

      ),
    ));
  }
}



class CurentCard extends StatelessWidget{
  const CurentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(

        width: 350,
        height: 200,
        decoration:  BoxDecoration(
          border:  Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
          image: const DecorationImage(image:AssetImage('assets/BrandDay.jpg'),
              fit: BoxFit.cover),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacer to push description to bottom
            const Spacer(),
// Description container at bottom
            Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6), // Semi-transparent background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: const Text(
                'Event Description: Annual Tech Conference 2024',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),



    );
  }

}
class CurentCard2 extends StatelessWidget{
  const CurentCard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(

        width: 350,
        height: 200,
        decoration:  BoxDecoration(
          border:  Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
          image: const DecorationImage(image:AssetImage('assets/Cars.jpg'),
              fit: BoxFit.cover),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Spacer to push description to bottom
            const Spacer(),
// Description container at bottom
            Container(
              height: 70,
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6), // Semi-transparent background
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
              child: const Text(
                'Event Description: Annual Tech Conference 2024',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),



    );
  }

}

class UpcomingCard extends StatelessWidget{
  const UpcomingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 110,
        decoration: BoxDecoration(
          border:  Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 80,
              decoration:const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:[Color(0xFF2563eb),
                        Color(0xFF1e40af),] )
              ) ,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NOV',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '25',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Asean Summit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Meet our prime minister be as a leader of ASEAN',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3:00 PM - 5:00 PM',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),

                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

}

class UpcomingCard2 extends StatelessWidget{
  const UpcomingCard2({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 110,
        decoration: BoxDecoration(
          border:  Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 90,
              height: 80,
              decoration:const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:[Color(0xFF2563eb),
                        Color(0xFF1e40af),] )
              ) ,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DEC',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '10',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Asean Summit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Meet our prime minister be as a leader of ASEAN',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '3:00 PM - 5:00 PM',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                    ),
                  ),

                ],
              ),
            ))
          ],
        ),
      ),
    );
  }

}

class LayoutCard extends StatelessWidget{
  const LayoutCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 300,
        decoration:  BoxDecoration(
          border:  Border.all(
            color: Colors.black,
            width: 2.0,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12.0),
          image: const DecorationImage(image:AssetImage('assets/Layout.png'),
              fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class BookButton extends StatelessWidget{
  const BookButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: FloatingActionButton.extended(
          backgroundColor: Colors.blueAccent,
          label:const Text('Booking'),
          onPressed: () {

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('LOGIN FIRST!!'),
                duration: Duration(seconds: 2),
              ),
            );

            Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const LoginPage()));
          },


        )
    );
  }

}

class NoticeText extends StatelessWidget {
  const NoticeText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Log In First', // You need to provide the text content
        style: TextStyle(
          color: Colors.red,
          fontWeight:FontWeight.bold,
          fontSize:14,
        ),
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 350,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(// to create empty space in container
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Contact us now!!!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 12),

              // Email Contact Section
              const Text(
                'Send us an email:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),

              ElevatedButton.icon(
                onPressed: () async {
                  String? encodeQueryParameters(Map<String, String> params) {
                    return params.entries
                        .map((MapEntry<String, String> e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                        .join('&');
                  }

                  final Uri emailLaunchUri = Uri(
                    scheme: 'mailto',
                    path: 'berjaya@gmail.com',
                    query: encodeQueryParameters(<String, String>{
                      'subject': 'Convention Info',
                    }),
                  );

                  if (await canLaunchUrl(emailLaunchUri)){
                    launchUrl(emailLaunchUri);
                  }else{
                    throw Exception('Could not launch $emailLaunchUri');
                  }

                },
                icon: const Icon(Icons.email, size: 20),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'berjaya@gmail.com',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.brown,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),

              const SizedBox(height: 20),

              // Phone Contact Section
              const Text(
                'SMS us:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 12),

              //indirect call
              OutlinedButton.icon(
                onPressed: () async{
                  final Uri telLaunchUri = Uri( //determine the scheme and path
                    scheme: 'tel',
                    path: '+1-555-010-999',
                  );
                  launchUrl(telLaunchUri); //call Uri
                },
                icon: const Icon(Icons.phone, size: 20),
                label: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    '+1-555-010-999',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.brown),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}