import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

abstract class SoundService {
  static Future<void> playSuccess() async {
    try {
      await _play(_makeTone(880, 0.22, volume: 0.45));
    } catch (_) {}
  }

  static Future<void> playFail() async {
    try {
      await _play(_makeTone(220, 0.30, volume: 0.35));
    } catch (_) {}
  }

  static Future<void> _play(Uint8List wav) async {
    final player = AudioPlayer();
    await player.play(BytesSource(wav));
    player.onPlayerComplete.first.then((_) => player.dispose());
  }

  // Generates a mono 44100Hz 16-bit PCM WAV with exponential decay envelope.
  static Uint8List _makeTone(double frequency, double durationSec, {double volume = 0.5}) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationSec).round();
    final data = ByteData(44 + numSamples * 2);

    _write4(data, 0, 'RIFF');
    data.setUint32(4, 36 + numSamples * 2, Endian.little);
    _write4(data, 8, 'WAVE');
    _write4(data, 12, 'fmt ');
    data.setUint32(16, 16, Endian.little);
    data.setUint16(20, 1, Endian.little);           // PCM
    data.setUint16(22, 1, Endian.little);           // mono
    data.setUint32(24, sampleRate, Endian.little);
    data.setUint32(28, sampleRate * 2, Endian.little);
    data.setUint16(32, 2, Endian.little);
    data.setUint16(34, 16, Endian.little);
    _write4(data, 36, 'data');
    data.setUint32(40, numSamples * 2, Endian.little);

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      final envelope = exp(-5.0 * t / durationSec);
      final raw = sin(2 * pi * frequency * t) * envelope * volume * 32767;
      data.setInt16(44 + i * 2, raw.round().clamp(-32768, 32767), Endian.little);
    }

    return data.buffer.asUint8List();
  }

  static void _write4(ByteData data, int offset, String s) {
    for (var i = 0; i < 4; i++) {
      data.setUint8(offset + i, s.codeUnitAt(i));
    }
  }
}
