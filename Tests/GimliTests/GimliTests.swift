import XCTest
@testable import Gimli

final class GimliTests: XCTestCase {
    func testGimli() {
        var gimli = Gimli()
        
        for i in 0..<4 {
            var j = UInt32(i)
            gimli.s.0[i] = j &* j &* j &+ j &* 0x9e3779b9
            j = UInt32(i + 4)
            gimli.s.1[i] = j &* j &* j &+ j &* 0x9e3779b9
            j = UInt32(i + 8)
            gimli.s.2[i] = j &* j &* j &+ j &* 0x9e3779b9
        }
        
        gimli.permute()
        
        let expected = (
            SIMD4<UInt32>(0xba11c85a, 0x91bad119, 0x380ce880, 0xd24c2c68),
            SIMD4<UInt32>(0x3eceffea, 0x277a921c, 0x4f73a0bd, 0xda5a9cd8),
            SIMD4<UInt32>(0x84b673f0, 0x34e52ff7, 0x9e2bef49, 0xf41bb8d6)
        )
        
        XCTAssertEqual(gimli.s.0, expected.0)
        XCTAssertEqual(gimli.s.1, expected.1)
        XCTAssertEqual(gimli.s.2, expected.2)
    }
    
    static var allTests = [
        ("testGimli", testGimli),
    ]
}
