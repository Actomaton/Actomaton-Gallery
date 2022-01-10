import SwiftUI
import UIKit

/// Conversion from `UIKit.UIView` to `SwiftUI.View`.
public func uiViewToSwiftUI<V: UIView>(
    make: (() -> V)? = nil
) -> some UIViewRepresentable
{
    FromUIView(make: make)
}

/// Conversion from `UIKit.UIViewController` to `SwiftUI.View`.
public func uiViewControllerToSwiftUI<VC: UIViewController>(
    make: (() -> VC)? = nil
) -> some UIViewControllerRepresentable
{
    FromUIViewController(make: make)
}

// MARK: - Private

private struct FromUIView<V: UIView>: UIViewRepresentable
{
    let make: (() -> V)?

    init(make: (() -> V)? = nil)
    {
        self.make = make
    }

    func makeUIView(context: Context) -> V
    {
        if let make = make {
            return make()
        } else {
            return V()
        }
    }

    func updateUIView(_ uiView: V, context: Context) {}
}

private struct FromUIViewController<VC: UIViewController>: UIViewControllerRepresentable
{
    let make: (() -> VC)?

    init(make: (() -> VC)? = nil)
    {
        self.make = make
    }

    func makeUIViewController(context: Context) -> VC
    {
        if let make = make {
            return make()
        } else {
            return VC()
        }
    }

    func updateUIViewController(_ uiViewController: VC, context: Context) {}
}
