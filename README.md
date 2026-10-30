# Course Explorer v2 - Praktikum Mobile Programming

**Nama:** MD. PRADIPTHA PRADNYASWARI
**NIM:** 2415051055

## Audit Arsitektur & Tanggung Jawab Lapisan (Dependency Direction)
Aplikasi ini telah menerapkan *Separation of Concerns* dengan arah dependensi yang benar: **Screen -> Provider -> Repository -> Service**. 

Berikut adalah tanggung jawab dari masing-masing folder (layer):
1. **`models/`**: Bertanggung jawab mendefinisikan struktur data (blueprint `Course`) dan melakukan *parsing* dari JSON ke Object Dart (fungsi `fromJson`).
2. **`services/`**: Lapisan paling bawah (*Data Source*). Bertanggung jawab berinteraksi langsung dengan sumber data mentah, contohnya membaca file JSON lokal menggunakan `rootBundle` dan memecahnya menggunakan `jsonDecode`. Layer ini tidak boleh tahu menahu soal UI (Widget).
3. **`repositories/`**: Berperan sebagai jembatan/abstraksi yang menghubungkan `Provider` dan `Service`. Jika nanti sumber data berubah dari JSON ke Database/API, kita hanya mengubah layer Service/Repository tanpa merusak Provider.
4. **`providers/`**: Lapisan pengelola *State* (State Management). Bertanggung jawab menampung data (*courses*, *favorites*), status antarmuka (*isLoading*, *error*), dan membroadcast perubahan data ke seluruh layar menggunakan `notifyListeners()`. Provider murni mengolah logika bisnis dan dilarang keras menyimpan *BuildContext* sebagai properti.
5. **`screens/`**: Lapisan Antarmuka (*View*). Hanya bertugas menampilkan UI (layar Home, Favorites, Profile, dsb). Tidak boleh melakukan pemrosesan data mentah. Hanya bertugas mengonsumsi data dari Provider menggunakan `context.watch` atau merespons interaksi dengan `context.read`.
6. **`widgets/` & `layouts/`**: Berisi potongan-potongan komponen UI yang bisa dipakai ulang (seperti *Card* mata kuliah) dan logika pengaturan tata letak responsif (Compact, Medium, Expanded).

## REST API Endpoint
- **URL Endpoint**: `https://jsonplaceholder.typicode.com/posts`
- **Method**: GET
- **Status Code**: 200 OK
- **Resource JSON**: `id`, `code`, `title`, `credits`, `status`

# Course Data Manager

Aplikasi manajemen data mata kuliah berbasis Flutter dengan pemisahan struktur (Clean Architecture) dan backend Supabase. Dibuat oleh MD. PRADIPTHA PRADNYASWARI (2415051055).

## Deskripsi
Aplikasi ini dikembangkan untuk mengelola daftar mata kuliah, mencakup fitur Create, Read, Update, dan Delete (CRUD). Aplikasi dilengkapi dengan state management menggunakan Provider, penanganan error (Network & Database Constraint), serta antarmuka responsif dengan NavigationBar.

## Cara Menjalankan
1. Pastikan Flutter SDK sudah terpasang.
2. Clone repository ini.
3. Jalankan `flutter pub get` di terminal untuk mengunduh package.
4. Hubungkan device/emulator, lalu jalankan aplikasi menggunakan `flutter run`.

## Arsitektur Singkat
Proyek ini memisahkan komponen menjadi beberapa layer utama:
- **Models:** Struktur data (Course).
- **Services:** Sumber data (CourseSupabaseService & CourseApiService).
- **Repositories:** Penghubung antara data source dan state (CourseRepository).
- **Providers:** State management untuk mengelola logika UI (CourseProvider).
- **Screens & Widgets:** Lapisan presentasi / antarmuka pengguna.

## Backend
- **Supabase:** Digunakan sebagai sumber data utama (BaaS/Database) untuk eksekusi operasi CRUD secara *real-time* lengkap dengan Row Level Security (RLS).