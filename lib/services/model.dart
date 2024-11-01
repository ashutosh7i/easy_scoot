import 'package:camera/camera.dart';

// card formats
enum OverlayFormat {
  aadharCard,
}

enum OverlayOrientation { landscape, portrait }

CameraDescription? cameraDescription;

abstract class OverlayModel {
  ///ratio between maximum allowable lengths of shortest and longest sides
  double? ratio;

  ///ratio between maximum allowable radius and maximum allowable length of shortest side
  double? cornerRadius;

  ///natural orientation for overlay
  OverlayOrientation? orientation;
}

class CardOverlay implements OverlayModel {
  CardOverlay(
      {this.ratio = 1.5,
      this.cornerRadius = 0.66,
      this.orientation = OverlayOrientation.landscape});

  @override
  double? ratio;
  @override
  double? cornerRadius;
  @override
  OverlayOrientation? orientation;

  static byFormat(OverlayFormat format) {
    switch (format) {
      case (OverlayFormat.aadharCard):
        return CardOverlay(ratio: 1.3, cornerRadius: 0.064);
    }
  }
}
