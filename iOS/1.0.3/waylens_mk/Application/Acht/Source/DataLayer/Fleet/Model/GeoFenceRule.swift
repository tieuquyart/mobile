//
//  GeoFenceRule.swift
//  Fleet
//
//  Created by forkon on 2020/5/13.
//  Copyright © 2020 waylens. All rights reserved.
//

public typealias GeoFenceRuleId = String

public struct GeoFenceRule: Decodable, Equatable {
    let fenceRuleID: GeoFenceRuleId
    let name: String
    let fenceID: GeoFenceId
    let type: GeoFenceRuleTypes
    let scope: GeoFenceRuleScope
    let createTime: Date
    let vehicleList: [VehicleId]

    private enum CodingKeys: String, CodingKey {
        case fenceRuleID
        case name
        case fenceID
        case type
        case scope
        case createTime
        case vehicleList
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        fenceRuleID = try values.decode(String.self, forKey: .fenceRuleID)
        name = try values.decode(String.self, forKey: .name)
        fenceID = try values.decode(GeoFenceId.self, forKey: .fenceID)
        type = try values.decode(GeoFenceRuleTypes.self, forKey: .type)
        scope = try values.decode(GeoFenceRuleScope.self, forKey: .scope)
        createTime = Date(millisecondsSince1970: try values.decode(TimeInterval.self, forKey: .createTime))
        vehicleList = (try? values.decode([String].self, forKey: .vehicleList)) ?? []
    }

}

public struct GeoFenceRuleForEdit: Equatable {
    public var fenceRuleID: GeoFenceRuleId?
    public var name: String?
    public var fenceID: GeoFenceId?
    public var type: GeoFenceRuleTypes?
    public var scope: GeoFenceRuleScope?
    public var vehicleList: [VehicleId]?

    public init(rule: GeoFenceRule? = nil) {
        self.fenceRuleID = rule?.fenceRuleID
        self.name = rule?.name
        self.fenceID = rule?.fenceID
        self.type = rule?.type
        self.scope = rule?.scope
        self.vehicleList = rule?.vehicleList
    }
}

typealias GeoFenceRuleReducer = (inout GeoFenceRuleForEdit) -> ()

public struct GeoFenceRuleTypes: OptionSet, Codable, Equatable {
    public typealias RawValue = Int

    public var rawValue: Int

    public static let enter = GeoFenceRuleTypes(rawValue: 1 << 0)
    public static let exit = GeoFenceRuleTypes(rawValue: 1 << 1)

    private enum GeoFenceRuleTypeString: String {
        case enter
        case exit
    }

    public var stringArrayValue: [String] {
        var retval: [String] = []

        if self.contains(.exit) {
            retval.append(GeoFenceRuleTypeString.exit.rawValue)
        }

        if self.contains(.enter) {
            retval.append(GeoFenceRuleTypeString.enter.rawValue)
        }

        return retval
    }

    public init(rawValue: GeoFenceRuleTypes.RawValue) {
        self.rawValue = rawValue
    }

    public init(stringValues: [String]) {
        var types: GeoFenceRuleTypes = GeoFenceRuleTypes()
        for stringValue in stringValues {
            switch stringValue.lowercased() {
            case GeoFenceRuleTypeString.exit.rawValue:
                types = types.union(.exit)
            case GeoFenceRuleTypeString.enter.rawValue:
                types = types.union(.enter)
            default:
                continue
            }
        }

        self = types
    }

    public init(from decoder: Decoder) throws {
        var typeRaw = try? decoder.singleValueContainer().decode([String].self)

        if typeRaw == nil {
            typeRaw = [try decoder.singleValueContainer().decode(String.self)]
        }

        self = GeoFenceRuleTypes(stringValues: typeRaw!)
    }

}

extension GeoFenceRuleTypes: CustomStringConvertible {

    public var description: String {
        var description: [String] = []

        if contains(.enter) {
            description.append(NSLocalizedString("Enter", comment: "Geo-fence Rule"))
        }

        if contains(.exit) {
            description.append(NSLocalizedString("Exit", comment: "Geo-fence Rule"))
        }

        return description.joined(separator: NSLocalizedString(" and ", comment: "and"))
    }

}

public enum GeoFenceRuleScope: String, Equatable, Decodable {
    case all
    case specific
}
