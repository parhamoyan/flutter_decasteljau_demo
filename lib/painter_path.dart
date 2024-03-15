import 'dart:math' as math;
import 'package:flutter/material.dart';

class PainterPath {
  List<PathElement> elements = [];

  PathElement elementAt(int i) {
    PathElement element;
    int index;
    if (i >= 0) {
      index = i;
    } else {
      index = elements.length + i - 1;
    }
    element = elements.elementAt(index);
    return element;
  }

  void updateElementAt(int i, PathElement updatedElement) {
    int index;
    if (i >= 0) {
      index = i;
    } else {
      index = elements.length + i - 1;
    }
    elements[index] = updatedElement;
  }

  void addEllipse(Rect r) {
    double rx = r.width * 0.5;
    double ry = r.height * 0.5;
    double cx = r.left + rx;
    double cy = r.top + ry;

    // Define kappa as needed
    double kappa = 0.5522847498;

    // Top right
    elements.add(PathElement(cx + rx, cy, PathElementType.moveTo));

    elements.add(PathElement(cx + rx, cy - ry * kappa, PathElementType.curveTo));
    elements.add(PathElement(cx + rx * kappa, cy - ry, PathElementType.curveToData));
    elements.add(PathElement(cx, cy - ry, PathElementType.curveToData));

    // Top left
    elements.add(PathElement(cx - rx * kappa, cy - ry, PathElementType.curveTo));
    elements.add(PathElement(cx - rx, cy - ry * kappa, PathElementType.curveToData));
    elements.add(PathElement(cx - rx, cy, PathElementType.curveToData));

    // Bottom left
    elements.add(PathElement(cx - rx, cy + ry * kappa, PathElementType.curveTo));
    elements.add(PathElement(cx - rx * kappa, cy + ry, PathElementType.curveToData));
    elements.add(PathElement(cx, cy + ry, PathElementType.curveToData));

    // Bottom right
    elements.add(PathElement(cx + rx * kappa, cy + ry, PathElementType.curveTo));
    elements.add(PathElement(cx + rx, cy + ry * kappa, PathElementType.curveToData));
    elements.add(PathElement(cx + rx, cy, PathElementType.curveToData));
  }
}

enum PathElementType { moveTo, lineTo, curveTo, curveToData }

class PathElement {
  double x, y;
  PathElementType type;

  PathElement(this.x, this.y, this.type);
}

class Point {
  double x;
  double y;

  Point(this.x, this.y);

  double distanceTo(Point other) {
    double dx = x - other.x;
    double dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  static Point lerp(Point a, Point b, double t) {
    final double x = a.x + (b.x - a.x) * t;
    final double y = a.y + (b.y - a.y) * t;
    return Point(x, y);
  }

  Point operator +(Point other) {
    return Point(x + other.x, y + other.y);
  }
}
