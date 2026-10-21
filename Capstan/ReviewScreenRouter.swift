import SwiftUI

/// Reads `ReviewLaunch.screen` once, after onboarding, and opens that destination.
struct ReviewScreenRouter: View {
    @Bindable var presenter: GridPresenter
    @Environment(\.scenePhase) private var scenePhase
    @State private var booted = false
    @State private var showSpinner = false
    @State private var routed = false
    @State private var cover: String?
    @State private var showLog = false
    @State private var showSettings = false
    @State private var showEditor = false

    var body: some View {
        ZStack {
            GridRootView(
                presenter: presenter,
                onLog: { showLog = true },
                onSettings: { showSettings = true },
                onAdd: { showEditor = true }
            )
            .opacity(showsHome ? 1 : 0)
            .accessibilityHidden(!showsHome)
            if booted, presenter.board.onboardingComplete, let cover, cover != "today" {
                coverDestination(cover)
                    .background(CapstanColor.bg.ignoresSafeArea())
            }
            if booted, !presenter.board.onboardingComplete {
                OnboardingView(onFinish: finishIntro)
            }
            if !booted {
                bootPlate
            }
        }
        .sheet(isPresented: $showLog) {
            StatsSheetView(presenter: presenter, onClose: { showLog = false })
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(presenter: presenter, onClose: { showSettings = false })
        }
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                ColumnEditorSheet(presenter: presenter, columnID: nil, onClose: { showEditor = false })
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Close") { showEditor = false }
                        }
                    }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            guard phase != .active else { return }
            Task { await presenter.flushForSceneExit() }
        }
        .task { await boot() }
    }

    private var showsHome: Bool {
        booted && presenter.board.onboardingComplete && (cover == nil || cover == "today")
    }

    private var bootPlate: some View {
        VStack(alignment: .leading, spacing: CapstanSpace.m) {
            Text("Today")
                .font(CapstanType.font(.title))
                .foregroundStyle(CapstanColor.ink)
            CapstanRule(thick: true)
            RoundedRectangle(cornerRadius: CapstanRadius.card, style: .continuous)
                .fill(CapstanColor.surface)
                .frame(height: 160)
                .redacted(reason: .placeholder)
            if showSpinner {
                ProgressView("Loading the board")
                    .font(CapstanType.font(.body))
                    .tint(CapstanColor.ink)
            }
        }
        .padding(CapstanSpace.m)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(CapstanColor.bg.ignoresSafeArea())
    }

    @ViewBuilder
    private func coverDestination(_ key: String) -> some View {
        switch key {
        case "log":
            StatsSheetView(presenter: presenter, onClose: { cover = nil })
        case "goals":
            SettingsSheetView(presenter: presenter, onClose: { cover = nil })
        case "calayerreticle":
            CapstanScreen(title: "Lock", onClose: { cover = nil }) {
                CALayerReticleView(presenter: presenter)
            }
        case "capband":
            CapstanScreen(title: "Daily caps", onClose: { cover = nil }) {
                CapBandView(presenter: presenter)
            }
        case "tickmark":
            CapstanScreen(title: "Ticks", onClose: { cover = nil }) {
                TickMarkView(presenter: presenter)
            }
        case "straymark":
            CapstanScreen(title: "Misses", onClose: { cover = nil }) {
                StrayMarkView(presenter: presenter)
            }
        case "hollowmark":
            CapstanScreen(title: "Refused", onClose: { cover = nil }) {
                HollowMarkView(presenter: presenter)
            }
        case "peelmark":
            CapstanScreen(title: "Removed", onClose: { cover = nil }) {
                PeelMarkView(presenter: presenter)
            }
        case "counters":
            CapstanScreen(title: "Habits", onClose: { cover = nil }) {
                CountersView(presenter: presenter)
            }
        default:
            Color.clear
        }
    }

    private func boot() async {
        let spinner = Task {
            do {
                try await Task.sleep(nanoseconds: 150_000_000)
            } catch {
                return
            }
            showSpinner = true
        }
        await presenter.load()
        spinner.cancel()
        showSpinner = false
        booted = true
        routeIfReady()
        while !Task.isCancelled {
            do {
                try await Task.sleep(nanoseconds: 30_000_000_000)
            } catch {
                return
            }
            let stamp = DayKey.stamp(Date(), calendar: .current)
            if stamp != presenter.board.daykey {
                await presenter.load()
            }
        }
    }

    private func routeIfReady() {
        guard !routed, presenter.board.onboardingComplete else { return }
        routed = true
        cover = ReviewLaunch.screen
    }

    private func finishIntro() {
        if presenter.board.columns.isEmpty {
            presenter.addColumn(name: "Reps")
        }
        presenter.completeOnboarding()
        routeIfReady()
    }
}
