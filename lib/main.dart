// ignore_for_file: avoid_print

import 'dart:math';

import 'package:boxy/boxy.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final customCard = CustomCard();

  late final List<Widget> customCards;

  @override
  void initState() {
    super.initState();
    customCards = List<Widget>.generate(10, (_) => customCard.randomCard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        color: Colors.white,
        child: ColoredBox(
          color: Colors.grey,
          child: CustomBoxy(
            delegate: CardListBoxyDelegate(),
            children: [
              BoxyId(
                id: #list,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: customCards.length,
                  itemBuilder: (_, i) {
                    return UnconstrainedBox(child: customCards[i]);
                  },
                  separatorBuilder: (_, __) => customCard.separator(),
                ),
              ),
              BoxyId(
                id: #maxFilledCard,
                child: ExcludeSemantics(
                  child: GestureDetector(
                    onTap: () => print('Something got hit'),
                    // Card widget with any height changed by font size etc
                    // It won't be painted nor hit-tested
                    child: Container(
                      height: customCard.maxSize,
                      width: 800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomCard {
  CustomCard({
    this.maxSize = 300,
    this.minSize = 100,
    this.cardWidth = 250,
  });

  final double maxSize;
  final double minSize;
  final double cardWidth;

  final rnd = Random(1);

  double randomSize() {
    return minSize + rnd.nextDouble() * (maxSize - minSize);
  }

  Widget separator() => const SizedBox(width: 10);

  Widget randomCard() {
    return Container(
      height: randomSize(),
      width: cardWidth,
      color: Colors.pink.shade400,
    );
  }
}

class CardListBoxyDelegate extends BoxyDelegate {
  @override
  Size layout() {
    final maxFilledCard = getChild(#maxFilledCard);
    final list = getChild(#list);

    final Size naxFilledCardSize = maxFilledCard.layout(constraints);
    final Size listSize =
        list.layout(constraints.tighten(height: naxFilledCardSize.height));

    return Size(listSize.width, naxFilledCardSize.height);
  }

  @override
  void paintChildren() => getChild(#list).paint();

  @override
  bool hitTest(SliverOffset position) {
    if (getChild(#list).hitTest()) {
      addHit();
      return true;
    }
    return false;
  }
}
