package com.example.new_movie_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.googlemobileads.GoogleMobileAdsPlugin
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.content.Context
import android.view.View
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.ImageView
import android.widget.Button
import com.google.android.gms.ads.nativead.NativeAdView
import com.google.android.gms.ads.nativead.NativeAd
import com.google.android.gms.ads.nativead.MediaView
// Facebook Audience Network imports
import com.facebook.ads.AudienceNetworkAds
import com.facebook.ads.InterstitialAd
import com.facebook.ads.AdView
import com.facebook.ads.NativeAd as FbNativeAd
import com.facebook.ads.NativeBannerAd as FbNativeBannerAd
import com.facebook.ads.Ad as FbAd
import com.facebook.ads.AdError
import com.facebook.ads.InterstitialAdListener
import com.facebook.ads.AdListener
import com.facebook.ads.NativeAdListener
import com.facebook.ads.AdSize as FbAdSize

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.new_movie_app/facebook_ads"
    private var fbInterstitialAd: InterstitialAd? = null
    private var fbBannerAd: AdView? = null
    private var fbNativeAd: FbNativeAd? = null
    private var methodChannel: MethodChannel? = null
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Initialize Facebook Audience Network
        AudienceNetworkAds.initialize(this)
        
        // Add test device for Facebook Ads (from logs)
        com.facebook.ads.AdSettings.addTestDevice("6a456e1f-e23f-4a75-9e17-f8fa9481c4e4")
        android.util.Log.i("FacebookAds", "Test device added: 6a456e1f-e23f-4a75-9e17-f8fa9481c4e4")

        // Google Ads Native Ad Factories
        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "nativeAd",
            LargeNativeAdFactory(layoutInflater)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "smallNativeAd",
            SmallNativeAdFactory(layoutInflater)
        )

        GoogleMobileAdsPlugin.registerNativeAdFactory(
            flutterEngine,
            "listTile",
            ListTileNativeAdFactory(this)
        )
        
        // Register Facebook Banner Ad Platform View
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "fb_banner_ad_view",
            FbBannerAdViewFactory()
        )
        
        // Register Facebook Native Ad Platform View
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "fb_native_ad_view",
            FbNativeAdViewFactory()
        )
        
        // Facebook Ads Platform Channel
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "loadFbInterstitial" -> {
                    val placementId = call.argument<String>("placementId") ?: ""
                    loadFbInterstitialAd(placementId, result)
                }
                "showFbInterstitial" -> {
                    if (fbInterstitialAd != null && fbInterstitialAd!!.isAdLoaded) {
                        fbInterstitialAd!!.show()
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "destroyFbInterstitial" -> {
                    fbInterstitialAd?.destroy()
                    fbInterstitialAd = null
                    result.success(true)
                }
                "loadFbBanner" -> {
                    val placementId = call.argument<String>("placementId") ?: ""
                    loadFbBannerAd(placementId, result)
                }
                "destroyFbBanner" -> {
                    fbBannerAd?.destroy()
                    fbBannerAd = null
                    result.success(true)
                }
                "loadFbNative" -> {
                    val placementId = call.argument<String>("placementId") ?: ""
                    loadFbNativeAd(placementId, result)
                }
                "destroyFbNative" -> {
                    fbNativeAd?.destroy()
                    fbNativeAd = null
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun loadFbInterstitialAd(placementId: String, result: MethodChannel.Result) {
        fbInterstitialAd = InterstitialAd(this, placementId)
        fbInterstitialAd?.loadAd(
            fbInterstitialAd?.buildLoadAdConfig()
                ?.withAdListener(object : InterstitialAdListener {
                    override fun onInterstitialDisplayed(ad: FbAd) {
                        android.util.Log.i("FbInterstitialAd", "✅ Interstitial displayed")
                    }
                    override fun onInterstitialDismissed(ad: FbAd) {
                        android.util.Log.i("FbInterstitialAd", "✅ Interstitial dismissed")
                        // Notify Flutter that ad was dismissed
                        methodChannel?.invokeMethod("onInterstitialDismissed", null)
                    }
                    override fun onError(ad: FbAd, error: AdError) {
                        android.util.Log.e("FbInterstitialAd", "❌ Error: ${error.errorMessage}")
                        result.error("FB_AD_ERROR", error.errorMessage, null)
                    }
                    override fun onAdLoaded(ad: FbAd) {
                        android.util.Log.i("FbInterstitialAd", "✅ Ad loaded")
                        result.success(true)
                    }
                    override fun onAdClicked(ad: FbAd) {
                        android.util.Log.i("FbInterstitialAd", "👆 Ad clicked")
                    }
                    override fun onLoggingImpression(ad: FbAd) {
                        android.util.Log.i("FbInterstitialAd", "📊 Logging impression")
                    }
                })
                ?.build()
        )
    }
    
    private fun loadFbBannerAd(placementId: String, result: MethodChannel.Result) {
        fbBannerAd = AdView(this, placementId, FbAdSize.BANNER_HEIGHT_50)
        fbBannerAd?.loadAd(
            fbBannerAd?.buildLoadAdConfig()
                ?.withAdListener(object : AdListener {
                    override fun onError(ad: FbAd, error: AdError) {
                        result.error("FB_BANNER_ERROR", error.errorMessage, null)
                    }
                    override fun onAdLoaded(ad: FbAd) {
                        result.success(true)
                    }
                    override fun onAdClicked(ad: FbAd) {}
                    override fun onLoggingImpression(ad: FbAd) {}
                })
                ?.build()
        )
    }
    
    private fun loadFbNativeAd(placementId: String, result: MethodChannel.Result) {
        fbNativeAd = FbNativeAd(this, placementId)
        fbNativeAd?.loadAd(
            fbNativeAd?.buildLoadAdConfig()
                ?.withAdListener(object : NativeAdListener {
                    override fun onMediaDownloaded(ad: FbAd) {}
                    override fun onError(ad: FbAd, error: AdError) {
                        result.error("FB_NATIVE_ERROR", error.errorMessage, null)
                    }
                    override fun onAdLoaded(ad: FbAd) {
                        // Return native ad data as a map
                        val nativeAd = ad as FbNativeAd
                        val adData = mapOf(
                            "headline" to (nativeAd.advertiserName ?: ""),
                            "body" to (nativeAd.adBodyText ?: ""),
                            "callToAction" to (nativeAd.adCallToAction ?: ""),
                            "iconUrl" to (nativeAd.adCoverImage?.url ?: ""),
                            "loaded" to true
                        )
                        result.success(adData)
                    }
                    override fun onAdClicked(ad: FbAd) {}
                    override fun onLoggingImpression(ad: FbAd) {}
                })
                ?.build()
        )
    }

    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        super.cleanUpFlutterEngine(flutterEngine)
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "nativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "smallNativeAd")
        GoogleMobileAdsPlugin.unregisterNativeAdFactory(flutterEngine, "listTile")
        fbInterstitialAd?.destroy()
        fbInterstitialAd = null
        fbBannerAd?.destroy()
        fbBannerAd = null
        fbNativeAd?.destroy()
        fbNativeAd = null
    }
}

// ─────────────────────────────────────────────────────────────────
// Facebook Banner Ad Platform View Factory
// ─────────────────────────────────────────────────────────────────
class FbBannerAdViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any>
        val placementId = params?.get("placementId") as? String 
            ?: "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID"
        return FbBannerAdView(context, placementId)
    }
}

class FbBannerAdView(context: Context, placementId: String) : PlatformView {
    private val adView: AdView = AdView(context, placementId, FbAdSize.BANNER_HEIGHT_50)
    
    init {
        adView.loadAd(
            adView.buildLoadAdConfig()
                .withAdListener(object : AdListener {
                    override fun onError(ad: FbAd, error: AdError) {
                        android.util.Log.e("FbBannerAd", "Error: ${error.errorMessage}")
                    }
                    override fun onAdLoaded(ad: FbAd) {
                        android.util.Log.i("FbBannerAd", "Banner ad loaded")
                    }
                    override fun onAdClicked(ad: FbAd) {}
                    override fun onLoggingImpression(ad: FbAd) {}
                })
                .build()
        )
    }
    
    override fun getView(): View = adView
    
    override fun dispose() {
        adView.destroy()
    }
}

// ─────────────────────────────────────────────────────────────────
// Facebook Native Ad Platform View Factory
// ─────────────────────────────────────────────────────────────────
class FbNativeAdViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any>
        val placementId = params?.get("placementId") as? String 
            ?: "IMG_16_9_APP_INSTALL#YOUR_PLACEMENT_ID"
        return FbNativeAdView(context, placementId)
    }
}

class FbNativeAdView(private val context: Context, placementId: String) : PlatformView {
    private val nativeAd: FbNativeBannerAd = FbNativeBannerAd(context, placementId)
    private val containerLayout: android.widget.FrameLayout = android.widget.FrameLayout(context)
    private var isAdLoaded = false
    
    init {
        // Show initial loading state
        showLoadingState()
        
        nativeAd.loadAd(
            nativeAd.buildLoadAdConfig()
                .withAdListener(object : NativeAdListener {
                    override fun onMediaDownloaded(ad: FbAd) {
                        android.util.Log.d("FbNativeAd", "Media downloaded")
                    }
                    override fun onError(ad: FbAd, error: AdError) {
                        android.util.Log.e("FbNativeAd", "❌ Error loading ad: ${error.errorMessage}")
                        showErrorState(error.errorMessage)
                    }
                    override fun onAdLoaded(ad: FbAd) {
                        android.util.Log.i("FbNativeAd", "✅ Native ad loaded successfully")
                        isAdLoaded = true
                        inflateAdView()
                    }
                    override fun onAdClicked(ad: FbAd) {
                        android.util.Log.d("FbNativeAd", "Ad clicked")
                    }
                    override fun onLoggingImpression(ad: FbAd) {
                        android.util.Log.d("FbNativeAd", "Logging impression")
                    }
                })
                .build()
        )
    }
    
    private fun showLoadingState() {
        containerLayout.removeAllViews()
        val loadingView = TextView(context).apply {
            text = "Loading ad..."
            textSize = 14f
            setTextColor(android.graphics.Color.GRAY)
            gravity = android.view.Gravity.CENTER
            setPadding(16, 32, 16, 32)
        }
        containerLayout.addView(loadingView)
    }
    
    private fun showErrorState(errorMessage: String) {
        containerLayout.removeAllViews()
        val errorView = TextView(context).apply {
            text = "Ad failed to load: $errorMessage"
            textSize = 12f
            setTextColor(android.graphics.Color.RED)
            gravity = android.view.Gravity.CENTER
            setPadding(16, 32, 16, 32)
        }
        containerLayout.addView(errorView)
    }
    
    private fun inflateAdView() {
        // Remove loading state
        containerLayout.removeAllViews()
        
        // Create a simple native ad layout programmatically
        val linearLayout = android.widget.LinearLayout(context).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setPadding(16, 16, 16, 16)
            setBackgroundColor(android.graphics.Color.parseColor("#1A1A1A"))
            layoutParams = android.widget.FrameLayout.LayoutParams(
                android.widget.FrameLayout.LayoutParams.MATCH_PARENT,
                android.widget.FrameLayout.LayoutParams.WRAP_CONTENT
            )
        }
        
        // Sponsored label
        val sponsoredText = TextView(context).apply {
            text = "Sponsored"
            textSize = 10f
            setTextColor(android.graphics.Color.GRAY)
            setPadding(8, 4, 8, 4)
        }
        linearLayout.addView(sponsoredText)
        
        // Icon ImageView (required for registerViewForInteraction)
        val iconView = ImageView(context).apply {
            layoutParams = android.widget.LinearLayout.LayoutParams(80, 80).apply {
                setMargins(0, 8, 0, 8)
            }
            scaleType = ImageView.ScaleType.CENTER_CROP
            setBackgroundColor(android.graphics.Color.GRAY)
        }
        linearLayout.addView(iconView)
        
        // Title
        val titleText = TextView(context).apply {
            text = nativeAd.advertiserName ?: "Ad"
            textSize = 16f
            setTextColor(android.graphics.Color.WHITE)
            setPadding(0, 8, 0, 8)
            setTypeface(null, android.graphics.Typeface.BOLD)
        }
        linearLayout.addView(titleText)
        
        // Body
        val bodyText = TextView(context).apply {
            text = nativeAd.adBodyText ?: ""
            textSize = 14f
            setTextColor(android.graphics.Color.LTGRAY)
            setPadding(0, 4, 0, 8)
            maxLines = 3
        }
        linearLayout.addView(bodyText)
        
        // CTA Button
        val ctaButton = Button(context).apply {
            text = nativeAd.adCallToAction ?: "Learn More"
            textSize = 14f
            setTextColor(android.graphics.Color.WHITE)
            setBackgroundColor(android.graphics.Color.BLUE)
        }
        linearLayout.addView(ctaButton)
        
        // Register the view - NativeBannerAd requires View + ImageView
        nativeAd.registerViewForInteraction(linearLayout, iconView)
        
        // Add the ad layout to container
        containerLayout.addView(linearLayout)
        android.util.Log.i("FbNativeAd", "✅ Ad view inflated and displayed")
    }
    
    override fun getView(): View {
        return containerLayout
    }
    
    override fun dispose() {
        nativeAd.unregisterView()
        nativeAd.destroy()
    }
}

// ─────────────────────────────────────────────────────────────────
// ListTile native ad factory (customizable media + icon + headline + body + CTA)
// ─────────────────────────────────────────────────────────────────
class ListTileNativeAdFactory(private val context: Context) :
    GoogleMobileAdsPlugin.NativeAdFactory {

    override fun createNativeAd(
        nativeAd: NativeAd,
        customOptions: MutableMap<String, Any>?
    ): NativeAdView {
        val nativeAdView = LayoutInflater.from(context).inflate(
            R.layout.list_tile_native_ad,
            null
        ) as NativeAdView

        val attributionViewSmall = nativeAdView.findViewById<TextView>(R.id.native_ad_attribution_small)
        val iconView = nativeAdView.findViewById<ImageView>(R.id.native_ad_icon)
        val mediaView = nativeAdView.findViewById<MediaView>(R.id.native_ad_media)
        val headlineView = nativeAdView.findViewById<TextView>(R.id.native_ad_headline)
        val bodyView = nativeAdView.findViewById<TextView>(R.id.native_ad_body)
        val callToActionButton = nativeAdView.findViewById<Button>(R.id.native_ad_btn)

        // Handle icon
        val icon = nativeAd.icon
        if (icon != null) {
            attributionViewSmall.visibility = View.VISIBLE
            iconView.setImageDrawable(icon.drawable)
        } else {
            attributionViewSmall.visibility = View.INVISIBLE
        }
        nativeAdView.iconView = iconView

        // Handle media
        if (nativeAd.mediaContent != null) {
            mediaView.setMediaContent(nativeAd.mediaContent)
            mediaView.visibility = View.VISIBLE
            nativeAdView.mediaView = mediaView
        } else {
            mediaView.visibility = View.GONE
        }

        // Handle headline
        headlineView.text = nativeAd.headline
        nativeAdView.headlineView = headlineView

        // Handle body
        bodyView.text = nativeAd.body
        bodyView.visibility = if (nativeAd.body != null) View.VISIBLE else View.INVISIBLE
        nativeAdView.bodyView = bodyView

        // Handle call to action
        if (nativeAd.callToAction == null) {
            callToActionButton.visibility = View.INVISIBLE
        } else {
            callToActionButton.visibility = View.VISIBLE
            callToActionButton.text = nativeAd.callToAction
        }
        nativeAdView.callToActionView = callToActionButton

        nativeAdView.setNativeAd(nativeAd)
        return nativeAdView
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
