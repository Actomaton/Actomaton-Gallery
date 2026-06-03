import UIKit

/// Sample image (`color.jpg`) bundled with the `ColorFilter` target.
///
/// Exposed so `ColorFilterBindingUI` can reuse the same asset instead of duplicating it.
public func colorFilterSampleImage() -> UIImage
{
    UIImage(named: "color.jpg", in: .module, with: nil)!
}
