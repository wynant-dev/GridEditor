import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';

import 'viewport_camera.dart';

/// Owns viewport camera state and pointer-driven pan/zoom interaction.
class ViewportController extends ChangeNotifier {
  ViewportController({ViewportCamera camera = const ViewportCamera()})
      : _camera = camera;

  ViewportCamera _camera;
  int? _panPointerId;
  Offset? _lastPanPosition;

  ViewportCamera get camera => _camera;

  void zoomBy(double factor, {Offset? focalPoint}) {
    _camera = focalPoint == null
        ? _camera.zoomBy(factor)
        : _camera.zoomByAt(factor, focalPoint);
    notifyListeners();
  }

  void panBy(Offset delta) {
    _camera = _camera.panBy(delta);
    notifyListeners();
  }

  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final factor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      zoomBy(factor, focalPoint: event.localPosition);
    }
  }

  void handlePointerDown(PointerDownEvent event) {
    if (event.buttons == kMiddleMouseButton) {
      _panPointerId = event.pointer;
      _lastPanPosition = event.localPosition;
    }
  }

  void handlePointerMove(PointerMoveEvent event) {
    if (_panPointerId == event.pointer && _lastPanPosition != null) {
      final delta = event.localPosition - _lastPanPosition!;
      _lastPanPosition = event.localPosition;
      panBy(delta);
    }
  }

  void handlePointerUp(PointerUpEvent event) {
    if (_panPointerId == event.pointer) {
      _panPointerId = null;
      _lastPanPosition = null;
    }
  }

  void handlePointerCancel(PointerCancelEvent event) {
    if (_panPointerId == event.pointer) {
      _panPointerId = null;
      _lastPanPosition = null;
    }
  }
}
