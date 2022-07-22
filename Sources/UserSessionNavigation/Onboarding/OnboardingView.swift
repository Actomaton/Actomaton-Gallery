import SwiftUI

public struct OnboardingView: View
{
    @Binding
    private var isOnboardingComplete: Bool

    public init(isOnboardingComplete: Binding<Bool>)
    {
        self._isOnboardingComplete = isOnboardingComplete
    }

    public var body: some View
    {
        VStack(spacing: 16) {
            Image(systemName: "airplane.circle")
                .font(.system(size: 180))

            Text("Onboarding")

            Spacer().frame(height: 50)

            Button(action: { isOnboardingComplete = true }) {
                Text("Skip")
            }
        }
        .font(.title)
    }
}

struct OnboardingView_Previews: PreviewProvider
{
    static var previews: some View
    {
        OnboardingView(
            isOnboardingComplete: .constant(false)
        )
    }
}
