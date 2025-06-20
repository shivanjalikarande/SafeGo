# 🌍 SafeGo: Emergency Support System for Travelers

SafeGo is a smart emergency assistance application designed to protect travelers—especially those exploring unfamiliar countries—by automatically detecting distress situations and alerting personal contacts and embassies with real-time location information.

## 🚀 Features

### ✅ 1. Real-Time Location Tracking
- Continuously fetches user’s live location.
- Determines the country and nearest local emergency services (police, fire, hospitals, embassy).

### ✅ 2. Auto-Fetch Emergency Directory
- Based on GPS and country code, auto-fetch:
  - Police station
  - Ambulance
  - Fire services
  - Indian Embassy (if user is abroad)

### ✅ 3. Pre-Saved Personal Emergency Contacts
- Users can add trusted personal contacts.
- Contacts are notified via SMS in case of an SOS alert.

### ✅ 4. Smart SOS Button
- One-click emergency SOS trigger.
- Sends:
  - User's live location
  - Time
  - Custom message
- Sends SMS to personal contacts and displays nearby services.

### ✅ 5. Unresponsive User Detection
- SOS trigger starts a countdown.
- If user doesn’t cancel within X seconds:
  - Automatically sends alert email to the Indian Embassy (if abroad).
  - Optionally initiates auto-call to local emergency number (configurable).

### ✅ 6. Country-Specific Embassy Support
- Automatically detects user's country.
- Shows embassy contact info (email, phone, Google Maps link).
- If user is abroad and unresponsive, embassy is notified.

---

## 📱 Screenshots
![image](https://github.com/user-attachments/assets/c70997cd-25cd-4ad3-a52e-5193d03d94f9)
![image](https://github.com/user-attachments/assets/8db06f09-0958-4e91-99ae-3b7925ad2ffa)
![image](https://github.com/user-attachments/assets/1d20090f-e853-43fe-b2d7-d6d068323b72)
![image](https://github.com/user-attachments/assets/88860abc-444c-4072-a612-380a336dd40c)



---

## ⚙️ Tech Stack

| Component        | Technology              |
|------------------|--------------------------|
| Frontend         | Flutter                  |
| Backend          | Node.js (Express.js)     |
| Location API     | Google Maps Geolocation API |
| Messaging API    | Twilio / SMS Gateway     |
| Email API        | Nodemailer / Gmail SMTP  |
| Database         | PostgreSQL - Supabase   |
| Deployment       | Railway / Vercel / Render |

---

## 🧠 How It Works

1. On app launch, user's location is fetched using GPS.
2. Based on location:
   - Nearby emergency services are fetched.
   - Country is detected to display embassy.
3. SOS button sends real-time alert to:
   - Emergency contacts (via SMS)
   - Embassy (via email if unresponsive)
4. Countdown timer checks if user cancels the alert.
5. Embassy gets notified with name, GPS link, and timestamp.

---


Backend :

1. npm install node-fetch node-cron dotenv
2. npm install @supabase/supabase-js express cors body-parser
3. 
