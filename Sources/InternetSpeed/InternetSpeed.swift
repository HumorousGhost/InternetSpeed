import Foundation

open class InternetSpeed {
    
    public static let instance = InternetSpeed()
    
    /// start internet speed
    /// - Parameters:
    ///   - timeInterval: speed time interval
    ///   - downlinkSpeedString: downlink speed string
    ///   - upSpeed: up speed
    public func startMonitor(
        _ timeInterval: TimeInterval = 2,
        downlinkSpeedString: ((String) -> Void)? = nil,
        upSpeedString: ((String) -> Void)? = nil) {
            self.timeInterval = timeInterval
            self.downlinkSpeedString = downlinkSpeedString
            self.upSpeedString = upSpeedString
            self.startSpeed()
        }
    
    /// start internet speed
    /// - Parameters:
    ///   - timeInterval: speed time interval
    ///   - downlinkSpeed: downlink speed, Unit: B
    ///   - upSpeed: up speed, Unit: B
    public func startMonitor(
        _ timeInterval: TimeInterval = 2,
        downlinkSpeed: ((Double) -> Void)? = nil,
        upSpeed: ((Double) -> Void)? = nil) {
        
        self.timeInterval = timeInterval
        self.downlinkSpeed = downlinkSpeed
        self.upSpeed = upSpeed
            self.startSpeed()
    }
    
    /// stop internet speed
    public func stopMonitor() {
        timer.invalidate()
        timer = nil
    }
    
    private func startSpeed() {
        if timer == nil {
            if #available(iOS 10.0, macOS 10.12, *) {
                self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: true, block: { [unowned self] _ in
                    self.getCurrentSpeed()
                })
            } else {
                self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(getCurrentSpeed), userInfo: nil, repeats: true)
            }
        }
    }
    
    /// get internet speed
    @objc private func getCurrentSpeed() {
        var ifadds: UnsafeMutablePointer<ifaddrs>?
        if getifaddrs(&ifadds) == 0 {
            let rawData = unsafeBitCast(ifadds?.pointee.ifa_addr, to: UnsafeMutablePointer<if_data>.self)
            self.receiveData += UInt64(rawData.pointee.ifi_ibytes)
            self.sendData += UInt64(rawData.pointee.ifi_obytes)
        }
        freeifaddrs(ifadds)
        if !self.isFirstTime {
            let iSpeed = Double(self.receiveData - self.lastReceiveData) / self.timeInterval
            self.downlinkSpeed?(iSpeed)
            self.downlinkSpeedString?(getSpeedString(iSpeed))
            let oSpeed = Double(self.sendData - self.lastSendData) / self.timeInterval
            self.upSpeed?(oSpeed)
            self.upSpeedString?(getSpeedString(oSpeed))
        } else {
            self.isFirstTime = false
        }
        
        self.lastReceiveData = self.receiveData
        self.lastSendData = self.sendData
        self.receiveData = 0
        self.sendData = 0
    }
    
    private func getSpeedString(_ speed: Double) -> String {
        var string = ""
        if speed < 1024 {
            string = String(format: "%.2fB/S", speed)
        } else if speed >= 1024 && speed < 1024 * 1024 {
            string = String(format: "%.2KB/S", speed / 1024)
        } else {
            string = String(format: "%.2MB/S", speed / 1024 * 1024)
        }
        return string
    }
    
    
    private var downlinkSpeed: ((Double) -> Void)? = nil
    private var downlinkSpeedString: ((String) -> Void)? = nil
    private var upSpeed: ((Double) -> Void)? = nil
    private var upSpeedString: ((String) -> Void)? = nil
    
    private var timer: Timer!
    private var timeInterval: TimeInterval = 2
    
    private var isFirstTime = true
    private var receiveData: UInt64 = 0
    private var lastReceiveData: UInt64 = 0
    private var sendData: UInt64 = 0
    private var lastSendData: UInt64 = 0
}
