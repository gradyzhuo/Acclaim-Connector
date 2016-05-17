//
//  Parameter.swift
//  Acclaim
//
//  Created by Grady Zhuo on 4/4/16.
//  Copyright © 2016 Grady Zhuo. All rights reserved.
//

import Foundation

public protocol Parameter {
    var key: String { get }
}


public protocol ParameterValue{ }

extension String : ParameterValue{ /* not implemented.*/ }
extension Int: ParameterValue{ /* not implemented.*/ }


public typealias Parameters = [Parameter]

extension RangeReplaceableCollectionType where Generator.Element == Parameter {
    public typealias Element = Generator.Element
    
    public init<T:ParameterValue>(dictionary elements: [String:T]){
        self.init()
        elements.forEach {
            self.add(parameterValue: $1, forKey: $0)
        }
    }
    
    public init<T:ParameterValue>(dictionary elements: [String:[T]]){
        self.init()
        elements.forEach {
            self.add(array: $1, forKey: $0)
        }
    }
    
    public init<T:ParameterValue>(dictionary elements: [String:[String:T]]){
        self.init()
        elements.forEach {
            self.add(dictionary: $1, forKey: $0)
        }
    }
    
    public func indexOf(paramKey key: String)->Self.Index?{
        let index = self.indexOf { $0.key == key }
        return index
    }
    
    public func indexOf(param: Element)->Self.Index?{
        let index = self.indexOf { $0.key == param.key }
        return index
    }
    
    public func contains(param: Element) -> Bool {
        return self.contains{ $0.key == param.key }
    }
    
    public mutating func add(param:Element){
        if !self.contains(param) {
            self.append(param)
        }
    }
    
    public mutating func addParams(params:[Element]){
        params.forEach {
            if !self.contains($0) {
                self.append($0)
            }
        }
    }
    
    public mutating func remove(forKey key:String)->Element? {
        if let index = self.indexOf(paramKey: key){
            return self.removeAtIndex(index)
        }
        return nil
    }
    
    internal func serialize(serializer: ParametersSerializer) -> NSData? {
        if let parameters = self as? [Element] {
            return serializer.serialize(parameters)
        }
        return nil
    }
    
}


//MARK: - Convenience Methods
extension RangeReplaceableCollectionType where Generator.Element == Parameter {
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of ParameterValueType.
     - forKey key: a string type value be the key.
     - returns: The new Parameter generated.
     */
    internal mutating func add<T:ParameterValue>(parameterValue value: T, forKey key:String)->Element{
        let param = FormParameter(key: key, value: value)
        self.add(param)
        return param
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of String.
     - forKey key: a string type value be the key.
     - returns: The new Parameter generated.
     */
    public mutating func add(string value: String, forKey key:String)->Element{
        return self.add(parameterValue: value, forKey: key)
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of Int.
     - forKey key: a string type value be the key.
     - returns: The new Parameter generated.
     */
    public mutating func add(int value: Int, forKey key:String)->Element{
        return self.add(parameterValue: value, forKey: key)
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of Array<ParameterValueType>.
     - forKey key: a string type value be the key.
     - returns: The new Parameter generated.
     */
    public mutating func add<T:ParameterValue>(array value: [T], forKey key:String)->Parameter{
        let param = FormParameter(key: key, value: value)
        self.add(param)
        return param
    }
    
    /**
     Generating and adding a new parameter by input key and value.
     - parameters:
     - value: Value by instance of Dictionary<String,ParameterValueType>.
     - forKey key: a string type value be the key.
     - returns: The new Parameter generated.
     */
    public mutating func add<T:ParameterValue>(dictionary value: [String:T], forKey key:String)->Parameter{
        let param = FormParameter(key: key, value: value)
        self.add(param)
        return param
    }
    
    public mutating func add(data value: NSData?, forKey key: String, fileName: String = "", MIME: MIMEType = .All)->Parameter{
        let param = FormDataParameter(key: key, data: value ?? NSData(), fileName: fileName, MIME: MIME)
        self.add(param)
        return param
    }
    
    public mutating func add(image value: UIImage?, decoder: ImageDecoder, forKey key: String)->Parameter{
        let data = decoder.decode(image: value) ?? NSData()
        let filename = String(format: "%.2f.%@", NSDate().timeIntervalSince1970, decoder.fileExtension)
        let param = FormDataParameter(key: key, data: data, fileName: filename, MIME: decoder.MIME)
        self.add(param)
        return param
    }
    
    
}

/// ImageDecoder
public enum ImageDecoder {
    case JPEG(quality: CGFloat)
    case PNG
    
    internal var MIME: MIMEType {
        switch self {
        case .JPEG:
            return .Image(subtype: "jpeg")
        case .PNG:
            return .Image(subtype: "png")
        }
    }
    
    internal var fileExtension: String {
        switch self {
        case .JPEG:
            return "jpg"
        case .PNG:
            return "png"
        }
    }
    
    internal func decode(image image:UIImage?)->NSData?{
        
        guard let image = image else{
            return nil
        }
        
        switch self {
        case .JPEG(let quality):
            return UIImageJPEGRepresentation(image, quality)
        default:
            return UIImagePNGRepresentation(image)
        }
    }
    
}