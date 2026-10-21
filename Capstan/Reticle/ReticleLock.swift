import Foundation

/// The live lock frame. It names the pinned column while the fold is Pinned
/// and is absent in Bare and Vacant.
struct ReticleLock: Equatable, Sendable {
    var columnID: UUID
}
