import SwiftUI

struct DatePickerOptional: View {
    let label: String
    let prompt: String
    let range: PartialRangeThrough<Date>
    @Binding var date: Date?
    @State private var hiddenDate: Date = Date()
    @State private var showDate: Bool = false

    init(_ label: String, prompt: String, in range: PartialRangeThrough<Date>, selection: Binding<Date?>) {
        self.label = label
        self.prompt = prompt
        self.range = range
        self._date = selection
    }

    var body: some View {
        ZStack {
            HStack {
                Text(label)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                Spacer()
                if showDate {
                    Button {
                        showDate = false
                        date = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.secondary)
                    }
                    DatePicker(
                        label,
                        selection: $hiddenDate,
                        in: range,
                        displayedComponents: .date
                    )
                    .labelsHidden()
                    .onChange(of: hiddenDate) { newDate in
                        date = newDate
                    }
                } else {
                    Button {
                        showDate = true
                        hiddenDate = date ?? Date()
                    } label: {
                        Text(prompt)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.primary)
                    }
                    .frame(width: 120, height: 34)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGray5))
                    )
                    .foregroundColor(.white)
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
