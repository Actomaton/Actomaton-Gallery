import SwiftUI

struct RuleInputView: View
{
    @Binding var value: UInt8

    var body: some View
    {
        HStack {
            Spacer()

            TextField("", text: Binding(
                get: { "\(value)" },
                set: { newValue in
                    if let intValue = UInt8(newValue) {
                        value = min(max(intValue, 0), 255)
                    }
                }
            ))
            .keyboardType(.numberPad)
            .frame(width: 60)
            .textFieldStyle(RoundedBorderTextFieldStyle())

            Stepper("", value: $value, in: 0...255)
                .frame(width: 100)

            Spacer()
        }
        .padding()
    }
}
