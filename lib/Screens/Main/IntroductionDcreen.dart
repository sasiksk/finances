import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skfinance/Screens/Main/SplashScreen.dart';

class IntroductionScreen extends StatelessWidget {
  const IntroductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 241, 245, 245),
              Color.fromARGB(255, 95, 109, 101)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to Digi Vasool',
                style: GoogleFonts.tinos(
                  textStyle: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Effortlessly manage your finances with our app. Start by entering your finance name and track your daily and weekly collection data with ease.',
                textAlign: TextAlign.center,
                style: GoogleFonts.tinos(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Image.asset(
                'assets/intro_image.png',
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue.shade900,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 60, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 5,
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SplashScreen()),
                  );
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: GoogleFonts.tinos().fontFamily,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Sri Selva Vinayaga Software Solutions',
                style: GoogleFonts.tinos(
                  textStyle: const TextStyle(
                      fontSize: 12,
                      color: Color.fromARGB(137, 13, 59, 2),
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
