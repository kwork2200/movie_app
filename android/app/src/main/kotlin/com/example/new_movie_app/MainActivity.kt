package com.example.new_movie_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import com.google.android.gms.ads.nativead.NativeAdView
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.ImageView
import android.widget.Button
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.MediaView

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Register the Native Ad Factory
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            NativeAdFactoryExample(layoutInflater)
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        
        // Unregister the Native Ad Factory
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
    }
}

class NativeAdFactoryExample(private val layoutInflater: LayoutInflater) : 
    GoogleMobileAdsPlugin.NativeAdFactory {
    
    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = layoutInflater.inflate(
            R.layout.native_ad_layout, 
            null
        ) as NativeAdView
        
        // Populate the native ad view with the native ad assets
        val headlineView = nativeAdView.findViewById<TextView>(R.id.ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.ad_body)
        val callToActionView = nativeAdView.findViewById<Button>(R.id.ad_call_to_action)
        val iconView = nativeAdView.findViewById<ImageView>(R.id.ad_icon)
        val advertiserView = nativeAdView.findViewById<TextView>(R.id.ad_advertiser)
        val mediaView = nativeAdView.findViewById<MediaView>(R.id.ad_media)
        
        // Set the headline
        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView
        
        // Set the body
        if (nativeAd.body != null) {
            bodyView.text = nativeAd.body
            bodyView.visibility = android.view.View.VISIBLE
            nativeAdView.bodyView = bodyView
        } else {
            bodyView.visibility = android.view.View.GONE
        }
        
        // Set the call to action
        if (nativeAd.callToAction != null) {
            callToActionView.text = nativeAd.callToAction
            callToActionView.visibility = android.view.View.VISIBLE
            nativeAdView.callToActionView = callToActionView
        } else {
            callToActionView.visibility = android.view.View.GONE
        }
        
        // Set the icon
        if (nativeAd.icon != null) {
            iconView.setImageDrawable(nativeAd.icon?.drawable)
            iconView.visibility = android.view.View.VISIBLE
            nativeAdView.iconView = iconView
        } else {
            iconView.visibility = android.view.View.GONE
        }
        
        // Set the advertiser
        if (nativeAd.advertiser != null) {
            advertiserView.text = nativeAd.advertiser
            advertiserView.visibility = android.view.View.VISIBLE
            nativeAdView.advertiserView = advertiserView
        } else {
            advertiserView.visibility = android.view.View.GONE
        }
        
        // Set the media view
        if (nativeAd.mediaContent != null) {
            mediaView.setMediaContent(nativeAd.mediaContent)
            mediaView.visibility = android.view.View.VISIBLE
            nativeAdView.mediaView = mediaView
        } else {
            mediaView.visibility = android.view.View.GONE
        }
        
        // Set the native ad
        nativeAdView.setNativeAd(nativeAd)
        
        return nativeAdView
    }
}
