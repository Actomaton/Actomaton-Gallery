import UIKit
import SwiftUI
import ActomatonUI

public enum ExampleListBuilder
{
    @MainActor
    public static func build(examples: [AnyExample]) -> UIViewController
    {
        let exampleListStore = RouteStore(
            state: .init(examples: examples),
            reducer: ExampleList.reducer,
            environment: ()
        )

        let exampleListVC = HostingViewController(
            store: exampleListStore,
            content: ExampleListView.init
        )

        exampleListStore.subscribeRoutes { [weak exampleListVC] route in
            print("===> route = \(route)", Thread.current)

            switch route {
            case let .showExample(example):
                let vc = example.build()
                vc.navigationItem.largeTitleDisplayMode = .never

                exampleListVC?.navigationController?.pushViewController(vc, animated: true)
            }
        }

        return exampleListVC
    }
}
