import 'package:flutter/material.dart';

class CarouselExample extends StatefulWidget {
  @override
  _CarouselExampleState createState() => _CarouselExampleState();
}

class _CarouselExampleState extends State<CarouselExample> {
  final PageController _pageController = PageController(viewportFraction: 0.8);
  int _currentIndex = 0;

  final List<String> images = [
    'https://via.placeholder.com/300/09f/fff.png', // Example image URL
    'https://via.placeholder.com/300/f0f/000.png',
    'https://via.placeholder.com/300/ff0/000.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Carousel Example")),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (int index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    double value = 1.0;
                    if (_pageController.position.haveDimensions) {
                      value = _pageController.page! - index;
                      value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                    }
                    return Center(
                      child: SizedBox(
                        height: Curves.easeOut.transform(value) * 300,
                        width: Curves.easeOut.transform(value) * 250,
                        child: child,
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                width: _currentIndex == index ? 12.0 : 8.0,
                height: _currentIndex == index ? 12.0 : 8.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.blue : Colors.grey,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
