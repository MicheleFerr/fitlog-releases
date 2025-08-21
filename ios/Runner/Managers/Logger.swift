import Foundation
import os.log

/// Centralized logging system with levels and categories
final class Logger {
    
    // MARK: - Log Level
    
    enum Level: Int, Comparable {
        case debug = 0
        case info = 1
        case warning = 2
        case error = 3
        case critical = 4
        
        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            case .critical: return "🚨"
            }
        }
        
        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }
        
        static func < (lhs: Level, rhs: Level) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
    
    // MARK: - Categories
    
    enum Category: String {
        case general = "General"
        case audioSession = "AudioSession"
        case backgroundTask = "BackgroundTask"
        case liveActivity = "LiveActivity"
        case permission = "Permission"
        case network = "Network"
        case database = "Database"
        case performance = "Performance"
        case battery = "Battery"
        case system = "System"
        
        var osLog: OSLog {
            return OSLog(subsystem: "com.gymbro.tracklog", category: rawValue)
        }
    }
    
    // MARK: - Properties
    
    static let shared = Logger()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
    
    // Configuration
    private(set) var minimumLevel: Level = {
        #if DEBUG
        return .debug
        #else
        return .info
        #endif
    }()
    
    private var isConsoleLoggingEnabled = true
    private var isFileLoggingEnabled = false
    private var logFileURL: URL?
    
    // Metrics
    private var logCounts: [Level: Int] = [:]
    private let metricsQueue = DispatchQueue(label: "com.gymbro.logger.metrics")
    
    // MARK: - Initialization
    
    private init() {
        setupFileLogging()
    }
    
    // MARK: - Public Methods
    
    func log(
        _ level: Level,
        _ message: String,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        guard level >= minimumLevel else { return }
        
        let timestamp = dateFormatter.string(from: Date())
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        
        // Format message
        let formattedMessage = formatMessage(
            level: level,
            message: message,
            category: category,
            timestamp: timestamp,
            file: fileName,
            function: function,
            line: line
        )
        
        // Log to various outputs
        logToConsole(formattedMessage)
        logToOSLog(level: level, message: message, category: category)
        logToFile(formattedMessage)
        
        // Update metrics
        updateMetrics(for: level)
    }
    
    // Convenience methods
    func debug(_ message: String, category: Category = .general) {
        log(.debug, message, category: category)
    }
    
    func info(_ message: String, category: Category = .general) {
        log(.info, message, category: category)
    }
    
    func warning(_ message: String, category: Category = .general) {
        log(.warning, message, category: category)
    }
    
    func error(_ message: String, category: Category = .general) {
        log(.error, message, category: category)
    }
    
    func critical(_ message: String, category: Category = .general) {
        log(.critical, message, category: category)
    }
    
    // MARK: - Configuration
    
    func configure(
        minimumLevel: Level? = nil,
        consoleLogging: Bool? = nil,
        fileLogging: Bool? = nil
    ) {
        if let level = minimumLevel {
            self.minimumLevel = level
        }
        
        if let console = consoleLogging {
            self.isConsoleLoggingEnabled = console
        }
        
        if let file = fileLogging {
            self.isFileLoggingEnabled = file
            if file {
                setupFileLogging()
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func formatMessage(
        level: Level,
        message: String,
        category: Category,
        timestamp: String,
        file: String,
        function: String,
        line: Int
    ) -> String {
        #if DEBUG
        // Detailed format for debug builds
        return """
            \(level.emoji) [\(timestamp)] [\(category.rawValue)] [\(file):\(line)]
            \(function) - \(message)
            """
        #else
        // Concise format for release builds
        return "\(level.emoji) [\(timestamp)] [\(category.rawValue)] \(message)"
        #endif
    }
    
    private func logToConsole(_ message: String) {
        guard isConsoleLoggingEnabled else { return }
        print(message)
    }
    
    private func logToOSLog(level: Level, message: String, category: Category) {
        os_log("%{public}@", log: category.osLog, type: level.osLogType, message)
    }
    
    private func logToFile(_ message: String) {
        guard isFileLoggingEnabled, let url = logFileURL else { return }
        
        DispatchQueue.global(qos: .utility).async {
            do {
                let data = (message + "\n").data(using: .utf8)!
                
                if FileManager.default.fileExists(atPath: url.path) {
                    let fileHandle = try FileHandle(forWritingTo: url)
                    fileHandle.seekToEndOfFile()
                    fileHandle.write(data)
                    fileHandle.closeFile()
                } else {
                    try data.write(to: url)
                }
            } catch {
                // Avoid recursive logging
                print("Failed to write to log file: \(error)")
            }
        }
    }
    
    private func setupFileLogging() {
        guard let documentsDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let logsDirectory = documentsDirectory.appendingPathComponent("Logs")
        
        do {
            try FileManager.default.createDirectory(
                at: logsDirectory,
                withIntermediateDirectories: true
            )
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let fileName = "gymbro-\(dateFormatter.string(from: Date())).log"
            
            logFileURL = logsDirectory.appendingPathComponent(fileName)
            
        } catch {
            print("Failed to setup file logging: \(error)")
        }
    }
    
    private func updateMetrics(for level: Level) {
        metricsQueue.async {
            self.logCounts[level, default: 0] += 1
        }
    }
    
    // MARK: - Metrics & Debugging
    
    func getMetrics() -> [String: Any] {
        return metricsQueue.sync {
            return [
                "logCounts": logCounts.mapValues { $0 },
                "minimumLevel": minimumLevel.rawValue,
                "consoleEnabled": isConsoleLoggingEnabled,
                "fileEnabled": isFileLoggingEnabled,
                "logFileSize": getLogFileSize()
            ]
        }
    }
    
    private func getLogFileSize() -> Int64 {
        guard let url = logFileURL,
              let attributes = try? FileManager.default.attributesOfItem(atPath: url.path),
              let size = attributes[.size] as? Int64 else {
            return 0
        }
        return size
    }
    
    func clearLogFile() {
        guard let url = logFileURL else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
            info("Log file cleared", category: .general)
        } catch let fileError {
            self.error("Failed to clear log file: \(fileError)", category: .general)
        }
    }
    
    func exportLogs() -> URL? {
        return logFileURL
    }
}

// MARK: - Production Logging Helper

extension Logger {
    /// Log only critical information in production
    func production(_ message: String, category: Category = .general) {
        #if DEBUG
        info(message, category: category)
        #else
        // In production, only log if it's important
        if category == .audioSession || category == .backgroundTask {
            info(message, category: category)
        }
        #endif
    }
}