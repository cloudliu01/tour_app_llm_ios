import Foundation
import MetricKit

/// Bridges MetricKit payloads into analytics events until full observability stack lands.
@MainActor
final class MetricKitMonitor: NSObject, MXMetricManagerSubscriber {
    static let shared = MetricKitMonitor()

    private let metricManager = MXMetricManager.shared

    private override init() {
        super.init()
    }

    func start() {
        metricManager.add(self)
    }

    func stop() {
        metricManager.remove(self)
    }

    nonisolated func didReceive(_ payloads: [MXMetricPayload]) {
        // TODO: Wire to NarrationAnalytics once implemented.
        for payload in payloads {
            #if DEBUG
            print("Received MetricKit payload: \(payload)")
            #endif
        }
    }

    nonisolated func didReceive(_ payloads: [MXDiagnosticPayload]) {}
}

