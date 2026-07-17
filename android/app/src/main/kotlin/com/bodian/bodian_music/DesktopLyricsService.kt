package com.bodian.bodian_music

import android.app.Service
import android.content.Intent
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.LayoutInflater
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.TextView
import kotlin.math.abs

/**
 * 桌面歌词悬浮窗服务
 */
class DesktopLyricsService : Service() {
    private var windowManager: WindowManager? = null
    private var lyricsView: View? = null
    private var lyricsTextView: TextView? = null
    
    private var layoutParams: WindowManager.LayoutParams? = null
    private var initialX = 0
    private var initialY = 0
    private var touchX = 0f
    private var touchY = 0f
    private var isDragging = false
    
    private var isShowing = false
    private var lyricText = ""
    private var nextLyricText = ""
    
    companion object {
        const val ACTION_SHOW = "com.bodian.music.action.SHOW_LYRICS"
        const val ACTION_HIDE = "com.bodian.music.action.HIDE_LYRICS"
        const val ACTION_UPDATE = "com.bodian.music.action.UPDATE_LYRIC"
        const val EXTRA_LYRIC = "lyric"
        const val EXTRA_NEXT_LYRIC = "next_lyric"
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_SHOW -> showLyrics()
            ACTION_HIDE -> hideLyrics()
            ACTION_UPDATE -> {
                lyricText = intent.getStringExtra(EXTRA_LYRIC) ?: ""
                nextLyricText = intent.getStringExtra(EXTRA_NEXT_LYRIC) ?: ""
                updateLyricText()
            }
        }
        return START_STICKY
    }

    private fun showLyrics() {
        if (isShowing) return
        
        val layoutInflater = getSystemService(LAYOUT_INFLATER_SERVICE) as LayoutInflater
        lyricsView = layoutInflater.inflate(R.layout.desktop_lyrics, null)
        lyricsTextView = lyricsView?.findViewById(R.id.lyrics_text)
        
        val type = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }
        
        layoutParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            type,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                    WindowManager.LayoutParams.FLAG_LAYOUT_IN_SCREEN or
                    WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS,
            PixelFormat.TRANSLUCENT
        )
        
        layoutParams?.gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
        layoutParams?.x = 0
        layoutParams?.y = 100
        
        lyricsView?.setOnTouchListener { _, event ->
            when (event.action) {
                MotionEvent.ACTION_DOWN -> {
                    initialX = layoutParams?.x ?: 0
                    initialY = layoutParams?.y ?: 0
                    touchX = event.rawX
                    touchY = event.rawY
                    isDragging = false
                    true
                }
                MotionEvent.ACTION_MOVE -> {
                    val dx = (event.rawX - touchX).toInt()
                    val dy = (event.rawY - touchY).toInt()
                    
                    if (abs(dx) > 10 || abs(dy) > 10) {
                        isDragging = true
                    }
                    
                    if (isDragging) {
                        layoutParams?.x = initialX + dx
                        layoutParams?.y = initialY + dy
                        windowManager?.updateViewLayout(lyricsView, layoutParams)
                    }
                    true
                }
                MotionEvent.ACTION_UP -> {
                    if (!isDragging) {
                        lyricsView?.performClick()
                    }
                    true
                }
                else -> false
            }
        }
        
        lyricsView?.setOnClickListener {
            // 点击歌词回到应用
            val launchIntent = packageManager.getLaunchIntentForPackage(packageName)
            launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(launchIntent)
        }
        
        try {
            windowManager?.addView(lyricsView, layoutParams)
            isShowing = true
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun hideLyrics() {
        if (isShowing && lyricsView != null) {
            try {
                windowManager?.removeView(lyricsView)
                isShowing = false
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun updateLyricText() {
        lyricsTextView?.text = lyricText
    }

    override fun onDestroy() {
        hideLyrics()
        super.onDestroy()
    }
}
