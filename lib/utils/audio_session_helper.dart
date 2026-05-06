import 'package:audio_session/audio_session.dart';

/// Configures the OS audio session for muted video playback.
///
/// Call this immediately before [VideoPlayerController.initialize()] for any
/// video that plays silently (volume = 0). This prevents the video player's
/// native layer from interrupting background audio apps (Spotify, etc.).
///
/// On iOS: uses AVAudioSessionCategory.ambient so the session mixes with
/// other audio and does not interrupt background playback.
///
/// On Android: uses gainTransientMayDuck so background audio is ducked
/// (volume lowered) rather than paused. Combined with setVolume(0.0) on the
/// controller, the net effect is silence with minimal disruption.
Future<void> configureAmbientAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.ambient,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    avAudioSessionRouteSharingPolicy:
        AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.movie,
      flags: AndroidAudioFlags.none,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidWillPauseWhenDucked: false,
  ));
}

/// Configures the OS audio session for intentional audio playback.
///
/// Call this immediately before [VideoPlayerController.initialize()] for any
/// video that plays with sound (e.g. brand screen video). This requests full
/// audio focus so the video audio is heard clearly.
Future<void> configureMusicAudioSession() async {
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration.music());
}
