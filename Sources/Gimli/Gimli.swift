@inline(__always)
fileprivate func rotate(_ x: UInt32, by bits: Int) -> UInt32 {
    return (x << bits) | (x >> (32 &- bits))
}

struct GimliState {
    var word0: UInt32 = 0
    var word1: UInt32 = 0
    var word2: UInt32 = 0
    var word3: UInt32 = 0
    var word4: UInt32 = 0
    var word5: UInt32 = 0
    var word6: UInt32 = 0
    var word7: UInt32 = 0
    var word8: UInt32 = 0
    var word9: UInt32 = 0
    var wordA: UInt32 = 0
    var wordB: UInt32 = 0
}

public final class Gimli {
    private var state: GimliState
    public var words: UnsafeMutableBufferPointer<UInt32>
    public var bytes: UnsafeMutableRawBufferPointer
    
    public init() {
        state = GimliState()
        words = withUnsafeMutablePointer(to: &state) {
            $0.withMemoryRebound(to: UInt32.self, capacity: 12, {
                UnsafeMutableBufferPointer(start: $0, count: 12)
            })
        }
        bytes = withUnsafeMutablePointer(to: &state) {
            $0.withMemoryRebound(to: UInt8.self, capacity: 4 * 12, {
                UnsafeMutableRawBufferPointer(start: $0, count: 4 * 12)
            })
        }
    }

    public func permute() {
        for round in (1...24).reversed() {
            for column in 0..<4 {
                let x = rotate(words[0 &+ column], by: 24)
                let y = rotate(words[4 &+ column], by:  9)
                let z =        words[8 &+ column]
                
                words[8 &+ column] = x ^ (z << 1) ^ ((y & z) << 2)
                words[4 &+ column] = y ^ x        ^ ((x | z) << 1)
                words[0 &+ column] = z ^ y        ^ ((x & y) << 3)
            }
            
            if round & 3 == 0 {
                var x = words[0]
                words[0] = words[1]
                words[1] = x
                x = words[2]
                words[2] = words[3]
                words[3] = x
                words[0] ^= 0x9e377900 | UInt32(round);
            } else if round & 3 == 2 {
                var x = words[0]
                words[0] = words[2]
                words[2] = x
                x = words[1]
                words[1] = words[3]
                words[3] = x
            }
        }
    }
}
