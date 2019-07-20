public struct Gimli {
    var s: (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>)
    
    public init() {
        s = (.zero, .zero, .zero)
    }
    
    public subscript(index: Int) -> UInt8 {
        get {
            return withUnsafePointer(to: s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index]
                }
            }
        }
        set {
            withUnsafeMutablePointer(to: &s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index] = newValue
                }
            }
        }
    }
    
    public var last: UInt8 {
        get {
            self[47]
        }
        set {
            self[47] = newValue
        }
    }
    
    public mutating func permute() {
        for round in (UInt32(1)...24).reversed() {
            let x = s.0.rotated(by: 24)
            let y = s.1.rotated(by:  9)
            let z = s.2
            
            s.2 = x ^ (z &<< 1) ^ ((y & z) &<< 2)
            s.1 = y ^  x        ^ ((x | z) &<< 1)
            s.0 = z ^  y        ^ ((x & y) &<< 3)
            
            switch round % 4 {
            case 0:
                s.0 = s.0[SIMD4<Int>(1, 0, 3, 2)]
                s.0 ^= SIMD4<UInt32>(0x9e377900 ^ round, 0, 0, 0)
            case 2:
                s.0 = s.0[SIMD4<Int>(2, 3, 0, 1)]
            default:
                break
            }
        }
    }
}

extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    func rotated(by n: UInt32) -> SIMD4<UInt32> {
        (self &<< n) | (self &>> (32 &- n))
    }
}

extension Gimli: Equatable {
    public static func == (lhs: Gimli, rhs: Gimli) -> Bool {
        lhs.s.0 == rhs.s.0 && lhs.s.1 == rhs.s.1 && lhs.s.2 == rhs.s.2
    }
}
