import SwiftUI

/// Rename a habit or add one, and set an optional daily cap. Deletes are confirmed.
struct ColumnEditorSheet: View {
    @Bindable var presenter: GridPresenter
    var columnID: UUID?
    var onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var name = ""
    @State private var limitText = ""
    @State private var error = ""
    @State private var confirmDelete = false
    @FocusState private var focused: Field?

    private enum Field: Hashable {
        case name
        case limit
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CapstanSpace.m) {
                Text(columnID == nil ? "Name the habit." : "Edit this habit.")
                    .font(CapstanType.font(.title))
                    .foregroundStyle(CapstanColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                CapstanRule(thick: true)
                fieldTitle("Name")
                TextField("Habit name", text: $name)
                    .font(CapstanType.font(.body))
                    .foregroundStyle(CapstanColor.ink)
                    .focused($focused, equals: .name)
                    .submitLabel(.done)
                    .padding(CapstanSpace.m)
                    .frame(minHeight: 44)
                    .capstanPlate()
                    .onChange(of: name) { _, value in
                        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            error = "Enter a name."
                        } else if !error.isEmpty {
                            error = ""
                        }
                    }
                fieldTitle("Daily cap")
                TextField("Whole number", text: $limitText)
                    .font(CapstanType.font(.body, tabular: true))
                    .foregroundStyle(CapstanColor.ink)
                    .keyboardType(.decimalPad)
                    .focused($focused, equals: .limit)
                    .padding(CapstanSpace.m)
                    .frame(minHeight: 44)
                    .capstanPlate()
                    .onChange(of: limitText) { _, value in
                        limitText = digits(from: value)
                    }
                if !error.isEmpty {
                    Text(error)
                        .font(CapstanType.font(.body))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Button("Save") { save() }
                    .buttonStyle(CapstanPressStyle(role: .accent))
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                if columnID != nil {
                    Button("Delete") { confirmDelete = true }
                        .buttonStyle(CapstanPressStyle(role: .destructive))
                }
            }
            .padding(CapstanSpace.m)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(CapstanColor.bg.ignoresSafeArea())
        .onTapGesture { focused = nil }
        .navigationTitle(columnID == nil ? "New habit" : "Edit habit")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focused = nil }
            }
        }
        .onAppear(perform: load)
        .confirmationDialog(
            "Delete this habit?",
            isPresented: $confirmDelete,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let columnID {
                    presenter.delete(columnID: columnID)
                }
                onClose()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("The counts for this habit are removed with it.")
        }
        .animation(CapstanMotion.fade(reduceMotion), value: error)
    }

    private func fieldTitle(_ title: String) -> some View {
        Text(title)
            .font(CapstanType.font(.caption))
            .foregroundStyle(CapstanColor.muted)
    }

    private func load() {
        guard let columnID, let face = presenter.board.columns.first(where: { $0.id == columnID }) else { return }
        name = face.name
        if let limit = face.dailyLimit {
            limitText = CapstanFormat.count(limit)
        }
    }

    private func digits(from raw: String) -> String {
        let separator = Locale.current.decimalSeparator ?? "."
        if raw.contains(separator) || raw.contains("-") || raw.contains(where: { !$0.isNumber && String($0) != separator }) {
            error = "Use a whole number. Negative values are refused."
        }
        let cleaned = raw.filter(\.isNumber)
        if cleaned != raw.filter(\.isNumber) {
            return cleaned
        }
        if !cleaned.isEmpty, error.hasPrefix("Use a whole") {
            error = ""
        }
        return cleaned
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            error = "Enter a name."
            return
        }
        let limit = CapstanFormat.whole(limitText)
        if !limitText.isEmpty, limit == nil || (limit ?? 0) < 1 {
            error = "Use a whole number above zero, or leave the cap empty."
            return
        }
        if let columnID {
            presenter.rename(columnID: columnID, name: trimmed)
            if presenter.board.notice == .refused {
                error = "That name was refused."
                return
            }
            presenter.setBand(columnID: columnID, dailyLimit: limit)
        } else {
            let id = UUID()
            presenter.addColumn(name: trimmed, id: id)
            if presenter.board.notice == .refused {
                error = "That habit was refused."
                return
            }
            if let limit {
                presenter.setBand(columnID: id, dailyLimit: limit)
            }
        }
        onClose()
    }
}
