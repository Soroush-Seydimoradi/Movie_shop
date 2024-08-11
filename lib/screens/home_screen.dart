import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_movie_shop/const/url.dart';
import 'package:flutter_movie_shop/model/movie_model.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import '../model/carousel_model.dart';
import '../model/star_model.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CarouselModel> carouselList = [];
  List<MovieModel> movieList1 = [];
  List<MovieModel> movieList2 = [];
  List<StarModel> starList = [];

  bool carousel = false;
  bool movie = false;
  bool star = false;

  callCarouselApi() async {
    final url = Uri.parse("$movieUrl=pageviewmovie");
    carousel = true;
    final Response _response = await get(url);
    carousel = false;
    if (_response.statusCode == 200) {
      final data = jsonDecode(_response.body);
      for (int i = 0; i < data.length; i++) {
        setState(() {
          carouselList.add(
            CarouselModel(
              id: data[i]['id'],
              imgSlide: data[i]['img_slide'],
              name: data[i]['name'],
            ),
          );
        });
      }
    }
  }

  callMovieApi(String inputUrl, List<MovieModel> movieList) async {
    final url = Uri.parse('$movieUrl=$inputUrl');
    movie = true;
    final Response response = await get(url);
    movie = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        setState(() {
          movieList.add(
            MovieModel(
              id: data[i]['id'],
              name: data[i]['name'],
              desc: data[i]['description'],
              saleSakht: data[i]['saleSakht'],
              price: data[i]['price'],
              imageUrl: data[i]['image_url'],
              keshvar: data[i]['keshvar'],
              zaman: data[i]['zaman'],
            ),
          );
        });
      }
    }
  }

  callStarApi() async {
    final url = Uri.parse('$movieUrl=stars');
    star = true;
    final Response response = await get(url);
    star = false;
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      for (int i = 0; i < data.length; i++) {
        setState(() {
          starList.add(
            StarModel(
              id: data[i]['id'],
              name: data[i]['name'],
              pic: data[i]['pic'],
            ),
          );
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    callCarouselApi();
    callMovieApi('movie1', movieList1);
    callMovieApi('movie2', movieList2);
    callStarApi();
  }

  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            carousel
                ? LoadingWidget(width: width)
                : CarouselWidget(carouselList: carouselList, width: width),
            movie
                ? LoadingWidget(width: width)
                : MovieSection(
                    width: width,
                    movieList: movieList1,
                    title: 'پرفروش ترین',
                  ),
            SizedBox(height: 20),
            star
                ? LoadingWidget(width: width)
                : starSection(starList: starList),
            movie
                ? LoadingWidget(width: width)
                : MovieSection(
                    width: width,
                    movieList: movieList2,
                    title: 'تازه ترین',
                  ),
          ],
        ),
      ),
    );
  }
}

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    super.key,
    required this.width,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 200,
        child: SpinKitFadingFour(
          color: Colors.deepPurpleAccent,
          size: width * 0.15,
        ),
      ),
    );
  }
}

class starSection extends StatelessWidget {
  const starSection({
    super.key,
    required this.starList,
  });

  final List<StarModel> starList;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: starList.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 120,
            width: 120,
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: FadeInImage(
                      placeholder: AssetImage('assets/images/logo.png'),
                      image: NetworkImage(starList[index].pic),
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Text(
                  starList[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

class MovieSection extends StatelessWidget {
  const MovieSection({
    super.key,
    required this.width,
    required this.movieList,
    required this.title,
  });

  final double width;
  final List<MovieModel> movieList;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold',
                    fontSize: 20),
              ),
              const Text(
                'بیشتر >',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'bold',
                    fontSize: 16),
              )
            ],
          ),
        ),
        SizedBox(
          width: width,
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movieList.length,
            itemBuilder: (context, index) {
              final helper = movieList[index];
              return SizedBox(
                width: 175,
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          id: helper.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8, left: 8, right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: FadeInImage(
                              placeholder: AssetImage('assets/images/logo.png'),
                              image: NetworkImage(helper.imageUrl),
                              width: 150,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            helper.name,
                            maxLines: 1,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'bold',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            helper.price + ',000 تومان',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'bold',
                                color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CarouselWidget extends StatelessWidget {
  const CarouselWidget({
    super.key,
    required this.carouselList,
    required this.width,
  });

  final List<CarouselModel> carouselList;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: carouselList.length,
          itemBuilder: (context, index, realIndex) {
            return Stack(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      carouselList[index].imgSlide,
                      width: width,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 55,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(7.5),
                    ),
                    child: Text(
                      carouselList[index].name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'bold',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.95,
          ),
        )
      ],
    );
  }
}
