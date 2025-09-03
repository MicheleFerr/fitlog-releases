# Alternative: Use Library/Sounds Directory

Se i suoni non funzionano dalla Documents directory, iOS richiede che i custom notification sounds siano in `Library/Sounds/`:

```swift
private func copyAudioFileToLibrarySounds(fileName: String, filePath: String) {
    guard let libraryPath = FileManager.default.urls(for: .libraryDirectory, 
                                                     in: .userDomainMask).first else { return }
    
    let soundsPath = libraryPath.appendingPathComponent("Sounds")
    
    // Create Sounds directory if needed
    try? FileManager.default.createDirectory(at: soundsPath, 
                                            withIntermediateDirectories: true)
    
    let destinationURL = soundsPath.appendingPathComponent("\(fileName).caf")
    
    // Copy with no protection
    try? FileManager.default.copyItem(atPath: filePath, toPath: destinationURL.path)
    try? FileManager.default.setAttributes(
        [.protectionKey: FileProtectionType.none],
        ofItemAtPath: destinationURL.path
    )
}
```

Poi in BackgroundAudioManager, usa solo il nome del file:
```swift
content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
```

iOS cercherà automaticamente in:
1. Bundle root
2. Library/Sounds
3. Documents (su alcuni iOS)