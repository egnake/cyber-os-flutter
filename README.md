# 🛡️ CYBER_OS

> **The Ultimate Mobile Cyber Security Intelligence & Toolkit Application.**

![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0%2B-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Hive](https://img.shields.io/badge/Hive-NoSQL-orange?style=for-the-badge)
![Riverpod](https://img.shields.io/badge/Riverpod-State%20Management-purple?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**CYBER_OS** is a comprehensive mobile application designed for penetration testers, security researchers, and network administrators. It combines advanced reconnaissance capabilities with essential "Red Team" utilities in a modern, cyberpunk-themed interface.

Built with **Flutter**, powered by **Riverpod** & **Hive**.

---

## 🔥 Key Features ( The Arsenal )

### 🕵️‍♂️ 1. Reconnaissance (Intelligence)
Gather detailed information about any target (IP or Domain).
* **IP Analysis:** Geolocation, ISP, Organization, and Risk Scoring algorithm.
* **WHOIS Lookup:** Deep dive into domain registration details and age via RDAP protocol.
* **DNS Dumper:** Live extraction of A, MX, NS, TXT, and SOA records.
* **Subdomain Finder:** Passive enumeration using Certificate Transparency logs (`crt.sh`).
* **Header Analysis:** Web server fingerprinting and security header checks.

### 🌐 2. Network Operations
Analyze connectivity and network infrastructure.
* **TCP Latency Tester:** Precise socket-based ping tool (bypasses ICMP blocks).
* **Subnet Calculator:** CIDR to Netmask, Broadcast, and Host range calculations.
* **MAC Vendor Lookup:** Identify device manufacturers from MAC addresses.
* **My Public IP:** Instant detection of external IP address.
* **System Info:** Device hardware and OS details.

### ⚔️ 3. Red Team Utilities
Quick reference and payload generation for penetration testing.
* **Reverse Shell Generator:** One-click payloads for Bash, Python, Netcat, PHP, etc.
* **Payload Cheatsheets:** Common injection vectors for XSS (Cross-Site Scripting) and SQLi.

### 🔐 4. Cryptography & Utils
Essential tools for data manipulation and encryption.
* **JWT Decoder:** Analyze JSON Web Tokens (Header/Payload) without verify signature.
* **Hash Generator:** Create MD5 and SHA-256 hashes instantly.
* **Base64 Tool:** Real-time Encoder and Decoder.
* **Password Strength:** Entropy analysis and strength estimation.
* **Unix Time Converter:** Convert timestamps to human-readable dates.
* **ROT13 Cipher:** Simple substitution cipher tool.

---

## 🛠️ Technical Stack

This project follows Clean Architecture principles and modern Flutter best practices.

* **Framework:** Flutter (Dart)
* **State Management:** Flutter Riverpod (`ConsumerStatefulWidget`, `Providers`)
* **Networking:** Dio (with Interceptors and Timeouts)
* **Local Database:** Hive (NoSQL, storing `IpData` objects with Adapters)
* **UI/UX:** Google Fonts (`Orbitron`, `RobotoMono`), Percent Indicator, Glassmorphism effects.
* **Utils:** `crypto`, `intl`, `flutter_launcher_icons`.

---

## 🚀 Getting Started

Follow these steps to run the project locally.

### Prerequisites
* Flutter SDK (Latest Stable)
* Dart SDK
* VS Code or Android Studio

### Installation

1.  **Clone the repository**
    ```bash
    git clone [https://github.com/egnake/cyber-os-flutter.git](https://github.com/egnake/cyber-os-flutter.git)
    cd cyber-os-flutter
    ```

2.  **Install dependencies**
    ```bash
    flutter pub get
    ```

3.  **Generate Database Adapters** (Crucial for Hive)
    ```bash
    dart run build_runner build --delete-conflicting-outputs
    ```

4.  **Run the App**
    ```bash
    flutter run
    ```

---

## 📱 Build for Android (APK)

To generate a release APK for testing on physical devices:

```bash
flutter build apk --release
```

## 🤝 Contributing
```text
Contributions are welcome! If you have a new tool idea or want to improve the UI, feel free to fork the repository.

Fork the Project

Create your Feature Branch (git checkout -b feature/AmazingFeature)

Commit your Changes (git commit -m 'Add some AmazingFeature')

Push to the Branch (git push origin feature/AmazingFeature)

Open a Pull Request
```

## 👤 Author
```text
Egnake

GitHub: @egnake
```

## 📄 License
```text
Distributed under the MIT License. See LICENSE file for more information.
```
