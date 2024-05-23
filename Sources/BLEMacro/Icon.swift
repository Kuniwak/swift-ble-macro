import Foundation


public struct Icon: RawRepresentable, Equatable {
    public typealias RawValue = String

    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public static let left = Icon(rawValue: "LEFT")
    public static let up = Icon(rawValue: "UP")
    public static let home = Icon(rawValue: "HOME")
    public static let down = Icon(rawValue: "DOWN")
    public static let right = Icon(rawValue: "RIGHT")
    public static let rewind = Icon(rawValue: "REWIND")
    public static let play = Icon(rawValue: "PLAY")
    public static let pause = Icon(rawValue: "PAUSE")
    public static let stop = Icon(rawValue: "STOP")
    public static let forward = Icon(rawValue: "FORWARD")
    public static let magic = Icon(rawValue: "MAGIC")
    public static let physicalWeb = Icon(rawValue: "PHYSICAL_WEB")
    public static let eddystone = Icon(rawValue: "EDDYSTONE")
    public static let nordic = Icon(rawValue: "NORDIC")
    public static let lock = Icon(rawValue: "LOCK")
    public static let alarm = Icon(rawValue: "ALARM")
    public static let settings = Icon(rawValue: "SETTINGS")
    public static let bluetooth = Icon(rawValue: "BLUETOOTH")
    public static let wifi = Icon(rawValue: "WIFI")
    public static let star = Icon(rawValue: "STAR")
    public static let plus = Icon(rawValue: "PLUS")
    public static let minus = Icon(rawValue: "MINUS")
    public static let brightnessHigh = Icon(rawValue: "BRIGHTNESS_HIGH")
    public static let brightnessLow = Icon(rawValue: "BRIGHTNESS_LOW")
    public static let download = Icon(rawValue: "DOWNLOAD")
    public static let upload = Icon(rawValue: "UPLOAD")
    public static let print = Icon(rawValue: "PRINT")
    public static let flash = Icon(rawValue: "FLASH")
    public static let flashOff = Icon(rawValue: "FLASH_OFF")
    public static let ledOn = Icon(rawValue: "LED_ON")
    public static let ledOff = Icon(rawValue: "LED_OFF")
    public static let battery = Icon(rawValue: "BATTERY")
    public static let info = Icon(rawValue: "INFO")
    public static let message = Icon(rawValue: "MESSAGE")
    public static let rocket = Icon(rawValue: "ROCKET")
    public static let parachute = Icon(rawValue: "PARACHUTE")
    public static let pikachu = Icon(rawValue: "PIKACHU")
    public static let number1 = Icon(rawValue: "NUMBER_1")
    public static let number2 = Icon(rawValue: "NUMBER_2")
    public static let number3 = Icon(rawValue: "NUMBER_3")
    public static let number4 = Icon(rawValue: "NUMBER_4")
    public static let number5 = Icon(rawValue: "NUMBER_5")
    public static let number6 = Icon(rawValue: "NUMBER_6")
    public static let number7 = Icon(rawValue: "NUMBER_7")
    public static let number8 = Icon(rawValue: "NUMBER_8")
    public static let number9 = Icon(rawValue: "NUMBER_9")
    public static let close = Icon(rawValue: "CLOSE")
    
    
    public static let attribute = "icon"
    
    
    public static func parse(xml: XMLElement) -> Result<Icon, MacroXMLError> {
        guard let iconString = xml.attribute(forName: attribute)?.stringValue else {
            return .failure(.missingAttribute(element: xml.name, attribute: attribute))
        }
        
        switch iconString {
        case left.rawValue:
            return .success(left)
        case up.rawValue:
            return .success(up)
        case home.rawValue:
            return .success(home)
        case down.rawValue:
            return .success(down)
        case right.rawValue:
            return .success(right)
        case rewind.rawValue:
            return .success(rewind)
        case play.rawValue:
            return .success(play)
        case pause.rawValue:
            return .success(pause)
        case stop.rawValue:
            return .success(stop)
        case forward.rawValue:
            return .success(forward)
        case magic.rawValue:
            return .success(magic)
        case physicalWeb.rawValue:
            return .success(physicalWeb)
        case eddystone.rawValue:
            return .success(eddystone)
        case nordic.rawValue:
            return .success(nordic)
        case lock.rawValue:
            return .success(lock)
        case alarm.rawValue:
            return .success(alarm)
        case settings.rawValue:
            return .success(settings)
        case bluetooth.rawValue:
            return .success(bluetooth)
        case wifi.rawValue:
            return .success(wifi)
        case star.rawValue:
            return .success(star)
        case plus.rawValue:
            return .success(plus)
        case minus.rawValue:
            return .success(minus)
        case brightnessHigh.rawValue:
            return .success(brightnessHigh)
        case brightnessLow.rawValue:
            return .success(brightnessLow)
        case download.rawValue:
            return .success(download)
        case upload.rawValue:
            return .success(upload)
        case print.rawValue:
            return .success(print)
        case flash.rawValue:
            return .success(flash)
        case flashOff.rawValue:
            return .success(flashOff)
        case ledOn.rawValue:
            return .success(ledOn)
        case ledOff.rawValue:
            return .success(ledOff)
        case battery.rawValue:
            return .success(battery)
        case info.rawValue:
            return .success(info)
        case message.rawValue:
            return .success(message)
        case rocket.rawValue:
            return .success(rocket)
        case parachute.rawValue:
            return .success(parachute)
        case pikachu.rawValue:
            return .success(pikachu)
        case number1.rawValue:
            return .success(number1)
        case number2.rawValue:
            return .success(number2)
        case number3.rawValue:
            return .success(number3)
        case number4.rawValue:
            return .success(number4)
        case number5.rawValue:
            return .success(number5)
        case number6.rawValue:
            return .success(number6)
        case number7.rawValue:
            return .success(number7)
        case number8.rawValue:
            return .success(number8)
        case number9.rawValue:
            return .success(number9)
        case close.rawValue:
            return .success(close)
        default:
            return .failure(.notSupportedIcon(icon: iconString))
        }
    }
}
