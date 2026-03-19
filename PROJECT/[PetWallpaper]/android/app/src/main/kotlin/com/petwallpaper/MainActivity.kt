package com.petwallpaper.app

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.petwallpaper/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setLiveWallpaper" -> {
                    try {
                        val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER).apply {
                            putExtra(
                                WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                                ComponentName(packageName, "com.petwallpaper.app.PetWallpaperService")
                            )
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("WALLPAPER_ERROR", e.message, null)
                    }
                }
                "isLiveWallpaperSet" -> {
                    val wallpaperManager = WallpaperManager.getInstance(this)
                    val info = wallpaperManager.wallpaperInfo
                    val isSet = info?.packageName == packageName
                    result.success(isSet)
                }
                else -> result.notImplemented()
            }
        }
    }
}
