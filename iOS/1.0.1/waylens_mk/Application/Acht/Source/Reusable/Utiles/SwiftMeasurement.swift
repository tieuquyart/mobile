import Foundation

public extension Double {

    func measurement<T: Unit>(unit: T) -> Measurement<T> {
        return Measurement(value: self, unit: unit)
    }

    func measurementLength(unit: UnitLength) -> Measurement<UnitLength> {
        return measurement(unit: unit)
    }

    func measurementDuration(unit: UnitDuration) -> Measurement<UnitDuration> {
        
        return measurement(unit: unit)
    }
    
}
//
public extension Int {

    func measurement<T: Unit>(unit: T) -> Measurement<T> {
        //print("self", self)
      return Double(self).measurement(unit: unit)
        
    }

    func measurementLength(unit: UnitLength) -> Measurement<UnitLength> {
        return measurement(unit: unit)
    }

    func measurementDuration(unit: UnitDuration) -> Measurement<UnitDuration> {
        return measurement(unit: unit)
    }

}



extension Measurement where UnitType == UnitLength {

    private var localeUnit: UnitType {
        return .kilometers
    }

    public var localeValue: Double {
        return converted(to: localeUnit).value
    }
    
   

    public var localeStringValue: String {
        return String(format: "%.1f", localeValue / 1000)
//        if localeValue.rounded() < 10000 {
//            return String(format: "%.1f", localeValue / 1000)
//        }
////        else if localeValue.rounded() < 100000 {
////            return String(format: "%d", Int64(localeValue / 1000))
////        }
////        else if localeValue.rounded() < 100000 {
////            return String(format: "%.1f", localeValue / 1000)
////                }
//        else if (localeValue / 1000).rounded() < 1000 {
//            return String(format: "%.1f", localeValue / 1000)
//        }
//        else {
//            return String(format: "%.3fM", localeValue / 1000000)
//        }
    
//        return String(format: "%d", Int64(localeValue.rounded()))
    }

    public var localeStringValueWithUnit: String {
        //return String(format: "%.1f %@", localeValue, NSLocalizedString("miles", comment: "miles"))
        return String(format: "%.1f %@", localeValue / 1000, NSLocalizedString("kilometers", comment: "kilometers"))
    }

}

extension Measurement where UnitType == UnitDuration {

    private var localeUnit: UnitType {
        return .hours
    }
 
    public var localeValue: Double {
        return converted(to: localeUnit).value
    }
    

    public var localeStringValue: String {
        return String(format: "%.1f", localeValue)
    }

    public var localeStringValueWithUnit: String {
        return String(format: "%.1f %@", localeValue , NSLocalizedString("hour(s)", comment: "hour(s)"))
    }

}

extension Measurement where UnitType == UnitElectricPotentialDifference {

    private var localeUnit: UnitType {
        return .millivolts
    }

    public var localeValue: Int {
        return Int(converted(to: localeUnit).value)
    }

    public var localeStringValue: String {
        return String(format: "%d", localeValue)
    }

    public var localeStringValueWithUnit: String {
        return String(format: "%d %@", localeValue, NSLocalizedString("mV", comment: "mV"))
    }

}
