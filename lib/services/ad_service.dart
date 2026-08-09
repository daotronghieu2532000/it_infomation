import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static String get appId => 'ca-app-pub-6241798695005922~4069397666';

  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6241798695005922/6646704943'
      : 'ca-app-pub-6241798695005922/6646704943';

  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6241798695005922/1862452984'
      : 'ca-app-pub-6241798695005922/1862452984';

  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6241798695005922/9320969742'
      : 'ca-app-pub-6241798695005922/9320969742';

  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-6241798695005922/3993792305'
      : 'ca-app-pub-6241798695005922/3993792305';

  static InterstitialAd? _interstitialAd;
  static bool _isInterstitialAdLoading = false;
  static DateTime? _lastInterstitialShowTime;
  static int _interstitialRequestCount = 0;

  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;

  // Load Interstitial Ad
  static void loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdLoading = false;
          debugPrint('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  // Show Interstitial Ad
  static void showInterstitialAd(VoidCallback onAdClosed) {
    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed();
      return;
    }

    _interstitialRequestCount++;

    // Check frequency: show only on every 3rd copy request
    if (_interstitialRequestCount % 3 != 0) {
      debugPrint('Skipping interstitial ad: request count is $_interstitialRequestCount (not multiple of 3)');
      onAdClosed();
      return;
    }

    // Check cooldown: must be at least 3 minutes since the last shown ad
    final now = DateTime.now();
    if (_lastInterstitialShowTime != null &&
        now.difference(_lastInterstitialShowTime!) < const Duration(minutes: 3)) {
      debugPrint('Skipping interstitial ad: cooldown active. Last shown at $_lastInterstitialShowTime');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitialShowTime = DateTime.now();
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed();
      },
    );
    _interstitialAd!.show();
  }

  // Load Rewarded Ad
  static void loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          debugPrint('RewardedAd loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdLoading = false;
          debugPrint('RewardedAd failed to load: $error');
        },
      ),
    );
  }

  // Show Rewarded Ad
  static void showRewardedAd(OnUserEarnedRewardCallback onUserEarnedReward, VoidCallback onAdClosed) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdClosed();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed();
      },
    );
    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
  }
}
