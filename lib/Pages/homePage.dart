import 'package:flutter/material.dart';
import 'package:teamup/Pages/namingcreate.dart';
import 'package:teamup/Pages/namingjoin.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Positioned.fill(child: SvgPicture.asset("assets/bgImages/screen1.svg")),
          Positioned.fill(child: Image.asset("assets/bgImages/screen1.png")),
          // Positioned(child: SvgPicture.asset("assets/bgImages/HomePageImage.svg",height: 40,width: 40,)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(255, 85, 85, 85),
                          blurRadius: 6,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Namingcreate(),
                          ),
                        );
                      },
                      style: ButtonStyle(
                        fixedSize: WidgetStatePropertyAll(Size(250, 45)),
                        shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        backgroundColor: WidgetStatePropertyAll<Color>(
                          Colors.black,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 70),
                        child: Text(
                          "create",
                          style: TextStyle(
                            fontSize: 20,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(255, 160, 160, 160),
                      blurRadius: 6,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Namingjoin(),
                          ),
                        );
                  },
                  style: ButtonStyle(
                    fixedSize: WidgetStatePropertyAll(Size(250, 45)),
                    shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ), // Border here
                      ),
                    ),
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.white,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 70),
                    child: Text(
                      "join",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 90),
            ],
          ),
        ],
      ),
    );
  }
}
