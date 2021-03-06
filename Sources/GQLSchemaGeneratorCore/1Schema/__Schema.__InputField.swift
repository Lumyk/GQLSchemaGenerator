//
//  __Schema.__InputField.swift
//  Gryphin
//
//  Created by Dima Bart on 2017-01-01.
//  Copyright © 2017 Dima Bart. All rights reserved.
//

import Foundation

extension __Schema {
    final class __InputField: JsonCreatable, Describeable, Typeable {
        
        let name:         String
        let description:  String?
        let defaultValue: String?
        let type:         __ObjectType
        
        // ----------------------------------
        //  MARK: - Init -
        //
        init(json: JSON) {
            self.name         = json["name"]                  as! String
            self.description  = json["description"]           as? String
            self.defaultValue = json["defaultValue"]          as? String
            self.type         = __ObjectType(json: json["type"] as! JSON)
        }
    }
}
