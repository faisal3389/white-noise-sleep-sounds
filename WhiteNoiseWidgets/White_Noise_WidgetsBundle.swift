import WidgetKit
import SwiftUI

@main
struct White_Noise_WidgetsBundle: WidgetBundle {
    var body: some Widget {
        NowPlayingSmallWidget()
        NowPlayingMediumWidget()
        LockScreenCircularWidget()
        LockScreenRectangularWidget()
    }
}
