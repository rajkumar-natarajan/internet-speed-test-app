# Internet Speed Test App

A React Native application to test internet connection speed.

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js 20 or higher
- Java Development Kit (JDK) 17
  ```bash
  brew install openjdk@17
  ```
- Xcode 15+ (for iOS development)
- Android Studio (for Android development)
- CocoaPods (for iOS dependencies)
  ```bash
  sudo gem install cocoapods
  ```

## Environment Setup

1. **Configure Java 17**
   ```bash
   # Create symlink for Java 17
   sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

   # Add to your shell profile (.zshrc or .bash_profile)
   echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

2. **Android Setup**
   - Install Android Studio
   - Install Android SDK (via Android Studio SDK Manager)
   - Create a `local.properties` file in the `android` directory:
     ```bash
     echo "sdk.dir=$HOME/Library/Android/sdk" > android/local.properties
     ```

## Project Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/rajkumar-natarajan/internet-speed-test-app.git
   cd internet-speed-test-app
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **iOS Setup**
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Running the App

### iOS

1. **Using Xcode (Recommended)**
   ```bash
   npm run ios-xcode
   ```
   Then in Xcode:
   - Select a simulator or device
   - Click the Run button (▶️) or press Cmd + R

2. **Using Command Line**
   ```bash
   npm run ios
   ```

### Android

1. **Start an Android Emulator** (via Android Studio)
   - Open Android Studio
   - Open Tools -> Device Manager
   - Launch your preferred emulator

2. **Run the app**
   ```bash
   npm run android
   ```

## Development

1. **Start Metro Bundler**
   ```bash
   npm start
   ```

2. **Run Tests**
   ```bash
   npm test
   ```

3. **Lint Code**
   ```bash
   npm run lint
   ```

## Troubleshooting Guide

### Environment Setup Issues

1. **Node.js Version Issues**
   ```bash
   # Check Node version
   node -v   # Should be 20 or higher

   # If needed, install/update Node using nvm
   nvm install 20
   nvm use 20
   ```

2. **Java Version Issues**
   ```bash
   # Check Java version
   java -version   # Should be 17

   # Install Java 17 if needed
   brew install openjdk@17

   # Configure Java 17
   sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
   echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```

### iOS Development Issues

1. **CocoaPods Installation Issues**
   ```bash
   # Install/Update CocoaPods
   sudo gem install cocoapods

   # If you get permissions errors
   sudo gem uninstall cocoapods
   brew install cocoapods
   ```

2. **Pod Install Issues**
   ```bash
   # Complete pod reset
   cd ios
   pod deintegrate
   pod cache clean --all
   rm -rf Pods/
   rm -rf ~/Library/Caches/CocoaPods
   rm Podfile.lock
   pod setup
   pod install --repo-update
   ```

3. **Build & Sandbox Permission Issues**
   If you encounter rsync errors or permission issues during build:
   ```bash
   # Reset Xcode command line tools
   sudo xcode-select --reset

   # Clean all build artifacts
   cd ios
   rm -rf build/ DerivedData/ Pods/ Podfile.lock
   cd ~/Library/Developer/Xcode
   rm -rf DerivedData/InternetSpeedTestApp-*

   # Reinstall pods
   cd <project>/ios
   pod install --repo-update

   # Fix build directory permissions
   sudo chown -R $(whoami) build
   sudo chmod -R 755 build

   # Fix Xcode DerivedData permissions
   sudo chown -R $(whoami) ~/Library/Developer/Xcode/DerivedData
   sudo chmod -R 755 ~/Library/Developer/Xcode/DerivedData
   ```

4. **Metro Bundler Issues**
   ```bash
   # If Metro is already running on port 8081
   lsof -i :8081 | grep LISTEN | awk '{print $2}' | xargs kill -9

   # Clear Metro cache
   rm -rf ~/Library/Developer/Xcode/DerivedData/*
   rm -rf $TMPDIR/metro-*
   rm -rf $TMPDIR/haste-map-*
   ```

5. **Xcode Build Issues**
   - Clean build: Product -> Clean Build Folder (Shift + Cmd + K)
   - Reset package caches: File -> Packages -> Reset Package Caches
   - Delete derived data: Xcode -> Preferences -> Locations -> Derived Data -> Delete
   - If issues persist:
     ```bash
     # Clean Xcode caches
     rm -rf ~/Library/Developer/Xcode/DerivedData
     rm -rf ~/Library/Caches/com.apple.dt.Xcode
     ```

### Android Development Issues

1. **SDK Location Issues**
   ```bash
   # Create/update local.properties
   echo "sdk.dir=$HOME/Library/Android/sdk" > android/local.properties

   # Verify Android SDK installation
   ls $HOME/Library/Android/sdk
   ```

2. **Gradle Issues**
   ```bash
   # Clean Gradle cache
   cd android
   ./gradlew clean
   rm -rf ~/.gradle/caches/
   ./gradlew --refresh-dependencies
   
   # If Gradle wrapper issues
   cd android
   rm -rf gradle/wrapper
   ./gradlew wrapper
   ```

3. **Android Build Tools Issues**
   ```bash
   # Using sdkmanager
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "build-tools;33.0.0"
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager --install "platforms;android-33"
   ```

### TypeScript and React Native Issues

1. **TypeScript Configuration Issues**
   ```bash
   # Reset TypeScript configuration
   rm -rf tsconfig.json
   cp node_modules/@react-native/typescript-config/tsconfig.json .
   
   # Add necessary compiler options
   {
     "extends": "@react-native/typescript-config",
     "compilerOptions": {
       "esModuleInterop": true,
       "jsx": "react-jsx",
       "skipLibCheck": true
     }
   }
   ```

2. **React Native CLI Issues**
   ```bash
   # Reset React Native CLI
   npm uninstall -g react-native-cli
   npm install -g @react-native-community/cli

   # Clear npm cache if needed
   npm cache clean --force
   ```

### General Debugging Tips

1. **Clean Project**
   ```bash
   # Remove all build artifacts and dependencies
   rm -rf node_modules/
   rm -rf ios/Pods/
   rm -rf android/build/
   rm -rf android/app/build/
   npm cache clean --force
   
   # Reinstall everything
   npm install
   cd ios && pod install && cd ..
   ```

2. **Reset Git Repository**
   ```bash
   # If you need to reset to a clean state (careful!)
   git clean -fdx
   git reset --hard
   ```

3. **Development Environment Health Check**
   ```bash
   # Check React Native environment
   npx react-native doctor
   
   # Check iOS environment
   xcodebuild -version
   pod --version
   
   # Check Android environment
   java -version
   adb devices
   ```

## Project Structure

```
internet-speed-test-app/
├── __tests__/          # Test files
├── android/            # Android native code
├── ios/               # iOS native code
├── src/               # Source files
│   ├── components/    # React components
│   ├── screens/       # Screen components
│   └── utils/         # Utility functions
└── App.tsx           # Root component
```

## Contributing

1. Create a new branch
2. Make your changes
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details

Open `App.tsx` in your text editor of choice and make some changes. When you save, your app will automatically update and reflect these changes — this is powered by [Fast Refresh](https://reactnative.dev/docs/fast-refresh).

When you want to forcefully reload, for example to reset the state of your app, you can perform a full reload:

- **Android**: Press the <kbd>R</kbd> key twice or select **"Reload"** from the **Dev Menu**, accessed via <kbd>Ctrl</kbd> + <kbd>M</kbd> (Windows/Linux) or <kbd>Cmd ⌘</kbd> + <kbd>M</kbd> (macOS).
- **iOS**: Press <kbd>R</kbd> in iOS Simulator.

## Congratulations! :tada:

You've successfully run and modified your React Native App. :partying_face:

### Now what?

- If you want to add this new React Native code to an existing application, check out the [Integration guide](https://reactnative.dev/docs/integration-with-existing-apps).
- If you're curious to learn more about React Native, check out the [docs](https://reactnative.dev/docs/getting-started).

# Troubleshooting

If you're having issues getting the above steps to work, see the [Troubleshooting](https://reactnative.dev/docs/troubleshooting) page.

# Learn More

To learn more about React Native, take a look at the following resources:

- [React Native Website](https://reactnative.dev) - learn more about React Native.
- [Getting Started](https://reactnative.dev/docs/environment-setup) - an **overview** of React Native and how setup your environment.
- [Learn the Basics](https://reactnative.dev/docs/getting-started) - a **guided tour** of the React Native **basics**.
- [Blog](https://reactnative.dev/blog) - read the latest official React Native **Blog** posts.
- [`@facebook/react-native`](https://github.com/facebook/react-native) - the Open Source; GitHub **repository** for React Native.
