

# 🌐 SafeGo – Emergency Safety App for Travelers

**SafeGo** is a safety-first mobile application that provides real-time emergency support for travelers, helping them stay protected by automating SOS alerts, tracking responsiveness, and giving quick access to emergency contacts and services based on their location.

---

## 🚀 Core Features

### 🔒 1. Passwordless Authentication
- Seamless login using **email-based magic links** powered by **Supabase**.
- No need to remember passwords – secure and user-friendly.

### 📍 2. Real-Time Location-Based Emergency Services
- Continuously fetches the user's live GPS location.
- Displays **country-specific emergency services** such as:
  - 🚓 Police
  - 🚒 Fire Station
  - 🚑 Ambulance
  - 🏛️ Indian Embassy (if abroad)

### 👥 3. Emergency Contact Directory by Region
- Automatically fetches and displays **regional emergency services** based on location.
- Allows quick direct contact in case of emergency.

### 📞 4. Personal Emergency Contacts
- Users can add and manage **trusted family and friends** as personal emergency contacts.
- Contact data is securely stored in **Supabase** and used in alerts.

### 🆘 5. One-Tap SOS Alerts
- Instantly sends an SOS with:
  - User's current location
  - Reason for alert
  - Timestamp
- Sends alerts to:
  - Personal emergency contacts (via SMS)
  - Displays local emergency services nearby

### ⏱️ 6. Alert Responsiveness System
- Periodically prompts the user: **“Are you safe?”**
- If the user doesn't respond within 2 minutes:
  - Automatically logs an **Unresponsive Alert** in the alert history
  - Displays it with **yellow severity**, indicating concern

### 🕓 7. Periodic Check-In Settings
- User can **enable or disable** periodic responsiveness checks.
- Choose interval: 2 mins, 1 hr, 2 hrs, or 4 hrs.
- Runs in the background even if the app is closed.

---

## 🖼️ Screenshots

| SOS Trigger | Alert Prompt | Emergency Directory | Check-In Settings |
|------------|---------------|---------------------|-------------------|
| ![sos](https://github.com/user-attachments/assets/c70997cd-25cd-4ad3-a52e-5193d03d94f9) | ![alert](https://github.com/user-attachments/assets/8db06f09-0958-4e91-99ae-3b7925ad2ffa) | ![directory](https://github.com/user-attachments/assets/1d20090f-e853-43fe-b2d7-d6d068323b72) | ![settings](https://github.com/user-attachments/assets/88860abc-444c-4072-a612-380a336dd40c) |

---

## 🛠️ Tech Stack

| Layer               | Technologies Used                           |
|---------------------|----------------------------------------------|
| 💻 App Framework     | Flutter                                      |
| 🔐 Auth & Database   | Supabase (email magic links, PostgreSQL)     |
| 📍 Location Services | Geolocator, Geocoding, Google Maps API       |
| 🔔 Notifications     | flutter_local_notifications                  |
| 🕒 Background Tasks  | WorkManager                                  |
| 📦 Local Storage     | shared_preferences, flutter_secure_storage   |
| 📞 SMS Integration   | Telephony Plugin                             |
| 🧭 Time Utils        | intl, timezone packages                      |

---

## 🧠 How It Works

1. On login, user is authenticated using **Supabase email magic link**.
2. **Live GPS** fetches the user's location and country.
3. Emergency services and embassy details are displayed accordingly.
4. **User can send an SOS** or receive periodic “Are you safe?” alerts.
5. If user doesn’t respond within 2 minutes:
   - An **auto SOS** is triggered.
   - An "Unresponsive" alert is logged.
6. Alert history is maintained for review and tracking.

---

## ✅ Project Highlights

- Built for **solo travelers, tourists, or emergency-prone situations**.
- Ensures **safety even when the app is minimized** or user is inactive.
- Lightweight, user-friendly, and **privacy-conscious** design.

---

## 🔧 Development Notes (Backend setup used during testing)

While the core system runs in Flutter with Supabase, Node.js scripts were used during testing for:
- Location fetching mock
- SOS testing
- Email triggers via Gmail SMTP

```bash
npm install node-fetch node-cron dotenv
npm install @supabase/supabase-js express cors body-parser
