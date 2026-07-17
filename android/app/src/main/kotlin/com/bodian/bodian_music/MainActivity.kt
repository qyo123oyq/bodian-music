package com.bodian.bodian_music

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.audiofx.Equalizer
import android.media.audiofx.BassBoost
import android.media.session.MediaSession
import android.os.Build

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.bodian.music/audio_effects"
    private val DESKTOP_LYRICS_CHANNEL = "com.bodian.music/desktop_lyrics"
    
    private var equalizer: Equalizer? = null
    private var bassBoost: BassBoost? = null
    private var mediaSession: MediaSession? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 音频特效通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "setEqualizerEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setEqualizerEnabled(enabled)
                    result.success(null)
                }
                "setEqualizerBandLevel" -> {
                    val band = call.argument<Int>("band") ?: 0
                    val level = call.argument<Int>("level") ?: 0
                    setEqualizerBandLevel(band, level)
                    result.success(null)
                }
                "setBassBoostEnabled" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    setBassBoostEnabled(enabled)
                    result.success(null)
                }
                "setBassBoostStrength" -> {
                    val strength = call.argument<Int>("strength") ?: 0
                    setBassBoostStrength(strength)
                    result.success(null)
                }
                "getEqualizerBandLevels" -> {
                    result.success(getEqualizerBandLevels())
                }
                else -> result.notImplemented()
            }
        }
        
        // 桌面歌词通道
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DESKTOP_LYRICS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "showLyrics" -> {
                    result.success(null)
                }
                "hideLyrics" -> {
                    result.success(null)
                }
                "updateLyric" -> {
                    val lyric = call.argument<String>("lyric") ?: ""
                    result.success(null)
                }
                "checkPermission" -> {
                    result.success(true)
                }
                "requestPermission" -> {
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setEqualizerEnabled(enabled: Boolean) {
        try {
            if (enabled) {
                if (equalizer == null) {
                    equalizer = Equalizer(0, 0)
                }
                equalizer?.enabled = true
            } else {
                equalizer?.enabled = false
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setEqualizerBandLevel(band: Int, level: Int) {
        try {
            equalizer?.setBandLevel(band.toShort(), level.toShort())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setBassBoostEnabled(enabled: Boolean) {
        try {
            if (enabled) {
                if (bassBoost == null) {
                    bassBoost = BassBoost(0, 0)
                }
                bassBoost?.enabled = true
            } else {
                bassBoost?.enabled = false
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun setBassBoostStrength(strength: Int) {
        try {
            bassBoost?.setStrength(strength.toShort())
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun getEqualizerBandLevels(): List<Int> {
        return try {
            val numBands = equalizer?.numberOfBands?.toInt() ?: 5
            List(numBands) { 0 }
        } catch (e: Exception) {
            List(5) { 0 }
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        equalizer?.release()
        bassBoost?.release()
        mediaSession?.release()
    }
}
