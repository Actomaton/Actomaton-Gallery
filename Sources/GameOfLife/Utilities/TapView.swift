import SwiftUI

/// Workaround view to detect touched location which is not possible
/// as of Xcode 11.1 SwiftUI.
/// 
/// - SeeAlso: https://stackoverflow.com/a/56518293/666371
struct TapView: UIViewRepresentable
{
    private let didTap: (CGPoint) -> Void

    init(didTap: @escaping (CGPoint) -> Void)
    {
        self.didTap = didTap
    }

    func makeCoordinator() -> Coordinator
    {
        Coordinator(didTap: self.didTap)
    }

    func makeUIView(context: UIViewRepresentableContext<TapView>) -> UIView
    {
        let view = UIView(frame: .zero)
        let gesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.onTap(gesture:))
        )
        view.addGestureRecognizer(gesture)
        return view
    }

    func updateUIView(
        _ uiView: UIView,
        context: UIViewRepresentableContext<TapView>
    )
    {
    }

    final class Coordinator: NSObject
    {
        let didTap: ((CGPoint) -> Void)

        init(didTap: @escaping (CGPoint) -> Void)
        {
            self.didTap = didTap
        }

        @objc func onTap(gesture: UITapGestureRecognizer)
        {
            let point = gesture.location(in: gesture.view)
            self.didTap(point)
        }
    }
}
