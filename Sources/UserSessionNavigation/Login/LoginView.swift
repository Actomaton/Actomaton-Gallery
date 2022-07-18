import SwiftUI
import ActomatonUI
import Utilities

public struct LoginView: View
{
    private let onAction: (Action) -> Void
    
    public init(onAction: @escaping (Action) -> Void)
    {
        self.onAction = onAction
    }
    
    public var body: some View
    {
        VStack(spacing: 16) {
            Image(systemName: "lock.circle")
                .font(.system(size: 180))
            
            Spacer().frame(height: 50)

            Button(action: { onAction(.login) }) {
                Text("Login")
            }

            Button(action: { runLoginFail() }) {
                Text("Login (Fail)")
            }

            Button(action: { onAction(.onboarding) }) {
                Text("Show Onboarding")
            }
        }
        .font(.title)
    }

    /// Simulates `.login` -> `.loginError`.
    private func runLoginFail() {
        Task {
            onAction(.login)

            try await Task.sleep(nanoseconds: 100_000_000)

            onAction(.loginError)
        }
    }
}
