//
//  SemanticColor.swift
//  Gaudi
//
//  Created by Giuseppe Lanza on 04/12/2019.
//  Copyright © 2019 Giuseppe Lanza. All rights reserved.
//

import UIKit

public enum TintColor: CaseIterable {
    case primary
    case secondary

    public static var allCases: [TintColor] {
        return [.primary, .secondary]
    }
}

public enum LabelColor: CaseIterable {
    case primary
    case secondary
    case tertiary
    case quaternary
    /*case placeholder*/
    /*case link*/
    case custom(color: UIColor)
    
    public static var allCases: [LabelColor] {
        return [.primary, .secondary, .tertiary, .quaternary, /*.placeholder, .link*/]
    }
}

public enum FillColor: CaseIterable {
    case primary
    case secondary
    case tertiary
    case quaternary
    case quinary
    case senary
    case septenary
    case octonary
    case custom(color: UIColor)
    
    public static var allCases: [FillColor] {
        return [.primary, .secondary, .tertiary, .quaternary, .quinary, .senary, .septenary, .octonary]
    }

}

public enum BackgroundColor: CaseIterable {
    case primary
    case secondary
    case tertiary
    case quaternary
    case quinary
    case senary
    case septenary
    case octonary
    case mask
    case maskLight
    case highlighted
    case buttonDisabled
    case custom(color: UIColor)
    
    public static var allCases: [BackgroundColor] {
        return [.primary, .secondary, .tertiary, .quaternary, .quinary, .senary, .septenary, .octonary, .mask, .maskLight, .highlighted]
    }
}

public enum GroupedContentBackgroundColor: CaseIterable {
    case primary
    case secondary
    case tertiary
    case custom(color: UIColor)
    
    public static var allCases: [GroupedContentBackgroundColor] {
        return [.primary, .secondary, .tertiary]
    }
}

#if FLEET

public enum TableViewCellBackgroundColor: CaseIterable {
    /* case plain */
    case grouped

    public static var allCases: [TableViewCellBackgroundColor] {
        return [/*.plain, */.grouped]
    }
}

#endif

public enum SeparatorColor: CaseIterable {
    case semiTransparent
    case opaque
    case custom(color: UIColor)
    
    public static var allCases: [SeparatorColor] {
        return [.semiTransparent, .opaque]
    }
}

public enum BorderColor: CaseIterable {
    case primary
    case custom(color: UIColor)

    public static var allCases: [BorderColor] {
        return [.primary]
    }
}

public enum ActivityColor: CaseIterable {
    case buffered
    case heavy
    case hit
    case hardBehavior
    case harshBehavior
    case severeBehavior
    case manual
    case dms
    case motion
    case adas
    case ignition
    case account
    case payment
}

public enum SemanticColor: CaseIterable {
    case bgTabbar
    case tint(TintColor)
    case label(LabelColor)
    case fill(FillColor)
    case background(BackgroundColor)
    /*case groupedBackground(GroupedContentBackgroundColor)*/
    case separator(SeparatorColor)
    case border(BorderColor)
    case activity(ActivityColor)
    case cameraPickerBackground
    case playerContainerBackground
    case textInputAreaBackground
    #if FLEET
    case cardHeaderBackground
    case cardBackground
    case mapFloatingPanelBackground
    case grabberHandleBar
    case tableViewCellBackground(TableViewCellBackgroundColor)
    case parkingStatus
    case timelineAxis
    case timelineMilestonePoint
    case memberTagBackground
    #endif

    public static var allCases: [SemanticColor] {
        var result: [SemanticColor] = []
        result += TintColor.allCases.map { .tint($0) }
        result += LabelColor.allCases.map { .label($0) }
        result += FillColor.allCases.map { .fill($0) }
        result += BackgroundColor.allCases.map { .background($0) }
        /*result += GroupedContentBackgroundColor.allCases.map { .groupedBackground($0) }*/
        result += SeparatorColor.allCases.map { .separator($0) }
        result += BorderColor.allCases.map { .border($0) }
        result += ActivityColor.allCases.map { .activity($0) }
        result += [.cameraPickerBackground]
        result += [.playerContainerBackground]
        result += [.textInputAreaBackground]

        #if FLEET
        result += [.cardHeaderBackground]
        result += [.cardBackground]
        result += [.mapFloatingPanelBackground]
        #endif

        return result
    }
}
