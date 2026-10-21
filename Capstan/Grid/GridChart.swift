import Foundation

/// Root archive. One Codable chart holds columns, cap bands, the Bare | Pinned
/// fold, and every mark. Day totals are derived. `schemaVersion` starts at 1.
struct GridChart: Codable, Equatable, Sendable {
    static let currentSchema = 1

    var schemaVersion: Int
    var columns: [ColumnRecord]
    var bands: [CapBandThreshold]
    var pins: [PinMarkEvent]
    var ticks: [TickMarkEvent]
    var strays: [StrayMarkEvent]
    var hollows: [HollowMarkEvent]
    var peels: [PeelMarkEvent]
    var snaps: [PeriodSnap]
    /// Explicit fold. Vacant when `columns` is empty.
    var phase: GridPhase
    var activeDaykey: Int
    var onboardingComplete: Bool

    init(
        schemaVersion: Int = GridChart.currentSchema,
        columns: [ColumnRecord] = [],
        bands: [CapBandThreshold] = [],
        pins: [PinMarkEvent] = [],
        ticks: [TickMarkEvent] = [],
        strays: [StrayMarkEvent] = [],
        hollows: [HollowMarkEvent] = [],
        peels: [PeelMarkEvent] = [],
        snaps: [PeriodSnap] = [],
        phase: GridPhase = .vacant,
        activeDaykey: Int,
        onboardingComplete: Bool = false
    ) {
        self.schemaVersion = schemaVersion
        self.columns = columns
        self.bands = bands
        self.pins = pins
        self.ticks = ticks
        self.strays = strays
        self.hollows = hollows
        self.peels = peels
        self.snaps = snaps
        self.phase = columns.isEmpty ? .vacant : phase
        self.activeDaykey = activeDaykey
        self.onboardingComplete = onboardingComplete
    }

    static func empty(daykey: Int) -> GridChart {
        GridChart(activeDaykey: daykey, onboardingComplete: false)
    }

    var reticle: ReticleLock? {
        guard case .pinned(let columnID) = phase else { return nil }
        return ReticleLock(columnID: columnID)
    }

    func tally(columnID: UUID, daykey: Int) -> DayTallySnapshot {
        let floor = snaps
            .filter { $0.columnID == columnID && $0.daykey == daykey }
            .map(\.instant)
            .max()
        let count = ticks.filter { tick in
            guard tick.columnID == columnID, tick.daykey == daykey else { return false }
            if let floor, tick.instant <= floor { return false }
            return true
        }.count
        return DayTallySnapshot(columnID: columnID, daykey: daykey, value: count)
    }

    func band(for columnID: UUID) -> CapBandThreshold? {
        bands.first { $0.columnID == columnID }
    }
}

/// Capstan fold. Bare has no armed column. Pinned names the reticle target.
/// Vacant is the empty grid, not a third counting phase.
enum GridPhase: Codable, Equatable, Sendable {
    case vacant
    case bare
    case pinned(UUID)

    private enum CodingKeys: String, CodingKey {
        case kind
        case columnID
    }

    private enum Kind: String, Codable {
        case vacant
        case bare
        case pinned
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let kind = try container.decode(Kind.self, forKey: .kind)
        switch kind {
        case .vacant:
            self = .vacant
        case .bare:
            self = .bare
        case .pinned:
            let columnID = try container.decode(UUID.self, forKey: .columnID)
            self = .pinned(columnID)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .vacant:
            try container.encode(Kind.vacant, forKey: .kind)
        case .bare:
            try container.encode(Kind.bare, forKey: .kind)
        case .pinned(let columnID):
            try container.encode(Kind.pinned, forKey: .kind)
            try container.encode(columnID, forKey: .columnID)
        }
    }
}

extension GridChart {
    enum CodingKeys: String, CodingKey {
        case schemaVersion
        case columns
        case bands
        case pins
        case ticks
        case strays
        case hollows
        case peels
        case snaps
        case phase
        case activeDaykey
        case onboardingComplete
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let version = try container.decode(Int.self, forKey: .schemaVersion)
        switch version {
        case 1:
            schemaVersion = 1
            columns = try container.decodeIfPresent([ColumnRecord].self, forKey: .columns) ?? []
            bands = try container.decodeIfPresent([CapBandThreshold].self, forKey: .bands) ?? []
            pins = try container.decodeIfPresent([PinMarkEvent].self, forKey: .pins) ?? []
            ticks = try container.decodeIfPresent([TickMarkEvent].self, forKey: .ticks) ?? []
            strays = try container.decodeIfPresent([StrayMarkEvent].self, forKey: .strays) ?? []
            hollows = try container.decodeIfPresent([HollowMarkEvent].self, forKey: .hollows) ?? []
            peels = try container.decodeIfPresent([PeelMarkEvent].self, forKey: .peels) ?? []
            snaps = try container.decodeIfPresent([PeriodSnap].self, forKey: .snaps) ?? []
            phase = try container.decodeIfPresent(GridPhase.self, forKey: .phase) ?? .vacant
            activeDaykey = try container.decode(Int.self, forKey: .activeDaykey)
            onboardingComplete = try container.decodeIfPresent(Bool.self, forKey: .onboardingComplete) ?? false
            if columns.isEmpty {
                phase = .vacant
            }
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .schemaVersion,
                in: container,
                debugDescription: "Unsupported grid schema \(version)"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encode(columns, forKey: .columns)
        try container.encode(bands, forKey: .bands)
        try container.encode(pins, forKey: .pins)
        try container.encode(ticks, forKey: .ticks)
        try container.encode(strays, forKey: .strays)
        try container.encode(hollows, forKey: .hollows)
        try container.encode(peels, forKey: .peels)
        try container.encode(snaps, forKey: .snaps)
        try container.encode(phase, forKey: .phase)
        try container.encode(activeDaykey, forKey: .activeDaykey)
        try container.encode(onboardingComplete, forKey: .onboardingComplete)
    }
}
