import XCTest
@testable import Filewriter
import Logging

final class swift_log_filewriterTests: XCTestCase {


    func testStaticVSInstanceWrites() {
        let tempdir = FileManager.default.temporaryDirectory
        var staticLog, instanceLog: URL
//        if #available(macOS 13.0, iOS 16.0, *) {
//            staticLog = tempdir.appending(path: "staticlog.txt", directoryHint: .notDirectory)
//            instanceLog = tempdir.appending(path: "instanceLog.txt", directoryHint: .notDirectory)
//        } else {
            // Fallback on earlier versions
            staticLog = tempdir.appendingPathComponent("staticlog.txt", isDirectory: false)
            instanceLog = tempdir.appendingPathComponent("instanceLog.txt", isDirectory: false)
//        }
        Filewriter.logfile = staticLog
        let instanceWriter = Filewriter(logfile: instanceLog, label: "InstanceWriter")

        let staticString = "Writing to static Filewriter"
        let instanceString = "Writing to instance Filewriter"
        Filewriter.write(staticString)
        instanceWriter.write(instanceString)

        do {
            let staticResult = try String(contentsOf: staticLog)
            let instanceResult = try String(contentsOf: instanceLog)
            print("Static: " + staticResult)
            print("Instance: " + instanceResult)
            XCTAssert(staticResult.hasSuffix(staticString+"\n"))
            XCTAssert(instanceResult.hasSuffix(instanceString+"\n"))
        } catch {
            XCTFail("Could not read from file")
        }
    }



    func testRequiredByLogHandler() throws {

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("testlog.txt")
        LoggingSystem.bootstrap({ label in
            Filewriter(logfile: url, label: "testLog")
        })
        var logger1 = Logger(label: "first logger")
        logger1.logLevel = .debug
        logger1[metadataKey: "only-on"] = "first"
        var logger2 = logger1
        logger2.logLevel = .error                  // this must not override `logger1`'s log level
        logger2[metadataKey: "only-on"] = "second" // this must not override `logger1`'s metadata

        XCTAssertEqual(.debug, logger1.logLevel)
        XCTAssertEqual(.error, logger2.logLevel)
        XCTAssertEqual("first", logger1[metadataKey: "only-on"])
        XCTAssertEqual("second", logger2[metadataKey: "only-on"])
    }
}
