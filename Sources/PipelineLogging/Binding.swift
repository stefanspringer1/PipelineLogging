import Foundation
import Pipeline

/// Keeps track of the severity i.e. the worst message type.
public final class SeverityTracker: @unchecked Sendable {
    
    private var _severity = InfoType.allCases.min()!
    
    /// Gets the current severity.
    var value: InfoType {
        queue.sync {
            _severity
        }
    }
    
    internal let group = DispatchGroup()
    internal let queue = DispatchQueue(label: "SeverityTracker")
    
    public func process(_ newSeverity: InfoType) {
        group.enter()
        self.queue.sync {
            if newSeverity > _severity {
                _severity = newSeverity
            }
            self.group.leave()
        }
    }
    
    /// Wait until all logging is done.
    public func wait() {
        group.wait()
    }
    
}

public struct ExecutionEventProcessorForLogger: ExecutionEventProcessor {
    
    public let metadataInfo: String
    public let metadataInfoForUserInteraction: String
    
    private let logger: Logger
    private let severityTracker = SeverityTracker()
    private let minimalInfoType: InfoType?
    private let excutionInfoFormat: ExecutionInfoFormat?
    
    /// The the severity i.e. the worst message type.
    var severity: InfoType { severityTracker.value }
    
    init(
        withMetaDataInfo metadataInfo: String,
        withMetaDataInfoForUserInteraction metadataInfoForUserInteraction: String? = nil,
        logger: Logger,
        withMinimalInfoType minimalInfoType: InfoType? = nil,
        excutionInfoFormat: ExecutionInfoFormat? = nil
    ) {
        self.metadataInfo = metadataInfo
        self.metadataInfoForUserInteraction = metadataInfoForUserInteraction ?? metadataInfo
        self.logger = logger
        self.minimalInfoType = minimalInfoType
        self.excutionInfoFormat = excutionInfoFormat
    }
    
    public func process(_ executionEvent: ExecutionEvent) {
        severityTracker.process(executionEvent.type)
        if let minimalInfoType, executionEvent.type < minimalInfoType {
            return
        }
        if let excutionInfoFormat {
            logger.log(executionEvent.description(format: excutionInfoFormat, withMetaDataInfo: metadataInfo))
        } else {
            logger.log(executionEvent.description(withMetaDataInfo: metadataInfo))
        }
    }
    
}
