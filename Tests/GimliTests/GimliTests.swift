import XCTest
@testable import Gimli

final class gimliTests: XCTestCase {
    func testGimli() {
        let gimli = Gimli()
        
        for i in 0..<12 {
            let j = UInt32(i)
            gimli.words[i] = j &* j &* j &+ j &* 0x9e3779b9
        }
        
        gimli.permute()

        let expected: [UInt32] = [
            0xba11c85a, 0x91bad119, 0x380ce880, 0xd24c2c68,
            0x3eceffea, 0x277a921c, 0x4f73a0bd, 0xda5a9cd8,
            0x84b673f0, 0x34e52ff7, 0x9e2bef49, 0xf41bb8d6
        ]
        
        for i in 0..<12 {
            XCTAssertEqual(gimli.words[i], expected[i])
        }
    }

    static var allTests = [
        ("testGimli", testGimli),
    ]
}
