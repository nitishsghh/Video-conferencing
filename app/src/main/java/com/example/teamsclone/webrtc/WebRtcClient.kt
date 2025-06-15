package com.example.teamsclone.webrtc

import android.content.Context
import android.media.AudioManager
import com.example.teamsclone.data.model.ConnectionQuality
import com.example.teamsclone.data.remote.response.IceServer
import org.webrtc.*
import timber.log.Timber
import java.nio.ByteBuffer
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class WebRtcClient @Inject constructor(
    private val context: Context
) {
    
    private val eglBase = EglBase.create()
    private var peerConnectionFactory: PeerConnectionFactory? = null
    private var audioSource: AudioSource? = null
    private var videoSource: VideoSource? = null
    private var localAudioTrack: AudioTrack? = null
    private var localVideoTrack: VideoTrack? = null
    private var videoCapturer: CameraVideoCapturer? = null
    
    private val peerConnections = mutableMapOf<String, PeerConnection>()
    private val dataChannels = mutableMapOf<String, DataChannel>()
    
    private var localStream: MediaStream? = null
    private var isFrontCamera = true
    private var isAudioEnabled = true
    private var isVideoEnabled = true
    
    private var listener: WebRtcClientListener? = null
    
    fun initialize() {
        initializePeerConnectionFactory()
        createMediaSources()
        createLocalStream()
    }
    
    private fun initializePeerConnectionFactory() {
        val options = PeerConnectionFactory.InitializationOptions.builder(context)
            .setEnableInternalTracer(true)
            .createInitializationOptions()
        
        PeerConnectionFactory.initialize(options)
        
        val videoEncoderFactory = DefaultVideoEncoderFactory(eglBase.eglBaseContext, true, true)
        val videoDecoderFactory = DefaultVideoDecoderFactory(eglBase.eglBaseContext)
        
        peerConnectionFactory = PeerConnectionFactory.builder()
            .setVideoEncoderFactory(videoEncoderFactory)
            .setVideoDecoderFactory(videoDecoderFactory)
            .setOptions(PeerConnectionFactory.Options())
            .createPeerConnectionFactory()
    }
    
    private fun createMediaSources() {
        peerConnectionFactory?.let { factory ->
            audioSource = factory.createAudioSource(MediaConstraints())
            videoSource = factory.createVideoSource(false)
            
            localAudioTrack = factory.createAudioTrack("audio_track", audioSource)
            localAudioTrack?.setEnabled(isAudioEnabled)
            
            localVideoTrack = factory.createVideoTrack("video_track", videoSource)
            localVideoTrack?.setEnabled(isVideoEnabled)
        }
    }
    
    private fun createLocalStream() {
        peerConnectionFactory?.let { factory ->
            localStream = factory.createLocalMediaStream("local_stream")
            localAudioTrack?.let { localStream?.addTrack(it) }
            localVideoTrack?.let { localStream?.addTrack(it) }
        }
    }
    
    fun startCamera(surfaceViewRenderer: SurfaceViewRenderer) {
        surfaceViewRenderer.init(eglBase.eglBaseContext, null)
        surfaceViewRenderer.setEnableHardwareScaler(true)
        surfaceViewRenderer.setMirror(isFrontCamera)
        
        videoCapturer = createCameraCapturer(isFrontCamera)
        
        videoCapturer?.let { capturer ->
            val surfaceTextureHelper = SurfaceTextureHelper.create("CaptureThread", eglBase.eglBaseContext)
            capturer.initialize(surfaceTextureHelper, context, videoSource?.capturerObserver)
            capturer.startCapture(1280, 720, 30)
            
            localVideoTrack?.addSink(surfaceViewRenderer)
        }
    }
    
    private fun createCameraCapturer(isFrontFacing: Boolean): CameraVideoCapturer? {
        val enumerator = Camera2Enumerator(context)
        val deviceNames = enumerator.deviceNames
        
        // First, try to find front facing camera
        if (isFrontFacing) {
            for (deviceName in deviceNames) {
                if (enumerator.isFrontFacing(deviceName)) {
                    val videoCapturer = enumerator.createCapturer(deviceName, null)
                    if (videoCapturer != null) {
                        return videoCapturer
                    }
                }
            }
        }
        
        // If front facing camera not found or not requested, try back facing camera
        for (deviceName in deviceNames) {
            if (!enumerator.isFrontFacing(deviceName)) {
                val videoCapturer = enumerator.createCapturer(deviceName, null)
                if (videoCapturer != null) {
                    return videoCapturer
                }
            }
        }
        
        return null
    }
    
    fun setListener(listener: WebRtcClientListener) {
        this.listener = listener
    }
    
    interface WebRtcClientListener {
        fun onIceCandidate(peerId: String, iceCandidate: IceCandidate)
        fun onOfferCreated(peerId: String, sessionDescription: SessionDescription)
        fun onAnswerCreated(peerId: String, sessionDescription: SessionDescription)
        fun onAddRemoteStream(peerId: String, mediaStream: MediaStream)
        fun onRemoveRemoteStream(peerId: String, mediaStream: MediaStream)
        fun onPeerConnected(peerId: String)
        fun onPeerDisconnected(peerId: String)
        fun onDataChannelMessage(peerId: String, message: String)
        fun onDataChannelCreated(peerId: String, dataChannel: DataChannel)
        fun onRenegotiationNeeded(peerId: String)
        fun onAudioToggled(enabled: Boolean)
        fun onVideoToggled(enabled: Boolean)
        fun onConnectionQualityChanged(peerId: String, quality: ConnectionQuality)
    }
}
