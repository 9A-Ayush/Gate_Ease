# 🏡 GateEase -- Smart Society Management App

> **Modernizing Society Management with Digital Security, Payments,
> Social Engagement & Local Marketplace**

![Banner](https://your-banner-link.com)
`<!-- optional banner if you have one -->`{=html}

------------------------------------------------------------------------

## 📖 Overview

**GateEase** is a **next-generation smart society management mobile
app** built with **Flutter & Firebase**.\
It helps societies and gated communities manage **residents, guards,
vendors, payments, visitors, and communication** --- all in one secure,
real-time platform.

The app introduces new features like an **inbuilt Social Feed** for
community engagement and a **Shopping Page** for buying local goods and
services.

------------------------------------------------------------------------

## 🎯 Key Features

### 👥 Multi-Role Access

-   **Resident** → Approve/deny visitors, raise complaints, pay bills,
    book amenities, shop online, and post on social feed\
-   **Admin** → Manage all users, post announcements, approve vendor
    ads, track payments, and resolve complaints\
-   **Guard** → Log visitor entries, check pre-approved lists, send SOS
    alerts, multi-language support\
-   **Vendor** → List services/products, request ad promotions, sell via
    shopping section

------------------------------------------------------------------------

### 🆕 New Modules

-   **📢 Inbuilt Social Feed** -- Residents can share posts, comment,
    and like updates to foster community engagement.\
-   **🛍️ Shopping Page** -- Buy goods & services within the society from
    trusted vendors with secure payments.

------------------------------------------------------------------------

## 🧰 Tech Stack

  Feature              Technology
  -------------------- --------------------------------------
  Frontend             Flutter (Dart)
  Backend              Firebase Firestore
  Authentication       Firebase Auth (Email, Phone, Google)
  Media Storage        Cloudinary
  Payments             Razorpay SDK
  Notifications        Firebase Cloud Messaging
  Calling System       Agora SDK
  Hosting (Optional)   Firebase Hosting (Admin Web Panel)

------------------------------------------------------------------------

## 🔐 Authentication & Onboarding Flow

-   **Admin Invite Flow:** Secure link → pre-filled role & society →
    auto verification\
-   **Self Signup Flow:** User selects role → chooses country, state,
    society → admin approval required\
-   **Profile Completion:** Each role has its own onboarding fields

------------------------------------------------------------------------

## 📂 Core Modules

1.  Visitor Management 🚪\
2.  Complaints & Escalations 📝\
3.  Amenity Booking 📅\
4.  Bill Payments 💳 (Razorpay)\
5.  Vendor Marketplace 🛍️\
6.  Vendor Ads & Promotions 📢\
7.  **Social Feed (NEW)** 🗨️\
8.  **Shopping Page (NEW)** 🛒\
9.  SOS Emergency Alerts 🚨\
10. Real-time Chat & Calls 📞

------------------------------------------------------------------------

## ☁️ Data Storage

-   **Cloudinary** → Profile images, post images, vendor ads, product
    images\
-   **Firestore** → Users, visitors, complaints, payments, posts,
    products, chats

------------------------------------------------------------------------

## 📞 Communication

-   Real-time **chat** with text + media support\
-   **Voice/Video calling** via Agora\
-   Push notifications for requests, complaints, payments, and ads

------------------------------------------------------------------------

## 🗄️ Firestore Data Example

    users/
    visitors/
    complaints/
    amenities/
    payments/
    vendors/
    ads/
    announcements/
    posts/     <-- Social feed
    products/  <-- Shopping
    messages/
    calls/

------------------------------------------------------------------------

## 📌 Installation

1.  Clone the repo

    ``` bash
    git clone https://github.com/yourusername/GateEase.git
    cd GateEase
    ```

2.  Install dependencies

    ``` bash
    flutter pub get
    ```

3.  Configure Firebase

    -   Add `google-services.json` (Android) and
        `GoogleService-Info.plist` (iOS).\

4.  Run the app

    ``` bash
    flutter run
    ```

------------------------------------------------------------------------

## 🎨 UI/UX

-   **Figma Prototype:** [View
    Design](https://www.figma.com/design/JjiIYOj2nT8DJunTEIbaut/Gate-Ease-2?node-id=0-1)\
-   **Design System:** Material 3 with modern color palette

------------------------------------------------------------------------

## 👨‍💻 Author

**Ayush Kumar** -- Full Stack Flutter Developer\
📍 India

🔗 [GitHub](https://github.com/9A-Ayush) \|
[LinkedIn](http://www.linkedin.com/in/ayush-kumar-849a1324b) \|
[Instagram](https://www.instagram.com/ayush_ix_xi)

------------------------------------------------------------------------

## 📜 License

This project is licensed under the MIT License.
