package com.kino.video_360.player

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
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.ProgressiveMediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource
import com.google.android.exoplayer2.ui.StyledPlayerView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter
import com.google.android.exoplayer2.upstream.DefaultDataSource
import com.google.android.exoplayer2.upstream.DefaultHttpDataSource
import com.google.android.exoplayer2.util.Util
import com.google.android.exoplayer2.video.spherical.SphericalGLSurfaceView
import com.kino.video_360.R

class VRActivity : Activity(), Player.Listener {

    private lateinit var vrPlayer: StyledPlayerView
    private var player: ExoPlayer? = null
    private var videoUrl = ""

    private lateinit var bandwidthMeter: DefaultBandwidthMeter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        setContentView(R.layout.activity_vr)
        window.decorView.setBackgroundColor(Color.BLACK)

        val i = intent
        videoUrl = i.getStringExtra(EXTRA_URL) ?: "https://multiplatform-f.akamaihd.net/i/multi/will/bunny/big_buck_bunny_,640x360_400,640x360_700,640x360_1000,950x540_1500,.f4v.csmil/master.m3u8"

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
        when (Util.inferContentType(url)) {
            C.TYPE_DASH -> {
                val dashChunkSourceFactory = DefaultDashChunkSource.Factory(dataFactory)
                return DashMediaSource.Factory(dashChunkSourceFactory, null)
                        .createMediaSource(mediaItem)
            }
            C.TYPE_SS -> {
                val ssChunkSourceFactory = DefaultSsChunkSource.Factory(dataFactory)
                return SsMediaSource.Factory(ssChunkSourceFactory, null)
                        .createMediaSource(mediaItem)
            }
            C.TYPE_HLS -> {
                return HlsMediaSource.Factory(dataFactory).createMediaSource(mediaItem)
            }
            C.TYPE_OTHER -> {
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