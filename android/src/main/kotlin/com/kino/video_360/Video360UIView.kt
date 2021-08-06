package com.kino.video_360

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.AttributeSet
import android.view.ViewGroup
import android.widget.FrameLayout
import com.google.android.exoplayer2.C
import com.google.android.exoplayer2.Player
import com.google.android.exoplayer2.SimpleExoPlayer
import com.google.android.exoplayer2.source.ExtractorMediaSource
import com.google.android.exoplayer2.source.MediaSource
import com.google.android.exoplayer2.source.dash.DashMediaSource
import com.google.android.exoplayer2.source.dash.DefaultDashChunkSource
import com.google.android.exoplayer2.source.hls.HlsMediaSource
import com.google.android.exoplayer2.source.smoothstreaming.DefaultSsChunkSource
import com.google.android.exoplayer2.source.smoothstreaming.SsMediaSource
import com.google.android.exoplayer2.ui.AspectRatioFrameLayout
import com.google.android.exoplayer2.ui.PlayerView
import com.google.android.exoplayer2.ui.spherical.SphericalGLSurfaceView
import com.google.android.exoplayer2.upstream.DataSource
import com.google.android.exoplayer2.upstream.DefaultBandwidthMeter
import com.google.android.exoplayer2.upstream.DefaultDataSourceFactory
import com.google.android.exoplayer2.upstream.DefaultHttpDataSourceFactory
import com.google.android.exoplayer2.util.Util

class Video360UIView : FrameLayout, Player.EventListener {

    private val TAG = Video360UIView::class.java.simpleName

    private lateinit var vrPlayer: PlayerView
    private var player: SimpleExoPlayer? = null
    private var videoUrl = ""
    private var isAutoPlay = true

    private lateinit var bandwidthMeter: DefaultBandwidthMeter

    constructor(context: Context) : super(context) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        init()
    }

    constructor(context: Context, attrs: AttributeSet, defStyleAttr: Int) : super(context, attrs, defStyleAttr) {
        init()
    }

    private fun init() {
        val layout = ViewGroup.LayoutParams(
            LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT
        )
        layoutParams = layout

        inflate(context, R.layout.view_vr, this);

        vrPlayer = findViewById(R.id.vr_player)
        (vrPlayer.videoSurfaceView as SphericalGLSurfaceView)
            .setDefaultStereoMode(C.STEREO_MODE_STEREO_MESH)
        vrPlayer.useController = false
//        vrPlayer.resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT

        bandwidthMeter = DefaultBandwidthMeter.Builder(context)
            .build()
    }

    private fun buildDataSourceFactory(context: Context, cookieValue: String): DataSource.Factory {
        val defaultHttpFactory = DefaultHttpDataSourceFactory(
            Util.getUserAgent(context, "kino_video_360"), bandwidthMeter
        )
        defaultHttpFactory.defaultRequestProperties.set("Cookie", cookieValue)

        return DefaultDataSourceFactory(context, bandwidthMeter, defaultHttpFactory)
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
                return ExtractorMediaSource.Factory(dataFactory).createMediaSource(uri)
            }
            else -> {
                return null
            }
        }
    }

    fun initializePlayer(url: String, autoPlay: Boolean) {
        player = SimpleExoPlayer.Builder(context).build()

        videoUrl = url
        isAutoPlay = autoPlay

        val mediaSource = buildMediaSource(videoUrl, buildDataSourceFactory(context, ""))
        mediaSource?.let {
            player?.prepare(it)
            player?.addListener(this)

            if (isAutoPlay) player?.playWhenReady = isAutoPlay

            vrPlayer.player = player
        }
    }

    fun releasePlayer() {
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

    fun onStart() {
        if (Build.VERSION.SDK_INT > 23) {
            initializePlayer(videoUrl, isAutoPlay)
        }
    }

    fun onResume() {
        if ((Build.VERSION.SDK_INT <= 23 || player == null)) {
            initializePlayer(videoUrl, isAutoPlay)
        }
    }

    fun onStop() {
        if (Build.VERSION.SDK_INT > 23) {
            releasePlayer()
        }
    }

    fun onPause() {
        if (Build.VERSION.SDK_INT <= 23) {
            releasePlayer()
        }
    }

    fun onDestroy() {
    }

    fun play() {
        if (player?.isPlaying == false) {
            player?.play()
        }
    }

    fun stop() {
        if (player?.isPlaying == true) {
            player?.pause()
        }
    }

    fun reset() {
        releasePlayer()
        initializePlayer(videoUrl, isAutoPlay)
    }

    fun seek(secondTime: Double) {
        val currentPos = player?.currentPosition
        val duration = player?.duration
        currentPos?.let { cur ->
            duration?.let { dur ->
                var seekTime = cur + (secondTime * 1000)
                if (seekTime < 0.0) seekTime = 0.0
                if (seekTime > dur) seekTime = dur.toDouble()
                player?.seekTo(seekTime.toLong())
            }
        }
    }

    fun getCurrentPosition(): Long {
        player?.currentPosition?.let {
            return it
        }
        return 0L
    }
}
