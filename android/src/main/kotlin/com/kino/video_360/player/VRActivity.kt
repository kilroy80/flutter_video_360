package com.kino.video_360

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.google.android.exoplayer2.util.Util
import com.google.android.exoplayer2.video.spherical.SphericalGLSurfaceView

class VRActivity : Activity(), Player.Listener {

    private lateinit var vrPlayer: PlayerView
    private var player: ExoPlayer? = null
    private var videoUrl = ""

    private lateinit var bandwidthMeter: DefaultBandwidthMeter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_vr)
        window.decorView.setBackgroundColor(Color.BLACK)

        val i = intent
        videoUrl = i.getStringExtra(VRActivity.EXTRA_URL) ?: ""

        vrPlayer = findViewById(R.id.vr_player)
        (vrPlayer.videoSurfaceView as SphericalGLSurfaceView)
                .setDefaultStereoMode(C.STEREO_MODE_STEREO_MESH)

        bandwidthMeter = DefaultBandwidthMeter.Builder(this)
                .build()
    }

    override fun onStart() {
        super.onStart()
        if (Build.VERSION.SDK_INT > 23) {
            initializePlayer()
        }
    }

    override fun onResume() {
        super.onResume()
        if ((Build.VERSION.SDK_INT <= 23 || player == null)) {
            initializePlayer()
        }
    }

    override fun onPause() {
        super.onPause()
        if (Build.VERSION.SDK_INT <= 23) {
            releasePlayer()
        }
    }

    override fun onStop() {
        super.onStop()
        if (Build.VERSION.SDK_INT > 23) {
            releasePlayer()
        }
    }

    private fun buildDataSourceFactory(context: Context, cookieValue: String): DataSource.Factory {
        val defaultHttpFactory = DefaultHttpDataSource.Factory()
        defaultHttpFactory.setUserAgent(Util.getUserAgent(context, "kino_video_360"))
        defaultHttpFactory.setDefaultRequestProperties(mapOf("Cookie" to cookieValue))
        defaultHttpFactory.setTransferListener(bandwidthMeter)
        return DefaultDataSource.Factory(context,defaultHttpFactory)
    }

    private fun buildMediaSource(url: String, dataFactory: DataSource.Factory): MediaSource? {
        val uri = Uri.parse(url)
        when (Util.inferContentType(url)) {
            C.TYPE_DASH -> {
                val dashChunkSourceFactory = DefaultDashChunkSource.Factory(dataFactory)
                return DashMediaSource.Factory(dashChunkSourceFactory, null)
                        .createMediaSource(uri)
            }
            C.TYPE_SS -> {
                val ssChunkSourceFactory = DefaultSsChunkSource.Factory(dataFactory)
                return SsMediaSource.Factory(ssChunkSourceFactory, null)
                        .createMediaSource(uri)
            }
            C.TYPE_HLS -> {
                return HlsMediaSource.Factory(dataFactory).createMediaSource(uri)
            }
            C.TYPE_OTHER -> {
                return ProgressiveMediaSource.Factory(dataFactory).createMediaSource(uri)
            }
            else -> {
                return null
            }
        }
    }

    private fun initializePlayer() {
        player = ExoPlayer.Builder(this).build()

        val uri = Uri.parse(videoUrl)
        val mediaSource = buildMediaSource(videoUrl, buildDataSourceFactory(this, ""))

        mediaSource?.let {
            player?.setMediaSource(it)
            player?.addListener(this)
            player?.playWhenReady = true

            vrPlayer.player = player
        }
    }

    private fun releasePlayer() {
        player?.release()
        player = null
    }

    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
        when (playbackState) {
            Player.STATE_BUFFERING -> {
            }
            Player.STATE_IDLE -> {
            }
            Player.STATE_READY -> {
            }
            Player.STATE_ENDED -> {
            }
        }
    }

    companion object {
        const val EXTRA_URL = "extra_url"
    }
}