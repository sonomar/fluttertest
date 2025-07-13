# DEINS - FEATURING KLOPPOCAR

## deins_mobile_core

"YOU NEVER WALK ALONE."
Kloppocar is an art project that makes use of the last car in Germany owned by world renown athlete Jürgen Klopp before he left for his trainer job in Liverpool. The art on the Kloppocar depicts his life, and also historical moments in football history, famous signatures, and more. The overall goal of this project is to collect donations for groups that take care of kids in need.

## Getting Started

1. Clone the repo
2. Go to the file '.env' and make sure the appropriate app instance (dev or production) is uncommented. Do not start the app with both instances uncommented. This env is not secured like a webapp, and can be present on github
3. In your terminal, go to the repo root directory and run 'flutter pub get'
4. Set up any simulators in Android Studio, Xcode, or connect your device
5. In the root directory, run 'flutter run'
6. You will either be asked how you want to run the app or it will start automatcally on devices or simulators
7. Once the app demo is running, type the 'r' key on the running instance to refresh the state if you change the code
8. CTRL + 'c' stops the server session. Closing the app in your simulator or rebooting the simulator will also stop the session

## Deploying the app on Android

1. Make sure the your branch has been pushed to Github. DO NOT PUSH DIRECTLY TO THE MAIN BRANCH. Create your own branch, pull from the Main branch into your branch, push YOUR BRANCH to Github, and create a Pull Request. Once the PR is merged to the main branch, you can continue
2. Update both the version and the release of the app in pubspec.yaml (change 1.0.12+6 to 1.0.13 + 7) and save the document
3. In the root directory of the app, run 'flutter clean && flutter pub get'
4. In the root directory of the app, run 'flutter build apk --release'
5. Go to the directory '/build/app/outputs/apk/release and find the 'app-release.apk' file
6. Send this file to your device and test the app through the apk file.
7. If all tests pass for the apk file, return to the root directory of the project and run 'flutter build appbundle --release'
8. Log into the Google Play Console ('https://developer.android.com/distribute/console') and click on the DEINS Solutions project, then the DEINS app
9. In the 'Test & Release' section on the left side of the console, head to the 'Production' section and click the 'Create new release' button on the top right of the screen
10. Follow instructions to upload the appBundle 'app-release.aab' from /build/app/outputs/bundle/release/app-release.aab, and add other info like update text for the app, after the bundle is successfully uploaded
11. Completing this process will allow you to submit the app for Review
12. When the review is completed, head to the 'Publishing Dashboard' to publish your updates to the Google Play Store and release the new version of the app. This update cannot be undone, but a new version can be submitted fairly quickly to fix an emergency bug

## Deploying the app on iOS

1. Make sure the your branch has been pushed to Github. DO NOT PUSH DIRECTLY TO THE MAIN BRANCH. Create your own branch, pull from the Main branch into your branch, push YOUR BRANCH to Github, and create a Pull Request. Once the PR is merged to the main branch, you can continue
2. Update both the version and the release of the app in pubspec.yaml (change 1.0.12+6 to 1.0.13 + 7) and save the document
3. In the root directory of the app, run 'flutter clean && flutter pub get'
4. In the root directory of the app, run 'flutter build ipa'
5. Go to the directory '/build/ios/archive and open the Runner.xarchive file within using Xcode
6. Follow the directions in Xcode to deploy the app to TestFlight
7. Log into app store connect after at least 20 minutes after the upload is completed. Find the version of the app you uploaded in Testflight and click the 'completion' button (or something similar) located under the name and version of the update. You will be asked if you are using any 3rd party data collection: Answer 'no' to this question and continue. Finally, click on the version number link on the item in testflight to send a message to all testing teams. Make sure to have testers download the app in testflight and test it. Please note that all above steps, including the testing note, are required before the app can be submitted to the iOS app store
8. If the app passes all tests, head to the 'Distribution' tab of App Store Connect and click the '+' sign on the top-left of the main console under the 'iOS App' section. This will create a new distribution. Within this new distribution, you should only need to update the 'What's New in this Update' text and select the build from Testflight that you just confirmed to deploy in the 'Build' section. Once all of this is done, click the 'save' button on the top right of the screen, then click 'submit for review' on the top right of the screen. Accept all other messages until the app is fully submitted for review
9. Manually release the app when the review is approved
10. Completing this process will allow you to submit the app for Review and then Publish it to the iOS app store once the review is accepted. This update cannot be undone, but a new version can be submitted to fix an emergency bug. Keep in mind no matter what this can take at least 8 hours for the revieew to be accepted again, so try not to submit breaking bugs into the app

## App Notes

1. The 'lib' folder in the root directory holds all code and files for the frontend views, styles and processes of the Flutter app. The file 'lib/main.dart' is the first file in the app tree
2. The 'backend' folder in the root directory holds all info on the schema and api built into the RDS MySql database stored on AWS. This backend folder connects to a Lambda system in AWS
3. The 'assets' folder in the root directory holds all asset files (images, videos, 3d-objects etc.) that will be stored in the app when it is deployed. To lower app size, most assets are accessed via AWS S3 buckets
4. The 'android' and 'ios' and 'web' folders contain all device-specific code for deploying to those various devices (info.plist, gradle files, js files etc.). You can navigate into this files if you need to update the podfile or gradle or any other device-specific systems when updating the app
5. The .env file works like any other app .env file, but because this is a mobile app, it should not contain any sensitive, secret codes. Those should be stored on the AWS backend and accessed via private API when necessary.
6. The pubspec.yaml file acts as the main list of plugins, routes for assets and more for the app. Run 'flutter pub get' after updating this file to update any changes you make
7. New plugins can be added with the command 'flutter pub add [plugin_name]'. Similarly, remove plugins safely with 'flutter pub remove [plugin_name]'
8. You can always run 'flutter clean && flutter pub get' if you aren't sure that settings are up to date
