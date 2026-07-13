import 'dart:developer';
import 'dart:io';

class AdHelper {

  static Map<String, dynamic> datamap = {
    "admobid2": "ca-app-pub-3940256099942544/9257395921",
    "admobnative": "ca-app-pub-3940256099942544/2247696110",
    "admobfull": "ca-app-pub-3940256099942544/1033173712",
    "admobfull1": "ca-app-pub-3940256099942544/1033173712",
    "admobfull2": "ca-app-pub-3940256099942544/1033173712",
    "rewardedint": "ca-app-pub-3940256099942544/5224354917",
    "admobid": "ca-app-pub-3940256099942544/6300978111",
  };

  static String get appOpenUnitId {
    if (Platform.isAndroid) {
      return datamap["admobid2"];
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_BANNER_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }


  static String get interstitialAdUnitId1 {
    if (Platform.isAndroid) {
      log(datamap["admobfull"]);
      return datamap["admobfull"];
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId2 {
    if (Platform.isAndroid) {
      return datamap["admobfull1"];
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get interstitialAdUnitId3 {
    if (Platform.isAndroid) {
      return datamap["admobfull2"];
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return datamap["rewardedint"];
    } else if (Platform.isIOS) {
      return '<YOUR_IOS_INTERSTITIAL_AD_UNIT_ID>';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

}
