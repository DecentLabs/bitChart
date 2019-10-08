//
//  transform.swift
//  bitChart
//
//  Created by brigitta forrai on 2019. 10. 07..
//  Copyright © 2019. brigitta forrai. All rights reserved.
//

import Foundation


//struct Test: Sequence {
//    let start: Int
//    let step = 1
//    let length: Int
//
//    func makeIterator() -> TestIterator {
//        return TestIterator(self)
//    }
//}
//
//struct TestIterator: IteratorProtocol {
//    let test: Test
//    var times = 0
//
//    init(_ test: Test) {
//        self.test = test
//    }
//
//    mutating func next() -> Int? {
//        let nextNumber = (times * test.step) + test.start
//        guard nextNumber < test.length else {
//            return nil
//        }
//
//        times += 1
//        return nextNumber
//    }
//}


class StreamReader {
    let encoding: String.Encoding = .utf8
    let chunkSize: Int = 4096
    let delimeter: String = "\n"
    var isAtEOF: Bool = false
    
    let fileHandle: FileHandle
    var buffer: Data
    let delimPattern : Data
    
    
    init?(path: URL) {
        guard let fileHandle = try? FileHandle(forReadingFrom: path) else { return nil }
        self.fileHandle = fileHandle
        
        buffer = Data(capacity: self.chunkSize)
        delimPattern = delimeter.data(using: self.encoding)!
        
    }
    
    func next() -> [String]? {
        if isAtEOF { return nil }
        
        repeat {
            if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                    let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                    let row = String(data: subData, encoding: encoding)
                    buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: [])
                    return row?.components(separatedBy: ",")
            } else {
                let tempData = fileHandle.readData(ofLength: chunkSize)
                if tempData.count == 0 {
                    isAtEOF = true
                    if (buffer.count > 0) {
                        let row = String(data: buffer, encoding: encoding)
                        return row?.components(separatedBy: ",")
                    } else {
                        return nil
                    }
                }
                buffer.append(tempData)
            }
        } while true
    }
    
        deinit {
            fileHandle.closeFile()
        }
        
        func rewind() {
            fileHandle.seek(toFileOffset: 0)
            buffer.removeAll(keepingCapacity: true)
            isAtEOF = false
        }
}
