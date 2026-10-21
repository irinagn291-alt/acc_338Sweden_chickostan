import SwiftUI

/// Daily caps for each habit. A blank field clears the cap.
struct CapBandView: View {
    @Bindable var presenter: GridPresenter
    @State private var drafts: [UUID: String] = [:]
    @State private var error = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: CapstanSpace.m) {
                Text("Set a daily cap, or leave it blank.")
                    .font(CapstanType.font(.body))
                    .foregroundStyle(CapstanColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                CapstanRule(thick: true)
                if presenter.board.columns.isEmpty {
                    Text("Add a habit before you set a cap.")
                        .font(CapstanType.font(.title))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    if let lead = presenter.board.columns.first {
                        VStack(alignment: .leading, spacing: CapstanSpace.s) {
                            Text(lead.name)
                                .font(CapstanType.font(.title))
                                .foregroundStyle(CapstanColor.ink)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .fixedSize(horizontal: false, vertical: true)
                            TextField("Whole number", text: draft(lead))
                                .font(CapstanType.font(.display, tabular: true))
                                .keyboardType(.decimalPad)
                                .padding(CapstanSpace.m)
                                .frame(minHeight: 44)
                                .capstanPlate()
                        }
                        .padding(CapstanSpace.m)
                        .capstanPlate()
                    }
                    if presenter.board.columns.count > 1 {
                    VStack(spacing: 0) {
                        ForEach(Array(presenter.board.columns.dropFirst())) { face in
                            HStack(spacing: CapstanSpace.s) {
                                Text(face.name)
                                    .font(CapstanType.font(.body))
                                    .foregroundStyle(CapstanColor.ink)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                TextField("Cap", text: draft(face))
                                    .font(CapstanType.font(.headline, tabular: true))
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(minWidth: 72, minHeight: 44)
                            }
                            .padding(.horizontal, CapstanSpace.m)
                            .frame(minHeight: 44)
                            CapstanRule()
                        }
                    }
                    .padding(.vertical, CapstanSpace.s)
                    .capstanPlate()
                    }
                    Button("Save caps") { saveAll() }
                        .buttonStyle(CapstanPressStyle(role: .accent))
                }
                if !error.isEmpty {
                    Text(error)
                        .font(CapstanType.font(.body))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Button("Retry") { error = "" }
                        .buttonStyle(CapstanPressStyle(role: .quiet))
                }
            }
            .padding(CapstanSpace.m)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(CapstanColor.bg.ignoresSafeArea())
        .navigationTitle("Daily caps")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: load)
    }

    private func draft(_ face: ColumnFace) -> Binding<String> {
        Binding(
            get: { drafts[face.id] ?? "" },
            set: { drafts[face.id] = $0.filter(\.isNumber) }
        )
    }

    private func load() {
        for face in presenter.board.columns {
            drafts[face.id] = face.dailyLimit.map { CapstanFormat.count($0) } ?? ""
        }
    }

    private func saveAll() {
        error = ""
        for face in presenter.board.columns {
            save(face.id)
            if !error.isEmpty { return }
        }
    }

    private func save(_ id: UUID) {
        let raw = drafts[id] ?? ""
        if raw.isEmpty {
            presenter.setBand(columnID: id, dailyLimit: nil)
            error = ""
            return
        }
        guard let value = CapstanFormat.whole(raw), value > 0 else {
            error = "Use a whole number above zero, or clear the field."
            return
        }
        presenter.setBand(columnID: id, dailyLimit: value)
        error = ""
    }
}
