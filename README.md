# CareConnect – React + XAMPP MySQL

CareConnect is a hospital appointment booking website with staff login and role-based dashboards for administrators, managers and doctors.

## Requirements
- Node.js (LTS)
- XAMPP with Apache and MySQL
- phpMyAdmin

## 1. Set up the database
1. Open XAMPP and start **MySQL** (Apache is useful for phpMyAdmin).
2. Visit `http://localhost/phpmyadmin`.
3. Import the `database.sql` file from this project. It creates/updates `careconnect_db`, doctors, appointments and users.
4. If you already have the older CareConnect database, back it up first, then import the updated SQL. It adds the approval fields and patient notification history. Existing appointments are retained.

## 2. Configure the administrator account
1. Open `server` and copy `.env.example` to `.env`.
2. Set `ADMIN_EMAIL` and a strong `ADMIN_PASSWORD` of at least 8 characters. Change `TOKEN_SECRET` to a long random value.
3. Check the database settings match your XAMPP MySQL setup. The usual local XAMPP settings are user `root` and a blank password.
4. In a terminal opened in the project root, run `npm run install:all`.
5. Run `npm run seed:admin --prefix server` to create the first administrator account. This command will not overwrite an existing account.

## 3. Start CareConnect
Open two terminals in the project root:

**Terminal 1 – backend**
```bash
npm run server
```

**Terminal 2 – frontend**
```bash
npm run client
```

Open the exact **Local** URL printed by Vite (normally `http://localhost:5173`; if that port is busy, Vite may choose `5174`, `5175`, etc.). Check the backend at `http://localhost:5000/api/health`. The frontend URL is not the backend URL.

## Staff roles and duties
- **Admin:** creates staff accounts, selects their role, links doctor accounts to doctor profiles, views system-wide appointment statistics and oversees access.
- **Manager:** reviews every pending request, checks the selected doctor’s appointments for that date, approves only when the doctor has no conflicting appointment, rejects requests with a reason, and views hospital statistics and graphs. The server checks for a conflict again when approving, so two requests cannot both be approved for the same doctor/date/time slot.
- **Doctor:** sees appointments assigned to their linked doctor profile after approval and can update their progress.
- **Doctor:** sees appointments assigned to their linked doctor profile and can update their status.

Use **Staff Login** on the website. The administrator creates manager and doctor accounts from the Admin Dashboard. There is no public staff registration.

## Manager approvals, graphs and patient notifications
- New patient bookings start with `Pending` status.
- The manager can open **Check doctor's schedule** on a pending request to see existing active appointments for that doctor on the selected date.
- Approval is blocked if the same doctor already has an active appointment at that exact date and time.
- When the manager approves or rejects a request, CareConnect saves a patient notification record. To send the notification as a real SMS, configure Twilio below.
- The Manager Dashboard shows appointment totals, pending/approved counts, registered patients, monthly appointment activity, doctor workload and booking status totals.

### Optional real SMS delivery with Twilio
1. Create/configure a Twilio account and obtain its Account SID, Auth Token and SMS-enabled sender number.
2. Open `server/.env` (do not share this file or its secrets).
3. Add these settings using your own Twilio values:
   ```env
   TWILIO_ACCOUNT_SID=your_account_sid
   TWILIO_AUTH_TOKEN=your_auth_token
   TWILIO_PHONE_NUMBER=your_twilio_number
   ```
4. Use patient phone numbers in international format, for example `+266...` for Lesotho.
5. Restart the backend. When a manager approves or rejects an appointment, the backend will submit the SMS and record the provider response. Without Twilio credentials, the appointment is still reviewed and a notification history record is saved, but no SMS is sent.

## Home page background
The home page and staff dashboards use healthcare photography as a background with a dark overlay so the text remains readable. The images are loaded from Unsplash and therefore require an internet connection; the rest of the app can run locally.

## Important security notes
- Passwords are stored as salted scrypt hashes, not plain text.
- Staff API routes use signed, time-limited login tokens and role checks.
- Change `TOKEN_SECRET` and the initial admin password before deployment. This starter project is intended for local coursework/demo use; deploy only after adding HTTPS, stronger session/token handling, audit logging, backups and production security review.
