import SwiftUI

/// Home is the fold. The figure, the action strip, and the drawn board stay mounted.
struct GridRootView: View {
    @Bindable var presenter: GridPresenter
    var onLog: () -> Void
    var onSettings: () -> Void
    var onAdd: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var selectedID: UUID?
    @State private var busy = false

    var body: some View {
        GeometryReader { geo in
            let board = presenter.board
            ScrollView {
                VStack(alignment: .leading, spacing: CapstanSpace.m) {
                    header
                    if let note = board.recoveryNote, !note.isEmpty {
                        recovery(note)
                    }
                    if board.columns.isEmpty {
                        EmptyBoard(
                            imageName: "cps_EmptyHome",
                            title: "Add a habit to start.",
                            line: "Pin one habit, then tick. The count lands only on the habit you pinned.",
                            action: "Add a habit",
                            onAction: onAdd
                        )
                        .frame(minHeight: geo.size.height - CapstanSpace.xxl * 2)
                    } else {
                        hero
                        ActionStripView(
                            tickEnabled: true,
                            busy: busy,
                            onPin: pin,
                            onTick: tick,
                            onPeel: peel
                        )
                        Text(instruction)
                            .font(CapstanType.font(.body))
                            .foregroundStyle(CapstanColor.ink)
                            .fixedSize(horizontal: false, vertical: true)
                            .animation(CapstanMotion.fade(reduceMotion), value: instruction)
                        CapstanGridLayerView(
                            columns: board.columns,
                            pinnedID: pinnedID,
                            selectedID: selectedID,
                            onSelect: { selectedID = $0 },
                            onPeel: peel
                        )
                        .frame(minHeight: max(320, geo.size.height * 0.52))
                        .accessibilityLabel("Habit board")
                    }
                }
                .padding(CapstanSpace.m)
                .frame(maxWidth: .infinity, minHeight: geo.size.height, alignment: .top)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .background(CapstanColor.bg.ignoresSafeArea())
        .onAppear(perform: alignSelection)
        .onChange(of: presenter.board.columns.map(\.id)) { _, _ in
            alignSelection()
        }
        .onChange(of: pinnedID) { _, _ in
            if selectedID == nil { alignSelection() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: CapstanSpace.s) {
            HStack(alignment: .center, spacing: CapstanSpace.s) {
                VStack(alignment: .leading, spacing: CapstanSpace.s) {
                    Text("Today")
                        .font(CapstanType.font(.title))
                        .foregroundStyle(CapstanColor.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(CapstanFormat.stamp(presenter.board.daykey))
                        .font(CapstanType.font(.caption, tabular: true))
                        .foregroundStyle(CapstanColor.muted)
                }
                Spacer(minLength: CapstanSpace.s)
                iconButton("chart.bar", label: "Log", action: onLog)
                iconButton("gearshape", label: "Settings", action: onSettings)
                iconButton("plus", label: "Add a habit", action: onAdd)
            }
            CapstanRule(thick: true)
            Text("Pin one habit, then tick.")
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var hero: some View {
        let face = selected
        return VStack(alignment: .leading, spacing: CapstanSpace.s) {
            HStack(alignment: .firstTextBaseline, spacing: CapstanSpace.s) {
                Text(face?.name ?? "Habit")
                    .font(CapstanType.font(.headline))
                    .foregroundStyle(CapstanColor.ink)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(0)
                Spacer(minLength: CapstanSpace.s)
                Text(phaseWord)
                    .font(CapstanType.font(.caption))
                    .foregroundStyle(CapstanColor.ink)
                    .padding(.horizontal, CapstanSpace.s)
                    .frame(minHeight: 44)
                    .background(CapstanColor.surface, in: RoundedRectangle(cornerRadius: CapstanRadius.chip, style: .continuous))
            }
            Text(CapstanFormat.count(face?.tally ?? 0))
                .font(CapstanType.font(.display, tabular: true))
                .foregroundStyle(CapstanColor.accent)
                .fixedSize(horizontal: false, vertical: true)
                .contentTransition(reduceMotion ? .identity : .numericText())
                .animation(CapstanMotion.fade(reduceMotion), value: face?.tally ?? 0)
            BandChip(tally: face?.tally ?? 0, limit: face?.dailyLimit, overBand: face?.overBand ?? false)
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, alignment: .leading)
        .capstanPlate()
        .accessibilityElement(children: .combine)
    }

    private func recovery(_ note: String) -> some View {
        VStack(alignment: .leading, spacing: CapstanSpace.s) {
            Text(note)
                .font(CapstanType.font(.body))
                .foregroundStyle(CapstanColor.ink)
                .fixedSize(horizontal: false, vertical: true)
            Button("Retry") {
                Task { await presenter.load() }
            }
            .buttonStyle(CapstanPressStyle(role: .quiet))
        }
        .padding(CapstanSpace.m)
        .capstanPlate()
    }

    private func iconButton(_ symbol: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(CapstanType.font(.headline))
                .foregroundStyle(CapstanColor.ink)
                .frame(width: 44, height: 44)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous)
                        .stroke(CapstanColor.ink, lineWidth: CapstanStroke.hairline)
                )
                .contentShape(Rectangle())
        }
        .accessibilityLabel(label)
    }

    private var selected: ColumnFace? {
        if let selectedID, let face = presenter.board.columns.first(where: { $0.id == selectedID }) {
            return face
        }
        return presenter.board.columns.first
    }

    private var pinnedID: UUID? {
        presenter.board.reticle?.columnID
    }

    private var phaseWord: String {
        if pinnedID != nil { return "Pinned" }
        if presenter.board.columns.isEmpty { return "Empty" }
        return "Open"
    }

    private var instruction: String {
        let name = selected?.name ?? "this habit"
        switch presenter.board.notice {
        case .ticked:
            return "One landed on \(name). Pin the next habit before you tick again."
        case .stray:
            return "That tick missed the pin. \(name) stayed the same."
        case .hollow:
            return "Nothing is pinned. Pin a habit, then tick."
        case .peeled:
            return "The latest tick or miss from today was removed."
        case .refused:
            return "That change was not applied."
        case .snapped:
            return "A new day started. Yesterday closed at zero."
        case .pinned, .reassigned, .none, .vacant:
            break
        }
        if let pinnedID, let pinned = presenter.board.columns.first(where: { $0.id == pinnedID }) {
            if selected?.id == pinnedID {
                return "\(pinned.name) is pinned. Tick adds one, then the pin releases."
            }
            return "The pin is on \(pinned.name). Tick on \(name) records a miss."
        }
        return "Choose a habit and pin it. Tick stays refused until then."
    }

    private func alignSelection() {
        let ids = presenter.board.columns.map(\.id)
        if let selectedID, ids.contains(selectedID) { return }
        selectedID = pinnedID ?? ids.first
    }

    private func pin() {
        guard let id = selected?.id else { return }
        commit { presenter.pin(columnID: id) }
    }

    private func tick() {
        guard let id = selected?.id else { return }
        commit { presenter.tick(columnID: id) }
    }

    private func peel() {
        commit { presenter.peel() }
    }

    private func commit(_ work: () -> Void) {
        guard !busy else { return }
        busy = true
        work()
        if case .ticked = presenter.board.notice {
            CapstanHaptic.commit()
        }
        Task {
            do {
                try await Task.sleep(nanoseconds: 180_000_000)
            } catch {
                busy = false
                return
            }
            busy = false
        }
    }
}
