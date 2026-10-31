import SwiftUI

/// Settings panel — language first; anchors from the pad-stage top-right gear (vision A).
struct SettingsSheetView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    languageRow
                } header: {
                    Text(settings.t("settings.language"))
                } footer: {
                    Text(settings.t("settings.footer"))
                        .font(.footnote)
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(settings.t("settings.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(settings.t("settings.done")) { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var languageRow: some View {
        HStack(spacing: 12) {
            Text(settings.t("settings.language.label"))
                .foregroundStyle(.primary)
            Spacer(minLength: 8)
            languagePicker
        }
    }

    private var languagePicker: some View {
        HStack(spacing: 0) {
            langChip(.zh, title: "中")
            langChip(.en, title: "EN")
        }
        .background(Capsule().fill(Color.white.opacity(0.08)))
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel(settings.t("settings.language"))
    }

    private func langChip(_ lang: AppLanguage, title: String) -> some View {
        Button {
            settings.language = lang
        } label: {
            Text(title)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(settings.language == lang ? Color.white : Color.white.opacity(0.45))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(settings.language == lang ? Color.white.opacity(0.18) : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(settings.language == lang ? .isSelected : [])
    }
}
