# InternetSpeed

Internet Speed Test Tool

## Usage

```swift

InternetSpeed.instance.startMonitor(1) { speed in
    print("downlink speed string " + speed)
} upSpeedString: { speed in
    print("up speed string " + speed)
}

/// or
InternetSpeed.instance.startMonitor(1) { speed in
    print("downlink speed \(speed)")
} upSpeed: { speed in
    print("up speed = \(speed)")
}
```

## Installation

You can add InternetSpeed to an Xcode project by adding it as a package dependency.

1. From the **File** menu, select **Swift Packages** › **Add Package Dependency…**
2. Enter https://github.com/HumorousGhost/InternetSpeed into the package repository URL text field
3. Link **InternetSpeed** to your application target
