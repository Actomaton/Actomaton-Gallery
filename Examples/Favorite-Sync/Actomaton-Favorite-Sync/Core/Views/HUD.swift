import SwiftUI

@MainActor
struct HUD<Content: View>: View
{
    @ViewBuilder let content: Content

    var body: some View
    {
        content
            .padding(.horizontal, 12)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .foregroundColor(Color.white)
                    .shadow(color: Color(.black).opacity(0.16), radius: 12, x: 0, y: 5)
            )
            .padding(16)
    }
}
