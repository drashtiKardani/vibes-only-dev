abstract class VibeStudioConfig {
  VibeStudioConfig._();

  static const initialDuration = 10.0; // seconds
  static const durationChangeStep = 10.0; // seconds

  static const initialIntensity = 50; // in scale of 0~99

  static const heightOfOneSecondBar = 65.0 / VibeStudioConfig.durationChangeStep; // height of 10s bar is 65
  static const vibeBarTimeBoxDim = 51.0;
}
