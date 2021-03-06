//
//  Swift.Method.swift
//  Gryphin
//
//  Created by Dima Bart on 2016-12-23.
//  Copyright © 2016 Dima Bart. All rights reserved.
//

import Foundation

extension Swift {
    final class Method: Container, Equatable {
        
        let visibility:  Visibility
        let name:        Name
        let returnType:  String?
        let parameters:  [Parameter]?
        let annotations: [Annotation]?
        
        fileprivate(set) var comments: [Line]
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(visibility: Visibility = .internal, name: Name, returnType: String? = nil, parameters: [Method.Parameter]? = nil, annotations: [Annotation]? = nil, body: [Line]? = nil, comments: [Line]? = nil) {
            
            self.visibility  = visibility
            self.name        = name
            self.returnType  = returnType
            self.parameters  = parameters
            self.annotations = annotations
            self.comments    = comments ?? []
            
            super.init()
            
            if let body = body {
                self.add(children: body)
            }
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        override var stringRepresentation: String {
            var string = ""
            
            /* ---------------------------------
             ** Construct the method parameters.
             */
            var parameterString = ""
            if let parameters = self.parameters {
                
                parameterString = parameters.map {
                    $0.stringRepresentation
                }.joined(separator: ", ")
            }
            
            /* ---------------------------------
             ** Construct the method annotations
             */
            let annotations = self.annotations?.map {
                "\(self.indent)\($0.stringRepresentation)\n"
            }.joined(separator: "") ?? ""
            
            /* ---------------------------------
             ** Construct the return type
             */
            var returnType = ""
            if let type = self.returnType, !type.isEmpty {
                returnType = " -> \(type)"
            }
            
            let visibility = self.visibility == .none ? "" : "\(self.visibility.rawValue) "
            
            string += self.comments.commentStringIndentedBy(self.indent)
            string += annotations
            string += "\(self.indent)\(visibility)\(self.name.string)(\(parameterString))\(returnType)"
            
            /* ----------------------------------------
             ** Only append body and opening / closing
             ** braces if body is non-empty. Otherwise
             ** we'll treat this like a declaration.
             */
            if !self.children.isEmpty {
                string += " {\n"
                string += "\(super.stringRepresentation)\n"
                string += "\(self.indent)}\n"
            } else {
                string += "\n"
            }
            
            return string
        }
    }
}

// ----------------------------------
//  MARK: - Name -
//
extension Swift.Method {
    enum Name: Equatable {
        case initialization(InitializerType, Bool)
        case function(FunctionType, String)
        
        enum InitializerType: String {
            case none
            case required
            case convenience
        }
        
        enum FunctionType: String {
            case none
            case `static`
            case `class`
        }
        
        var string: String {
            switch self {
            case .initialization(let type, let failable):
                let type     = (type == .none) ? "" : "\(type.rawValue) "
                let failable = failable ? "?" : ""

                return "\(type)init\(failable)"

            case .function(let type, let title):
                let type     = (type == .none) ? "" : "\(type.rawValue) "
                return "\(type)func \(title)"
            }
        }
    }
}

extension Swift.Method.Name {
    static func ==(lhs: Swift.Method.Name, rhs: Swift.Method.Name) -> Bool {
        switch (lhs, rhs) {
        case (.initialization(let lType, let lFailable), .initialization(let rType, let rFailable)) where lType == rType && lFailable == rFailable:
            return true
        case (.function(let lName), .function(let rName)) where lName == rName:
            return true
        default:
            return false
        }
    }
}

// ----------------------------------
//  MARK: - GraphQLParameter -
//
extension Swift.Method {
    struct Parameter: StringRepresentable, Equatable {
        
        enum Default: StringRepresentable, Equatable {
            case `nil`
            case value(String)
            
            var stringRepresentation: String {
                switch self {
                case .nil:               return "nil"
                case .value(let string): return string
                }
            }
        }
        
        let alias:     String
        let name:      String
        let type:      String
        let `default`: Default?
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(alias: String? = nil, name: String, type: String, default: Default? = nil) {
            self.alias   = alias ?? ""
            self.name    = name
            self.type    = type
            self.default = `default`
        }
        
        // ----------------------------------
        //  MARK: - String Representation -
        //
        var stringRepresentation: String {
            let alias      = self.alias.isEmpty ? "" : "\(self.alias) "
            let assignment = self.default != nil ? " = \(self.default!.stringRepresentation)" : ""
            
            return "\(alias)\(self.name): \(self.type)\(assignment)"
        }
    }
}

extension Swift.Method.Parameter.Default {
    static func ==(lhs: Swift.Method.Parameter.Default, rhs: Swift.Method.Parameter.Default) -> Bool {
        return lhs.stringRepresentation == rhs.stringRepresentation
    }
}

extension Swift.Method.Parameter {
    static func ==(lhs: Swift.Method.Parameter, rhs: Swift.Method.Parameter) -> Bool {
        return lhs.alias == rhs.alias &&
            lhs.name     == rhs.name &&
            lhs.type     == rhs.type &&
            lhs.default?.stringRepresentation ?? "" == rhs.default?.stringRepresentation ?? ""
    }
}

extension Swift.Method {
    static func +=(lhs: Swift.Method, rhs: Swift.Line) {
        lhs.add(child: rhs)
    }
    
    static func ==(lhs: Swift.Method, rhs: Swift.Method) -> Bool {
        return lhs.visibility     == rhs.visibility &&
            lhs.name              == rhs.name &&
            lhs.returnType  ?? "" == rhs.returnType  ?? "" &&
            lhs.parameters  ?? [] == rhs.parameters  ?? [] &&
            lhs.annotations ?? [] == rhs.annotations ?? []
    }
}
