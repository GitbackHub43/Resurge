import SwiftUI

// MARK: - HexShieldShape (Time Milestones)

/// A hexagonal shield — pointy at top, wider in middle, pointed at bottom.
struct HexShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        p.addLine(to: CGPoint(x: w, y: h * 0.2))
        p.addLine(to: CGPoint(x: w, y: h * 0.65))
        p.addLine(to: CGPoint(x: w * 0.5, y: h))
        p.addLine(to: CGPoint(x: 0, y: h * 0.65))
        p.addLine(to: CGPoint(x: 0, y: h * 0.2))
        p.closeSubpath()
        return p
    }
}

// MARK: - FlameShape (Streak Badges)

/// A flame silhouette with organic, flowing curves.
struct FlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        p.move(to: CGPoint(x: w * 0.5, y: 0))
        // Right side flame curve
        p.addCurve(to: CGPoint(x: w * 0.85, y: h * 0.45),
                   control1: CGPoint(x: w * 0.65, y: h * 0.05),
                   control2: CGPoint(x: w * 0.95, y: h * 0.25))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                   control1: CGPoint(x: w * 0.75, y: h * 0.65),
                   control2: CGPoint(x: w * 0.65, y: h * 0.9))
        // Left side flame curve (mirror)
        p.addCurve(to: CGPoint(x: w * 0.15, y: h * 0.45),
                   control1: CGPoint(x: w * 0.35, y: h * 0.9),
                   control2: CGPoint(x: w * 0.25, y: h * 0.65))
        p.addCurve(to: CGPoint(x: w * 0.5, y: 0),
                   control1: CGPoint(x: w * 0.05, y: h * 0.25),
                   control2: CGPoint(x: w * 0.35, y: h * 0.05))
        return p
    }
}

// MARK: - MedallionShape (Behavior Badges)

/// A circle with notched/gear-like edge.
struct MedallionShape: Shape {
    let notchCount: Int

    init(notchCount: Int = 16) {
        self.notchCount = notchCount
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.88
        var p = Path()
        for i in 0..<(notchCount * 2) {
            let angle = (Double(i) / Double(notchCount * 2)) * 2 * .pi - .pi / 2
            let r = i % 2 == 0 ? outerRadius : innerRadius
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle)) * r,
                y: center.y + CGFloat(sin(angle)) * r
            )
            if i == 0 {
                p.move(to: pt)
            } else {
                p.addLine(to: pt)
            }
        }
        p.closeSubpath()
        return p
    }
}

// MARK: - ProgramShieldShape (Program Badges)

/// A classic shield shape with rounded top and pointed bottom.
struct ProgramShieldShape: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width, h = rect.height
        var p = Path()
        // Rounded top edge
        p.move(to: CGPoint(x: 0, y: h * 0.15))
        p.addQuadCurve(to: CGPoint(x: w * 0.5, y: 0),
                       control: CGPoint(x: 0, y: 0))
        p.addQuadCurve(to: CGPoint(x: w, y: h * 0.15),
                       control: CGPoint(x: w, y: 0))
        // Sides that taper to bottom point
        p.addLine(to: CGPoint(x: w, y: h * 0.55))
        p.addCurve(to: CGPoint(x: w * 0.5, y: h),
                   control1: CGPoint(x: w, y: h * 0.75),
                   control2: CGPoint(x: w * 0.7, y: h * 0.95))
        p.addCurve(to: CGPoint(x: 0, y: h * 0.55),
                   control1: CGPoint(x: w * 0.3, y: h * 0.95),
                   control2: CGPoint(x: 0, y: h * 0.75))
        p.closeSubpath()
        return p
    }
}

// MARK: - StarBurstShape (Track Badges)

/// An N-pointed star shape.
struct StarBurstShape: Shape {
    let points: Int

    init(points: Int = 8) {
        self.points = points
    }

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        var p = Path()
        for i in 0..<(points * 2) {
            let angle = (Double(i) / Double(points * 2)) * 2 * .pi - .pi / 2
            let r = i % 2 == 0 ? outerRadius : innerRadius
            let pt = CGPoint(
                x: center.x + CGFloat(cos(angle)) * r,
                y: center.y + CGFloat(sin(angle)) * r
            )
            if i == 0 {
                p.move(to: pt)
            } else {
                p.addLine(to: pt)
            }
        }
        p.closeSubpath()
        return p
    }
}
