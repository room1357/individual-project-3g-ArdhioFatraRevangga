# pemrograman_mobile

A new Flutter project.

Biodata :
Nama : Ardhio Fatra Revangga
Kelas : SIB 3G
NIM : 2341760166

Expense Tracker Manager adalah aplikasi seluler yang dibangun menggunakan Flutter untuk membantu pengguna mencatat, mengelola, dan menganalisis pengeluaran berdasarkan kategori. Selain itu, aplikasi ini menyertakan fitur integrasi REST API (menggunakan Posts API dari JSONPlaceholder) sebagai demonstrasi kemampuan komunikasi data client-server.

##Fitur Utama

| Fitur                        | Deskripsi                                                                         |
| ---------------------------- | --------------------------------------------------------------------------------- |
| 🧾 **Manajemen Pengeluaran** | Melakukan operasi CRUD (Tambah, Ubah, Hapus, Lihat) pada semua transaksi pengeluaran pengguna.|
| 📊 **Statistik Pengeluaran** | Menyajikan visualisasi data (grafik) pengeluaran, dikelompokkan berdasarkan kategori dan rentang waktu.|
| 🏷️ **Manajemen Kategori**    | Memungkinkan pengelolaan (membuat, mengubah, menghapus) kategori agar data pengeluaran lebih terorganisir.|
| 👤 **Profil Pengguna**       | Menampilkan data pengguna yang sedang login.                                      |
| ⚙️ **Pengaturan Aplikasi**   | Mengatur preferensi aplikasi seperti bahasa dan notifikasi.                       |
| ☁️ **Posts (API)**           | Fitur tambahan untuk latihan REST API (GET, POST, DELETE) dengan JSONPlaceholder. |
| 🔐 **Autentikasi Login**     | Sistem dasar untuk masuk dan keluar (login/logout) dengan penyimpanan sesi menggunakan SharedPreferences.|

##Teknologi yang Digunakan
- **Flutter 3.35.4**
- **Dart 3.9.2**
- **DevTools 2.48.0**
- **HTTP package** — komunikasi REST API
- **Shared Preferences** — penyimpanan lokal sesi pengguna
- **Material Design 3** — komponen UI
- **JSONPlaceholder API** — API dummy untuk testing CRUD

##Cara Menjalankan Aplikasi

1️. **Clone Repository**

```bash
git https://github.com/room1357/individual-project-3g-Fitricahyaniati12.git
cd individual-project-3g-Fitricahyaniati12
```

2️. **Install Dependencies**

```bash
flutter pub get
```

3️. **Jalankan di Emulator atau Device**

```bash
flutter run
```
##Struktur Folder Utama

```plaintext
lib
│   main.dart                       # Entry point utama aplikasi
│   rest_client.dart                # Client HTTP dasar (tidak digunakan langsung)
│
├───client
│       rest_client.dart            # Implementasi REST client untuk konsumsi API JSONPlaceholder
│
├───models
│       category.dart               # Model data kategori pengeluaran
│       expense.dart                # Model data pengeluaran
│       post.dart                   # Model data postingan (API)
│       user.dart                   # Model data pengguna
│
├───screens
│       about_screen.dart               # Halaman tentang aplikasi
│       add_expense_screen.dart         # Form tambah pengeluaran baru
│       advanced_expense_list_screen.dart  # Daftar pengeluaran lengkap (fitur utama)
│       category_screen.dart            # Manajemen kategori pengeluaran
│       edit_expense_screen.dart        # Form edit pengeluaran
│       edit_profile_screen.dart        # Form edit profil pengguna
│       expense_list_screen.dart        # Tampilan daftar pengeluaran sederhana
│       home_screen.dart                # Halaman utama (menu cepat & ringkasan)
│       login_screen.dart               # Halaman login pengguna
│       posts_screen.dart               # Halaman demonstrasi API eksternal (CRUD Post)
│       profile_screen.dart             # Halaman profil pengguna
│       register_screen.dart            # Halaman pendaftaran pengguna
│       settings_screen.dart            # Halaman pengaturan aplikasi
│       statistics_screen.dart          # Halaman statistik & grafik pengeluaran
│
├───services
│       auth_service.dart               # Layanan autentikasi (login/logout)
│       expense_manager.dart            # Logika tambahan untuk pengelolaan pengeluaran
│       expense_service.dart            # CRUD data pengeluaran (local + shared preferences)
│       looping_examples.dart           # Contoh fungsi looping (latihan/eksperimen)
│       post_service.dart               # CRUD data posts via REST API
│
├───utils
│       currency_utils.dart             # Utilitas format mata uang (Rp)
│       date_utils.dart                 # Utilitas format dan manipulasi tanggal
│
└───widgets
        expense_card.dart               # Widget tampilan kartu pengeluaran
```

##Penjelasan Setiap Halaman

| File                                  | Deskripsi Singkat                                                                                                         |
| ------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **home_screen.dart**                  | Tampilan utama aplikasi. Menampilkan sapaan pengguna, ringkasan cepat, dan menu navigasi ke fitur lain.                   |
| **login_screen.dart**                 | Halaman untuk login pengguna dengan validasi input.                                                                       |
| **register_screen.dart**              | Form pendaftaran pengguna baru.                                                                                           |
| **advanced_expense_list_screen.dart** | Daftar pengeluaran lengkap dengan opsi tambah, edit, dan hapus.                                                           |
| **add_expense_screen.dart**           | Form untuk menambahkan pengeluaran baru.                                                                                  |
| **edit_expense_screen.dart**          | Form untuk memperbarui pengeluaran yang sudah ada.                                                                        |
| **statistics_screen.dart**            | Menampilkan grafik dan ringkasan statistik pengeluaran bulanan.                                                           |
| **category_screen.dart**              | Mengelola daftar kategori pengeluaran.                                                                                    |
| **profile_screen.dart**               | Menampilkan profil pengguna dan tombol edit profil.                                                                       |
| **edit_profile_screen.dart**          | Form untuk mengubah nama/email pengguna.                                                                                  |
| **settings_screen.dart**              | Pengaturan aplikasi seperti notifikasi, bahasa, versi, dan tautan ke halaman _About_.                                     |
| **about_screen.dart**                 | Informasi singkat tentang aplikasi dan pengembang.                                                                        |
| **posts_screen.dart**                 | Menampilkan daftar posting dari API eksternal (_JSONPlaceholder_). Dapat menambah, menghapus, dan memuat ulang postingan. |
| **expense_list_screen.dart**          | Tampilan daftar pengeluaran sederhana, versi dasar dari _Advanced Expense List_.                                          |

##Screenshot & Deskripsi Setiap Halaman

---
-About Screen

Menampilkan informasi tentang aplikasi, tujuan pembuatannya, serta identitas pengembang.  
Biasanya berisi versi aplikasi dan deskripsi singkat proyek.
<img width ="495" height="816" alt="Image" src="https://github.com/user-attachments/assets/3037013a-100f-4bed-a262-b2b9efa4713a" />

-Settings Screen
<img width="496" height="807" alt="Image" src="https://github.com/user-attachments/assets/ec25fc31-b170-413d-8ac2-eb7a72cc4438" />

-Login Screen
Halaman untuk masuk ke aplikasi menggunakan email dan password.
- 🔘 **Login:** Memverifikasi dan masuk ke aplikasi.
- 🔘 **Daftar:** Arahkan ke halaman Register.
<img width="497" height="802" alt="Image" src="https://github.com/user-attachments/assets/0bfa6054-a950-422a-92b0-47605586ad0b" />

-Register Screen
Form pendaftaran untuk pengguna baru.
- 🔘 **Daftar:** Membuat akun baru.
- 🔘 **Login:** Kembali ke halaman login.
<img width="504" height="812" alt="Image" src="https://github.com/user-attachments/assets/e042b92d-61d7-4fb5-923e-5b556e64ce36" />

-Advanced Expense List Screen
Menampilkan daftar pengeluaran
<img width="495" height="807" alt="Image" src="https://github.com/user-attachments/assets/6a43ec20-9d9b-4424-a4f0-c27d567fce70" />

-Category Screen
Mengelola kategori pengeluaran yang dapat digunakan saat input data.
- ➕ **Tambah Kategori:** Menambahkan kategori baru.
- 🗑️ **Hapus Kategori:** Menghapus kategori yang tidak digunakan.
<img width="498" height="809" alt="Image" src="https://github.com/user-attachments/assets/6b0aeaf4-a708-4f75-a6bd-c730d25c562c" />

-Profile Screen
Menampilkan profile pengguna
<img width="503" height="812" alt="Image" src="https://github.com/user-attachments/assets/6e3b043b-a068-4dad-a215-fbe98b86d58c" />

-Home Screen
Halaman utama setelah login. Menampilkan sapaan pengguna, total pengeluaran, dan menu cepat ke fitur lain.
- 🏷️ **Menu Grid:** Navigasi cepat ke Statistik, Kategori, Profil, Pengaturan, dan Posts.
- 🔘 **Logout:** Keluar dari aplikasi.
<img width="498" height="811" alt="Image" src="https://github.com/user-attachments/assets/00c644ab-2705-4d63-988c-f575dbdb9c4a" />

-Statistics Screen
Menampilkan grafik dan ringkasan statistik pengeluaran pengguna.  
Bisa difilter berdasarkan harian, mingguan, bulanan, atau kategori.
<img width="498" height="811" alt="Image" src="https://github.com/user-attachments/assets/cdd5f0f4-9257-49f2-a64e-2d71e7a89d89" />

-API screen
menampilkan data api
<img width="497" height="811" alt="Image" src="https://github.com/user-attachments/assets/9f978478-6043-4195-b715-41e5bb30dadc" />

-👷🏻Pengembang

| **Atribut**                     | **Keterangan**                                                                                                                                                      |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 👤 **Nama**                     | **Fitri cahyaniati**                                                                                                                                             |
| 💼 **Project**                  | _Individual Project — Expense Tracker Manager_                                                                                                                      |
| 📘 **Mata Kuliah**              | **Pemrograman Mobile (Flutter)**                                                                                                                                    |
| 🧭 **Deskripsi Singkat**        | Aplikasi untuk mencatat, mengelola, dan menganalisis pengeluaran pengguna berdasarkan kategori dan rentang waktu tertentu (harian, mingguan, bulanan, atau custom). |
| 🧠 **Teknologi yang Digunakan** | Flutter, Dart, HTTP Client, REST API (JSONPlaceholder), dan stateful widgets dengan UI modern berbasis gradient.                                                    |
| 📅 **Tahun Pengerjaan**         | **2025**                                                                                                                                                            |


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
