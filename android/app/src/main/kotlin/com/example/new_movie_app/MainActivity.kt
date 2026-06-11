package com.example.new_movie_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.NativeAdView
import android.view.LayoutInflater
import android.view.View
import android.widget.TextView
import android.widget.ImageView
import android.widget.Button
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.MediaView

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Large native ad (with media view) – used by NativeAdWidget(size: NativeAdSize.large)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAd",
            LargeNativeAdFactory(layoutInflater)
        )

        // Small native ad (compact row) – used by NativeAdWidget(size: NativeAdSize.small)
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "smallNativeAd",
            SmallNativeAdFactory(layoutInflater)
        )

        // Legacy factory id – kept for CustomHeightNativeAd / any existing usage
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            LargeNativeAdFactory(layoutInflater)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallNativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }
}

// ─────────────────────────────────────────────────────────────────
// Large native ad factory  (media + headline + body + CTA + icon)
// ─────────────────────────────────────────────────────────────────
class LargeNativeAdFactory(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = layoutInflater.inflate(
            R.layout.native_ad_layout,
            null
        ) as NativeAdView

        val headlineView    = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView        = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val callToActionView= nativeAdView.findViewById<Button>(R.id.ad_call_to_action)
        val iconView        = nativeAdView.findViewById<ImageView>(R.id.ad_icon)
        val advertiserView  = nativeAdView.findViewById<TextView>(R.id.ad_advertiser)
        val mediaView       = nativeAdView.findViewById<MediaView>(R.id.ad_media)

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
            nativeAdView.bodyView = bodyView
        } else {
            bodyView.visibility = View.GONE
        }

        if (nativeAd.callToAction != null) {
            callToActionView.text = nativeAd.callToAction
            callToActionView.visibility = View.VISIBLE
            nativeAdView.callToActionView = callToActionView
        } else {
            callToActionView.visibility = View.GONE
        }

        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = View.VISIBLE
            nativeAdView.iconView = iconView
        } else {
            iconView.visibility = View.GONE
        }

        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = View.VISIBLE
            nativeAdView.advertiserView = advertiserView
        } else {
            advertiserView.visibility = View.GONE
        }

        if (nativeAd.mediaContent != null) {
            mediaView.setMediaContent(nativeAd.mediaContent)
            mediaView.visibility = View.VISIBLE
            nativeAdView.mediaView = mediaView
        } else {
            mediaView.visibility = View.GONE
        }

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}

// ─────────────────────────────────────────────────────────────────
// Small native ad factory  (icon + headline + body + CTA – no media)
// ─────────────────────────────────────────────────────────────────
class SmallNativeAdFactory(private val layoutInflater: LayoutInflater) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = layoutInflater.inflate(
            R.layout.native_ad_small_layout,
            null
        ) as NativeAdView

        val headlineView     = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView         = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val callToActionView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)
        val iconView         = nativeAdView.findViewById<ImageView>(R.id.ad_icon)

        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = View.VISIBLE
            nativeAdView.bodyView = bodyView
        } else {
            bodyView.visibility = View.GONE
        }

        if (nativeAd.callToAction != null) {
            callToActionView.text = nativeAd.callToAction
            callToActionView.visibility = View.VISIBLE
            nativeAdView.callToActionView = callToActionView
        } else {
            callToActionView.visibility = View.GONE
        }

        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = View.VISIBLE
            nativeAdView.iconView = iconView
        } else {
            iconView.visibility = View.GONE
        }

        // Small layout has no mediaView – no need to set it
        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
    }
}
