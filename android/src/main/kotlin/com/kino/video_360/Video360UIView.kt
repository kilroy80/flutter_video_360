package com.kino.video_360

import android.content.Context
import android.net.Uri
import android.os.Build
import android.util.AttributeSet
import android.view.ViewGroup
import android.widget.FrameLayout
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
import io.flutter.view.TextureRegistry


class Video360UIView : FrameLayout, Player.Listener {

    private val TAG = Video360UIView::class.java.simpleName

    private lateinit var vrPlayer: StyledPlayerView
    private var player: ExoPlayer? = null
    private var videoUrl = ""
    private var isAutoPlay = true
    private var isRepeat = false

    private lateinit var bandwidthMeter: DefaultBandwidthMeter

    private var textureRegistry: TextureRegistry? = null

    constructor(context: Context, textureRegistry: TextureRegistry) : super(context) {
        this.textureRegistry = textureRegistry
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

        inflate(context, R.layout.view_vr, this)


        vrPlayer = findViewById(R.id.vr_player)



        (vrPlayer.videoSurfaceView as SphericalGLSurfaceView)
            .setDefaultStereoMode(C.STEREO_MODE_STEREO_MESH)
        vrPlayer.useController = false
//        vrPlayer.resizeMode = AspectRatioFrameLayout.RESIZE_MODE_FIT

        bandwidthMeter = DefaultBandwidthMeter.Builder(context)
            .build()
    }

    private fun buildDataSourceFactory(context: Context, cookieValue: String): DataSource.Factory {
        val defaultHttpFactory = DefaultHttpDataSource.Factory()
        defaultHttpFactory.setUserAgent(Util.getUserAgent(context, "kino_video_360"))
        defaultHttpFactory.setTransferListener(bandwidthMeter)
        defaultHttpFactory.setDefaultRequestProperties(mapOf("Cookie" to cookieValue))

        return DefaultDataSource.Factory(context, defaultHttpFactory)
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

    fun setupData(url: String, autoPlay: Boolean, repeat: Boolean) {
        videoUrl = url
        isAutoPlay = autoPlay
        isRepeat = repeat
    }

    fun initializePlayer(url: String, autoPlay: Boolean, repeat: Boolean) {
        player = ExoPlayer.Builder(context).build()

        videoUrl = url
        isAutoPlay = autoPlay
        isRepeat = repeat

        val mediaSource = buildMediaSource(videoUrl, buildDataSourceFactory(context, ""))
        mediaSource?.let {
            player?.setMediaSource(it)
            player?.prepare()
            player?.addListener(this)

            player?.playWhenReady = isAutoPlay
            if (isRepeat) {
                player?.repeatMode = Player.REPEAT_MODE_ALL
            } else {
                player?.repeatMode = Player.REPEAT_MODE_OFF
            }

            vrPlayer.player = player
        }
        vrPlayer.onResume()
    }

    fun releasePlayer() {
        if (player != null) {
            player?.release()
            player = null
        }
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
            initializePlayer(videoUrl, isAutoPlay, isRepeat)
        }
    }

    fun onResume() {
        if ((Build.VERSION.SDK_INT <= 23 || player == null)) {
            initializePlayer(videoUrl, isAutoPlay, isRepeat)
        }
    }

    fun onStop() {
        if (Build.VERSION.SDK_INT > 23) {
            vrPlayer.onPause()
            releasePlayer()
        }
    }

    fun onPause() {
        if (Build.VERSION.SDK_INT <= 23) {
            vrPlayer.onPause()
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
        initializePlayer(videoUrl, isAutoPlay, isRepeat)
    }

    fun seekTo(millisecond: Double) {
        val currentPos = player?.currentPosition
        val duration = player?.duration
        currentPos?.let { cur ->
            duration?.let { dur ->
                var seekTime = cur + millisecond
                if (seekTime < 0.0) seekTime = 0.0
                if (seekTime > dur) seekTime = dur.toDouble()
                player?.seekTo(seekTime.toLong())
            }
        }
    }

    fun jumpTo(millisecond: Double) {
        val duration = player?.duration
        duration?.let { dur ->
            var seekTime = millisecond
            if (seekTime < 0.0) seekTime = 0.0
            if (seekTime > dur) seekTime = dur.toDouble()
            player?.seekTo(seekTime.toLong())
        }
    }

    fun getPlaying(): Boolean {
        return player?.isPlaying == true
    }

    fun getCurrentPosition(): Long {
        player?.currentPosition?.let {
            return it
        }
        return 0L
    }

    fun getDuration(): Long {
        player?.duration?.let {
            return it
        }
        return 0L
    }
}