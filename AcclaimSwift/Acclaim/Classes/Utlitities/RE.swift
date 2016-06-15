import Foundation

public struct RE {
    
    public internal(set) var regularExpression: RegularExpression
    
    public struct Pattern {
        public internal(set) var patternString:String
    }
    
    public struct Sult {
        public internal(set) var content: String
        public internal(set) var result:TextCheckingResult
        public internal(set) var matches:[Int:String] = [:]
        
        public init(content: String, result:TextCheckingResult){
            self.content = content
            self.result = result
            
            var subStrs = [Int: String]()
            for index in 0..<self.numberOfMatches {
                
                if let subStr = self.substring(matchIndex: index) {
                    subStrs[index] = subStr
                }
            }
            self.matches = subStrs
        }
    }
    
    public internal(set) var pattern: Pattern
    
    public init(pattern: Pattern){
        self.pattern = pattern
        self.regularExpression = try! RegularExpression(pattern: pattern.patternString, options: .useUnicodeWordBoundaries)
    }
    
    public func match(inString string: String,  options: RegularExpression.MatchingOptions = .withTransparentBounds)->[RE.Sult]{
        let range = NSRange(location: 0, length: string.lengthOfBytes(using: String.Encoding.utf8))
        let matches = self.regularExpression.matches(in: string, options: options, range: range)
        return matches.map{ Sult(content: string, result: $0) }
    }
    
    public func isMatch(inString string: String,  options: RegularExpression.MatchingOptions = .withTransparentBounds)->Bool{
        
        let range = NSRange(location: 0, length: string.lengthOfBytes(using: String.Encoding.utf8))
        let matchedRange = self.regularExpression.rangeOfFirstMatch(in: string, options: options, range: range)
        return (range.location == matchedRange.location) && (range.length == matchedRange.length)
    }
    
}

extension RE.Pattern {
    
    public func isMatch(inString string: String, options: RegularExpression.MatchingOptions = .withTransparentBounds)->Bool{
        return RE(pattern: self).isMatch(inString: string, options: options)
    }
    
    public func match(inString string: String, options: RegularExpression.MatchingOptions = .withTransparentBounds)->[RE.Sult]{
        return RE(pattern: self).match(inString: string, options: options)
    }
    
    public func firstMatch(inString string: String, options: RegularExpression.MatchingOptions = .withTransparentBounds)->RE.Sult?{
        return RE(pattern: self).match(inString: string, options: options).first
    }
    
}

extension RE.Pattern : StringLiteralConvertible {
    
    public typealias StringLiteralType = String
    public typealias UnicodeScalarLiteralType = String
    public typealias ExtendedGraphemeClusterLiteralType = String

    public init(_ patternString: String){
        self.patternString = patternString
    }
    
    public init(unicodeScalarLiteral value: RE.Pattern.UnicodeScalarLiteralType) {
        self = RE.Pattern(value)
    }
    
    public init(stringLiteral value: RE.Pattern.StringLiteralType) {
        self = RE.Pattern(value)
    }

    public init(extendedGraphemeClusterLiteral value: RE.Pattern.ExtendedGraphemeClusterLiteralType) {
        self = RE.Pattern(value)
    }
    
}


extension RE.Sult {
    
    public var numberOfMatches:Int{
        return self.result.numberOfRanges
    }
    
    public func range(byIndex index: Int)->Range<String.Index>?{
        
        let numberOfMatchesRange = (0..<self.numberOfMatches)
        guard numberOfMatchesRange.contains(index) else{
            print("index (\(index)) is out of bounds. (\(numberOfMatchesRange)) ")
            return nil
        }
        
        let range = self.result.range(at: index)
        
        guard range.location != NSNotFound else {
            return nil
        }
        
        let startIndex = self.content.index(self.content.startIndex, offsetBy: range.location)
        let endIndex = self.content.index(startIndex, offsetBy: range.length)
        
        return startIndex..<endIndex
    }
    
    public func substring(matchIndex index: Int)->String?{
        guard let range = self.range(byIndex: index) else{
            return nil
        }
        
        return self.content.substring(with: range)
    }
    
    public subscript(index: Int)->String?{
        return self.substring(matchIndex: index)
    }
    
}
