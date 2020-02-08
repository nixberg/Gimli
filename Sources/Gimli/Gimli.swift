public struct Gimli {
    var s: (SIMD4<UInt32>, SIMD4<UInt32>, SIMD4<UInt32>)
    
    public init() {
        s = (.zero, .zero, .zero)
    }
    
    public subscript(index: Int) -> UInt8 {
        get {
            precondition((0..<48).contains(index))
            return withUnsafePointer(to: s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index]
                }
            }
        }
        // TODO: modify
        set {
            precondition((0..<48).contains(index))
            withUnsafeMutablePointer(to: &s) {
                $0.withMemoryRebound(to: UInt8.self, capacity: 48) {
                    $0[index] = newValue
                }
            }
        }
    }
    
    public mutating func permute() {
        @inline(__always)
        func applySPBox() {
            let x = s.0.rotated(by: 24)
            let y = s.1.rotated(by:  9)
            let z = s.2
            
            s.2 = x ^ (z &<< 1) ^ ((y & z) &<< 2)
            s.1 = y ^  x        ^ ((x | z) &<< 1)
            s.0 = z ^  y        ^ ((x & y) &<< 3)
        }
        
        func quadrupleRound(_ constant: UInt32) {
            applySPBox()
            s.0.smallSwap()
            s.0.x ^= constant
            
            applySPBox()
            
            applySPBox()
            s.0.bigSwap()
            
            applySPBox()
        }
        
        [0x9e377918, 0x9e377914, 0x9e377910, 0x9e37790c, 0x9e377908, 0x9e377904].forEach(quadrupleRound)
    }
}

fileprivate extension SIMD4 where Scalar == UInt32 {
    @inline(__always)
    func rotated(by n: UInt32) -> Self {
        (self &<< n) | (self &>> (32 &- n))
    }
    
    @inline(__always)
    mutating func smallSwap() {
        self = self[SIMD4(1, 0, 3, 2)]
    }
    
    @inline(__always)
    mutating func bigSwap() {
        self = self[SIMD4(2, 3, 0, 1)]
    }
}
