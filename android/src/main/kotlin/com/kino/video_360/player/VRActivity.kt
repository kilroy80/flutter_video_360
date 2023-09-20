package com.kino.video_360.player

import android.app.Activity
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.media3.common.C
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.common.util.Util
import androidx.media3.datasource.DataSource
import androidx.media3.datasource.DefaultDataSource
import androidx.media3.datasource.DefaultHttpDataSource
import androidx.media3.exoplayer.ExoPlayer
import androidx.media3.exoplayer.dash.DashMediaSource
import androidx.media3.exoplayer.dash.DefaultDashChunkSource
import androidx.media3.exoplayer.hls.HlsMediaSource
import androidx.media3.exoplayer.smoothstreaming.DefaultSsChunkSource
import androidx.media3.exoplayer.smoothstreaming.SsMediaSource
import androidx.media3.exoplayer.source.MediaSource
import androidx.media3.exoplayer.source.ProgressiveMediaSource
import androidx.media3.exoplayer.upstream.DefaultBandwidthMeter
import androidx.media3.exoplayer.video.spherical.SphericalGLSurfaceView
import androidx.media3.ui.PlayerView
import com.kino.video_360.R

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
        videoUrl = i.getStringExtra(VRActivity.EXTRA_URL)
            ?: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"

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
        val mediaItem = MediaItem.fromUri(uri)
        when (Util.inferContentType(uri)) {
            C.CONTENT_TYPE_DASH -> {
                val dashChunkSourceFactory = DefaultDashChunkSource.Factory(dataFactory)
                return DashMediaSource.Factory(dashChunkSourceFactory, null)
                        .createMediaSource(mediaItem)
            }
            C.CONTENT_TYPE_SS -> {
                val ssChunkSourceFactory = DefaultSsChunkSource.Factory(dataFactory)
                return SsMediaSource.Factory(ssChunkSourceFactory, null)
                        .createMediaSource(mediaItem)
            }
            C.CONTENT_TYPE_HLS -> {
                return HlsMediaSource.Factory(dataFactory).createMediaSource(mediaItem)
            }
            C.CONTENT_TYPE_OTHER -> {
                return ProgressiveMediaSource.Factory(dataFactory).createMediaSource(mediaItem)
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
            player?.prepare()
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