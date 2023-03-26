// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdScreen extends StatefulWidget {
  final String nameOrigin;
  const AdScreen({super.key, required this.nameOrigin});

  @override
  State<AdScreen> createState() => _AdScreenState();
}

class _AdScreenState extends State<AdScreen> {
  String HomeBannerAd = 'ca-app-pub-2931129192084584/1107438584';
  String ReviewsBannerAd = 'ca-app-pub-2931129192084584/9988019084';
  String ProfileBannerAd = 'ca-app-pub-2931129192084584/5412132211';
  String testAd = 'ca-app-pub-3940256099942544/6300978111';
  BannerAd? _bannerAd;
  BannerAd? _bannerAd1;


  @override
  void initState() {
  
    _bannerAd = BannerAd(
        adUnitId: 
          widget.nameOrigin == 'Home'
            ? HomeBannerAd
            : widget.nameOrigin == 'Reviews'
                ? ReviewsBannerAd
                : ProfileBannerAd, 
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {},
          onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        ))
      ..load();
    _bannerAd1 = BannerAd(
        adUnitId: 'ca-app-pub-2931129192084584/9988019084',
        size: AdSize.largeBanner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {},
          onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        ))
      ..load();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.nameOrigin == 'random'
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'ads',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
              _bannerAd1 == null
                  ? Container()
                  : Expanded(child: AdWidget(ad: _bannerAd1!)),
            ],
          )
        
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Center(
                  child: Text(
                        'ads',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
              _bannerAd == null
                  ? Container()
                  : Expanded(child: AdWidget(ad: _bannerAd!)),
            ],
          );
  }
}
