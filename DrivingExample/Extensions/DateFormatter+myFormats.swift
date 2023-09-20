//
//  DateFormatter+myFormats.swift
//  Hekate
//
//  Created by Juraj Antas on 22/11/2018.
//  Copyright © 2018 Juraj Antas. All rights reserved.
//

import Foundation

extension DateFormatter {
    class func myTripFormat() -> DateFormatter {
        let formatter : DateFormatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
    
    /*
     dateFormatter = [[NSDateFormatter alloc] init];
     NSLocale *enUSPOSIXLocale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
     [dateFormatter setLocale:enUSPOSIXLocale];
     [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"];
     [dateFormatter setCalendar:[NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian]];
     */

    class func myIsoFormater() ->DateFormatter {
        let formatter : DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "enUSPOSIXLocale")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
    
    class func myIsoParser() ->DateFormatter {
        let formatter : DateFormatter = DateFormatter()
        formatter.locale = Locale(identifier: "enUSPOSIXLocale")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .gregorian)
        return formatter
    }
}
