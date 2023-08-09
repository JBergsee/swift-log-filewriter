//
//  Filewriter.swift
//
//
//  Created by Johan Bergsee on 2023-07-18.
//
//

import Foundation
import Logging

public struct Filewriter: LogHandler {

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            metadata[metadataKey]
        }
        set {
            metadata[metadataKey] = newValue
        }
    }

    public var metadata = Logging.Logger.Metadata()

    /// Lowest level (`.trace`) by default
    public var logLevel = Logging.Logger.Level.trace

    /// The log label for the log handler.
    public var label: String = ""

    private static var defaultFW: Filewriter = {
        return Filewriter()
    }()

    public static var logfile: URL? {
        get {
            defaultFW.logfile
        }
        set {
            defaultFW.logfile = newValue
        }
    }

    public var logfile: URL? {
        didSet {
            if let logfile {
                if !logfile.isFileURL {
                    print("The logfile is no file URL. Removing")
                    self.logfile = nil
                } else if !FileManager.default.fileExists(atPath: logfile.path) {
                    //Create directory and file
                    do {
                        try FileManager.default.createDirectory(at: logfile.deletingLastPathComponent(), withIntermediateDirectories: true)
                        let timestamp = Filewriter.formatter.string(from: Date())
                        let data = "Logfile created \(timestamp)\n".data(using: .utf8)
                        try data!.write(to: logfile, options: .atomic)
                        print("Created new logfile at \(logfile.path)")
                    } catch {
                        print("New logfile could not be created. \( error.localizedDescription)")
                        self.logfile = nil
                    }
                } else {
                    print("Logging to existing file at \(logfile.path)")
                }
            }
        }
    }

    public let dateFormat: String = "yyyy-MM-dd HH:mm:ss"

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()

    public init(logfile: URL, label: String = "") {
        self.label = label
        defer {
            self.logfile = logfile //Has to be deferred in order to run `didSet`
        }
    }

    /// Init without parameters, logfile has to be set before logging or writing can start
    public init() {}


    /// Write to the static file using the default Filewriter
    public static func write(_ message: String) {
        Filewriter.defaultFW.write(message)
    }

    public func write(_ message: String) {
        guard let logfile else {
            print("No logfile set.")
            return
        }

        guard let data = (message + "\n").data(using: .utf8) else {
            return
        }

        do {
            let fileHandle = try FileHandle(forWritingTo: logfile)
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: data)
//            if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *) {
//                try fileHandle.synchronize()
//            }
            try fileHandle.close()
        } catch {
            print("Unable to write to file.")
            print("Error: \(error.localizedDescription)")
        }
    }

    /// - parameters:
    ///     - level: The log level the message was logged at.
    ///     - message: The message to log. To obtain a `String` representation call `message.description`.
    ///     - metadata: The metadata associated to this log message.
    ///     - source: The source where the log message originated, for example the logging module.
    ///     - file: The file the log message was emitted from.
    ///     - function: The function the log line was emitted from.
    ///     - line: The line the log message was emitted from.
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {

        Filewriter.formatter.dateFormat = dateFormat
        let timestamp = Filewriter.formatter.string(from: Date())
        let metadataString = prettify(metadata ?? Logger.Metadata())
        write("(\(timestamp) \(level.description) \(label) [\(source)] \(metadataString): \(message.description)")
    }

    private func prettify(_ metadata: Logger.Metadata) -> String {
        if metadata.isEmpty {
            return ""
        } else {
            return metadata.lazy.sorted(by: { $0.key < $1.key }).map { "\($0)=\($1)" }.joined(separator: " ")
        }
    }
}

extension Logger.Level: CustomStringConvertible {
    public var description: String {
        switch self {

        case .trace:
            return "trace"
        case .debug:
            return "debug"
        case .info:
            return "Info"
        case .notice:
            return "Notice"
        case .warning:
            return "WARNING"
        case .error:
            return "ERROR"
        case .critical:
            return "!!! CRITICAL !!!"
        }
    }
}
