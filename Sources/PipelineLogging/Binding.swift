import Foundation
import Pipeline
import Logging

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

public struct ExecutionLogEntry: Sendable, CustomStringConvertible {
    
    let executionEvent: ExecutionEvent
    let metadataInfo: String
    let excutionInfoFormat: ExecutionInfoFormat?
    
    public var description: String {
        if let excutionInfoFormat {
            executionEvent.description(format: excutionInfoFormat, withMetaDataInfo: metadataInfo)
        } else {
            executionEvent.description(withMetaDataInfo: metadataInfo)
        }
    }
}

public struct ExecutionEventProcessorForLogger: ExecutionEventProcessor {
    
    public let metadataInfo: String
    public let metadataInfoForUserInteraction: String
    
    private let logger: any Logger<ExecutionLogEntry,InfoType>
    private let severityTracker = SeverityTracker()
    private let minimalInfoType: InfoType?
    private let excutionInfoFormat: ExecutionInfoFormat?
    
    /// The the severity i.e. the worst message type.
    var severity: InfoType { severityTracker.value }
    
    /// This closes all loggers.
    public func closeEventProcessing() throws {
        try logger.close()
    }
    
    public init(
        withMetaDataInfo metadataInfo: String,
        withMetaDataInfoForUserInteraction metadataInfoForUserInteraction: String? = nil,
        logger: any Logger<ExecutionLogEntry,InfoType>,
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
        logger.log(ExecutionLogEntry(executionEvent: executionEvent, metadataInfo: metadataInfo, excutionInfoFormat: excutionInfoFormat), withMode: executionEvent.type)
    }
    
}

/// A logger that just prints to the standard output.
public final class ExecutionLogEntryPrinter: ConcurrentLogger<ExecutionLogEntry,InfoType>, @unchecked Sendable {
    
    public typealias Message = ExecutionLogEntry
    public typealias Mode = InfoType
    
    private let printLogger: PrintLogger<ExecutionLogEntry,PrintMode>
    
    public init(errorsToStandard: Bool = false) {
        printLogger = PrintLogger(errorsToStandard: errorsToStandard)
    }
    
    override public func log(_ message: ExecutionLogEntry, withMode mode: InfoType? = nil) {
        if let mode, mode >= .error {
            printLogger.log(message, withMode: .error)
        } else {
            printLogger.log(message, withMode: .standard)
        }
        
    }
    
}
