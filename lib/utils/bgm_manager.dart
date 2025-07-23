import 'package:audioplayers/audioplayers.dart';

class BgmManager {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> preload(String fileName) async {
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setSource(AssetSource('sounds/bgm2.wav'));
  }


  /// 특정 배경음악 재생
  static Future<void> playBgm(String fileName) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/bgm2.wav'));
  }

  /// 정지
  static Future<void> stopBgm() async {
    await _player.stop();
  }
}
