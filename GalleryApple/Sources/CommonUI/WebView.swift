import SafariServices
import SwiftUI

public struct WebView: UIViewControllerRepresentable
{
    let url: URL

    public init(url: URL)
    {
        self.url = url
    }

    public func makeUIViewController(
        context: UIViewControllerRepresentableContext<WebView>
    ) -> SFSafariViewController
    {
        return SFSafariViewController(url: url)
    }

    public func updateUIViewController(
        _ uiViewController: SFSafariViewController,
        context: UIViewControllerRepresentableContext<WebView>
    )
    {
    }
}

struct WebView_Previews: PreviewProvider
{
    static var previews: some View
    {
        Group {
            WebView(url: URL(string: "https://github.com/inamiy/Actomaton")!)
        }
    }
}
