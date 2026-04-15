import SwiftUI

struct AppIconOption: Identifiable {
    let id: String
    let name: String
    let iconName: String? // nil = default icon
    let previewColor: Color
    let symbolName: String

    static let allOptions: [AppIconOption] = [
        AppIconOption(id: "default", name: "Default", iconName: nil, previewColor: Color(red: 0.3, green: 0.2, blue: 0.6), symbolName: "moon.fill"),
        AppIconOption(id: "minimal", name: "Minimal", iconName: "AppIcon-Minimal", previewColor: .black, symbolName: "waveform"),
        AppIconOption(id: "nature", name: "Nature", iconName: "AppIcon-Nature", previewColor: Color(red: 0.1, green: 0.5, blue: 0.3), symbolName: "leaf.fill"),
        AppIconOption(id: "ocean", name: "Ocean", iconName: "AppIcon-Ocean", previewColor: Color(red: 0.1, green: 0.2, blue: 0.6), symbolName: "water.waves"),
    ]
}

struct AppIconPicker: View {
    @State private var selectedIcon: String = {
        if let name = UIApplication.shared.alternateIconName {
            return AppIconOption.allOptions.first(where: { $0.iconName == name })?.id ?? "default"
        }
        return "default"
    }()

    var body: some View {
        ForEach(AppIconOption.allOptions) { option in
            Button {
                setIcon(option)
            } label: {
                HStack(spacing: 14) {
                    // Icon preview
                    RoundedRectangle(cornerRadius: 12)
                        .fill(option.previewColor)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Image(systemName: option.symbolName)
                                .font(.title3)
                                .foregroundStyle(.white)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    Text(option.name)
                        .foregroundStyle(.white)

                    Spacer()

                    if selectedIcon == option.id {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appAccent)
                    }
                }
            }
            .listRowBackground(Color.appSurface)
        }
    }

    private func setIcon(_ option: AppIconOption) {
        guard selectedIcon != option.id else { return }
        selectedIcon = option.id

        UIApplication.shared.setAlternateIconName(option.iconName) { error in
            if let error {
                print("Failed to set alternate icon: \(error)")
            }
        }
    }
}
