/**
 * VoLtKid应用主入口
 * 六边形电路闯关游戏
 */
import SwiftUI

@main
struct VoLtKidApp: App {
    var body: some Scene {
        WindowGroup {
            CoverView()
                .preferredColorScheme(.light)
        }
    }
}
