import Gimli
import XCTest

final class GimliTests: XCTestCase {
    func testPermutation() {
        XCTAssert(State().permutations().dropFirst(383).joined().starts(with: [
            0xf7, 0xb2, 0xd5, 0x86, 0x5e, 0x79, 0x28, 0x27,
            0xcb, 0xad, 0xe4, 0x14, 0x07, 0x5f, 0x6e, 0x3e,
            0x40, 0x8a, 0xcc, 0x2f, 0xdb, 0xb7, 0xbb, 0x56,
            0x47, 0x08, 0x9c, 0xf4, 0xef, 0xc6, 0xc1, 0x23,
            0xf1, 0x21, 0x5b, 0x75, 0x22, 0x2c, 0x72, 0x85,
            0xb8, 0xdb, 0x63, 0x01, 0xe9, 0x0a, 0x73, 0x0c,
        ]))
    }
    
    func testMRAC() {
        var state = State()
        
        XCTAssertEqual(state.count, 48)
        XCTAssertEqual(state.indices, 0..<48)
        
        XCTAssertEqual(state.index(after: state.startIndex), 1)
        XCTAssertEqual(state.index(before: state.endIndex), 47)
        
        state[43] = 0xff
        XCTAssertEqual(state[43], 0xff)
        state.first = 0xff
        XCTAssertEqual(state.first, 0xff)
        state.last = 0xff
        XCTAssertEqual(state.last, 0xff)
        
        state.withContiguousMutableStorageIfAvailable {
            for (index, element): (_, UInt8) in zip($0.indices, 0...) {
                $0[index] = element
            }
        }
        state.withContiguousStorageIfAvailable {
            XCTAssert($0.elementsEqual(0..<48))
        }
        
        state.withUnsafeMutableBytes {
            $0.copyBytes(from: 1...48)
        }
        state.withUnsafeBytes {
            XCTAssert($0.elementsEqual(1...48))
        }
        
        XCTAssert(state.elementsEqual(1...48))
    }
}

extension State {
    fileprivate func permutations() -> some Sequence<Self> {
        sequence(state: self, next: {
            $0.permute()
            return $0
        })
    }
}
