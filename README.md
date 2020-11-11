# flutter_auth

This is a simple flutter application that enables its users to:
*   **Sign up** into the app.
*   **Sign in** into their accounts.
*   **Sign out** from the app.
*   **Display** other users of the app.
*   **Notify** users upon successful signing up of new app users.

## Development 
*   [Flutter](https://flutter.dev/)
*   [ParseServer](https://back4app.com/)(Back4App)
*   [Firebase](https://google.firebase.com/)


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

### Sign up page
Sign up using a username
![alt text][sign_up_page]{width=300px}
### Push notificationse
Push Notifications are triggered from the client-side to all registered app users.
**NOTE**: Push notifications are only visible when connected to the internet at the moment the user signs-up, while your own app is **running in the background**.

Notification from the status bar.
![alt text][status_bar_push_notification]{width=300px}

Notification from the lock screen.
![alt text][lock_screen_push_notification]{width=300px}

### Sign in page
![alt text][sign_in_page]{width=300px}

### Home page
<img src="./assets/sign_up_page.png" width="250"/>
![](./assets/sign_up_page.png = 250x)
![alt text][home_page]{width=300px}

### Users Page
![alt text][users_page]{width=300px}

[//]: # (Image References)
[sign_in_page]: ./assets/sign_in_page.png  = 250x
[sign_up_page]: ./assets/sign_up_page.png
[home_page]: ./assets/home_page.png
[users_page]: ./assets/users_page.png
[status_bar_push_notification]: ./assets/status_bar_push_notification.png
[lock_screen_push_notification]: ./assets/lock_screen_push_notification.png
