import 'package:audioplayers/audioplayers.dart';

class BgmManager {
  static final AudioPlayer _player = AudioPlayer();

  /// 미리 로드 (선택)
  static Future<void> preload(String fileName) async {
    await _player.setPlayerMode(PlayerMode.mediaPlayer);
    await _player.setSource(AssetSource('sounds/$fileName'));
  }

  /// 특정 배경음악 재생
  static Future<void> playBgm(String fileName) async {
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.play(AssetSource('sounds/$fileName'));
  }

  /// 정지
  static Future<void> stopBgm() async {
    await _player.stop();
  }
}

