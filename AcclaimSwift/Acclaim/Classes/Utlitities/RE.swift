import Foundation

public struct RE {
    
    public internal(set) var regularExpression: NSRegularExpression
    
    public struct Pattern {
        public internal(set) var patternString:String
    }
    
    public struct Sult {
        public internal(set) var content: String
        public internal(set) var result:NSTextCheckingResult
        public internal(set) var matches:[Int:String] = [:]
        
        public init(content: String, result:NSTextCheckingResult){
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
        self.regularExpression = try! NSRegularExpression(pattern: pattern.patternString, options: .UseUnicodeWordBoundaries)
    }
    
    public func match(inString string: String,  options: NSMatchingOptions = .WithTransparentBounds)->[RE.Sult]{
        let range = NSRange(location: 0, length: string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
        let matches = self.regularExpression.matchesInString(string, options: options, range: range)
        return matches.map{ Sult(content: string, result: $0) }
    }
    
}

extension RE.Pattern {
    
    public func match(inString string: String, options: NSMatchingOptions = .WithTransparentBounds)->[RE.Sult]{
        return RE(pattern: self).match(inString: string, options: options)
    }
    
    public func firstMatch(inString string: String, options: NSMatchingOptions = .WithTransparentBounds)->RE.Sult?{
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
        
        let range = self.result.rangeAtIndex(index)
        
        guard range.location != NSNotFound else {
            return nil
        }
        
        let startIndex = self.content.startIndex.advancedBy(range.location)
        let endIndex = self.content.startIndex.advancedBy(range.location + range.length)
        return startIndex..<endIndex
    }
    
    public func substring(matchIndex index: Int)->String?{
        guard let range = self.range(byIndex: index) else{
            return nil
        }
        
        return self.content.substringWithRange(range)
    }
    
    public subscript(index: Int)->String?{
        return self.substring(matchIndex: index)
    }
    
}