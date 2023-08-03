# FileWriter/Logging

Very lightweight FileWriter to be used by Server-side Swift applications, that can also double as a log file writer for [SwiftLog](https://github.com/apple/swift-log) 

It can be used both statically and instance based to use in parallel if different files for different processes are required.

## Usage

### Static Filewriter

```swift
import Filewriter

        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let file = docDir.appending(path: "file.txt", directoryHint: .notDirectory)
        Filewriter.logfile = file

        Filewriter.write("A string that will appear on a single line in the file.")

```

### As instance of Filewriter

```swift
import Filewriter

        let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let file = docDir.appending(path: "file.txt", directoryHint: .notDirectory)
        
        let writer = Filewriter(logfile: file)
        writer.write("A string that will appear on a single line in the file.")

```


### Logging backend for SwiftLog
FileWriter/Logging can be used as a primary or secondary logging backend to save log messages to a file of your choice.

You can use SwiftLog's `MultiplexLogHandler` to setup FileWriter/Logging with another logging backend.

```swift
import Logging
import Filewriter

    //Setup Log writing
    let logfile = URL(fileURLWithPath: "./logs/logfile.txt")
    
LoggingSystem.bootstrap { label in
    MultiplexLogHandler([
        // Setup the standard logging backend to enable console logging
        StreamLogHandler.standardOutput(label: label)
        //Setup the FileWriter to write log to file
        Filewriter(logfile: logfile, label: label)
    ])
}
```

### Using a Logger

You can now use SwiftLog as usual and log messages are written to the file at the given URL.

```swift
import Logging

let logger = Logger(label: "com.example.App")

logger.error("Something went wrong!")
```


## Installation

Filewriter is easily installed using Swift Package Manager. 

### Swift Package Manager

Add the Filewriter package as a dependency to your `Package.swift` file.

```swift
.package(url: "https://github.com/JBergsee/swift-log-filewriter.git", from: "0.1.1")
```

Add Filewriter to your target's dependencies.

```swift
.target(
            name: "ExampleApp",
            dependencies: [
                .product(name: "Filewriter", package: "swift-log-filewriter"),
            ],
```
