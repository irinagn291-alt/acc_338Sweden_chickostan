import SwiftUI

/// Habits, caps, reset, and the support link. The editor pushes on this stack.
struct SettingsSheetView: View {
    @Bindable var presenter: GridPresenter
    var onClose: () -> Void

    @State private var confirmToday = false
    @State private var confirmAll = false
    @State private var editor: EditorRoute?

    private enum EditorRoute: Identifiable, Hashable {
        case create
        case edit(UUID)
        var id: String {
            switch self {
            case .create: "create"
            case .edit(let value): value.uuidString
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if presenter.board.columns.isEmpty {
                    EmptyBoard(
                        imageName: "cps_EmptyGridCutout",
                        title: "No habits yet.",
                        line: "Add one habit. You can rename it and set a daily cap here.",
                        action: "Add a habit",
                        onAction: { editor = .create }
                    )
                } else {
                    List {
                        Section {
                            if let url = URL(string: "https://capstan-grid.pro/contact-us") {
                                Link(destination: url) {
                                    VStack(alignment: .leading, spacing: CapstanSpace.s) {
                                        Text("Contact and support")
                                            .font(CapstanType.font(.headline))
                                            .foregroundStyle(CapstanColor.ink)
                                        Text(url.absoluteString)
                                            .font(CapstanType.font(.callout))
                                            .foregroundStyle(CapstanColor.ink)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                    .contentShape(Rectangle())
                                }
                            }
                        }
                        if let note = presenter.board.recoveryNote, !note.isEmpty {
                            Section {
                                Text(note)
                                    .font(CapstanType.font(.body))
                                    .foregroundStyle(CapstanColor.ink)
                                    .fixedSize(horizontal: false, vertical: true)
                                Button("Retry") {
                                    Task { await presenter.load() }
                                }
                                .frame(minHeight: 44)
                            }
                        }
                        Section {
                            ForEach(presenter.board.columns) { face in
                                Button {
                                    editor = .edit(face.id)
                                } label: {
                                    HStack(spacing: CapstanSpace.s) {
                                        Text(face.name)
                                            .font(CapstanType.font(.body))
                                            .foregroundStyle(CapstanColor.ink)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                        Spacer(minLength: CapstanSpace.s)
                                        Text(CapstanFormat.count(face.tally))
                                            .font(CapstanType.font(.headline, tabular: true))
                                            .foregroundStyle(CapstanColor.accent)
                                        Image(systemName: "chevron.right")
                                            .foregroundStyle(CapstanColor.muted)
                                            .accessibilityHidden(true)
                                    }
                                    .frame(minHeight: 44)
                                    .contentShape(Rectangle())
                                }
                            }
                            Button("Add a habit") { editor = .create }
                                .font(CapstanType.font(.headline))
                                .foregroundStyle(CapstanColor.ink)
                                .frame(minHeight: 44)
                        }
                        Section {
                            row("Daily caps") { CapBandView(presenter: presenter) }
                            row("Lock") { CALayerReticleView(presenter: presenter) }
                            row("Habit list") { CountersView(presenter: presenter) }
                            row("Ticks") { TickMarkView(presenter: presenter) }
                            row("Misses") { StrayMarkView(presenter: presenter) }
                            row("Refused ticks") { HollowMarkView(presenter: presenter) }
                            row("Removed ticks") { PeelMarkView(presenter: presenter) }
                        }
                        Section {
                            Button("Reset today") { confirmToday = true }
                                .font(CapstanType.font(.body))
                                .foregroundStyle(CapstanColor.ink)
                                .frame(minHeight: 44)
                            Button("Erase all data") { confirmAll = true }
                                .font(CapstanType.font(.body))
                                .foregroundStyle(CapstanColor.ink)
                                .frame(minHeight: 44)
                            Button("Show introduction") {
                                presenter.reopenOnboarding()
                                onClose()
                            }
                                .font(CapstanType.font(.body))
                                .foregroundStyle(CapstanColor.ink)
                                .frame(minHeight: 44)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(CapstanColor.bg.ignoresSafeArea())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .frame(width: 44, height: 44)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel("Close")
                }
            }
            .navigationDestination(item: $editor) { route in
                ColumnEditorSheet(
                    presenter: presenter,
                    columnID: {
                        if case .edit(let id) = route { return id }
                        return nil
                    }(),
                    onClose: { editor = nil }
                )
            }
            .confirmationDialog(
                "Reset today?",
                isPresented: $confirmToday,
                titleVisibility: .visible
            ) {
                Button("Reset today", role: .destructive) {
                    presenter.resetToday()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Every count for this date returns to zero.")
            }
            .confirmationDialog(
                "Erase every habit?",
                isPresented: $confirmAll,
                titleVisibility: .visible
            ) {
                Button("Erase all data", role: .destructive) {
                    Task { await presenter.resetAllData() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Habits and counts are removed. This cannot be undone.")
            }
        }
    }

    private func row<Destination: View>(_ title: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            Text(title)
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
    }
}
