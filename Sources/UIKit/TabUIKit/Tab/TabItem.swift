import UIKit
import ExampleListUIKit

struct TabItem
{
    var title: String
    var tabBarItem: UITabBarItem
    var examples: [Example]
}

extension TabItem
{
    init(
        title: String,
        image: UIImage,
        examples: [Example]
    )
    {
        self.title = title
        self.tabBarItem = .init(title: title, image: image, tag: 0)
        self.examples = examples
    }
}
