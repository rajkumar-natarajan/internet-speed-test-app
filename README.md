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

## Troubleshooting

### iOS Issues

1. **Pod Install Issues**
   ```bash
   cd ios
   pod deintegrate
   pod cache clean --all
   pod install
   ```

2. **Build Issues**
   - Clean build in Xcode: Product -> Clean Build Folder
   - Delete derived data: Xcode -> Preferences -> Locations -> Derived Data -> Delete

### Android Issues

1. **SDK Location Issues**
   - Verify `local.properties` exists in the android folder
   - Ensure Android SDK is properly installed via Android Studio

2. **Gradle Issues**
   ```bash
   cd android
   ./gradlew clean
   cd ..
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
