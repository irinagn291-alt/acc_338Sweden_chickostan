import SwiftUI

struct ContentView: View {
    @Bindable var presenter: GridPresenter

    var body: some View {
        ReviewScreenRouter(presenter: presenter)
    }
}
