# Task Tracker App

Aplikasi Flutter untuk mengelola task pribadi: melihat daftar task, menambah,
mengubah status (Done/Pending), melihat detail, kalender per tanggal, dan
profil pengguna. Dibuat untuk technical test Fullstack Developer (Flutter
focus).

---

## Daftar Isi

- [Cara Menjalankan Project](#cara-menjalankan-project)
- [Architecture Explanation](#architecture-explanation)
- [State Management Explanation](#state-management-explanation)
- [Alasan Memilih Approach Tertentu](#alasan-memilih-approach-tertentu)
- [API yang Digunakan](#api-yang-digunakan)
- [Known Limitations](#known-limitations)
- [Struktur Folder Lengkap](#struktur-folder-lengkap)

---

## Cara Menjalankan Project

### Requirement

- Flutter SDK 3.35.x (channel stable)
- Dart SDK ^3.9.2
- API key dari [restful-api.dev](https://restful-api.dev) versi _authenticated_

### Langkah

1. Clone repository, lalu install dependency:

   ```bash
   flutter pub get
   ```

2. Daftar di [restful-api.dev](https://restful-api.dev) untuk mendapatkan
   `x-api-key` pribadi (gratis, ada limit request harian).

3. Jalankan aplikasi **wajib** menyertakan API key lewat `--dart-define`,
   karena API key **tidak di-hardcode** di source code (lihat
   `lib/core/constants/api_constants.dart`):

   ```bash
   flutter run --dart-define=API_KEY=isi_api_key_anda
   ```

   Jika menjalankan lewat VS Code, tambahkan ke `.vscode/launch.json`:

   ```json
   {
     "configurations": [
       {
         "name": "task_management",
         "request": "launch",
         "type": "dart",
         "args": ["--dart-define=API_KEY=isi_api_key_anda"]
       }
     ]
   }
   ```

4. Untuk build release:

   ```bash
   flutter build apk --dart-define=API_KEY=isi_api_key_anda
   ```

### Alur Penggunaan

Buka app → Splash Screen mengecek session → jika belum pernah login,
diarahkan ke **Register** untuk membuat akun baru (email & password apa
saja, tidak perlu verifikasi) → setelah register/login otomatis masuk ke
**Home** dengan 4 tab di bottom navigation: Home, Task, Date, Profile.

---

## Architecture Explanation

Project ini memakai **layered architecture** sederhana (bukan Clean
Architecture penuh ala textbook, tapi tetap punya separation of concern
yang jelas), terbagi 4 layer:

```
lib/
├── core/           → Hal lintas-fitur: network client, konstanta, util, routing
├── data/           → Layer "kotor": tahu detail API, model JSON, local storage
├── domain/         → Kontrak abstrak (interface) — tidak tahu detail implementasi
├── presentation/   → UI (StatefulWidget) + Controller (logic non-UI)
└── app/            → Root widget, route table
```

### Alur dependency (selalu satu arah, turun)

```
presentation  →  domain (interface)  →  data (implementasi)  →  core (network)  →  API eksternal
```

`presentation` **tidak pernah** mengimpor langsung dari `data`
implementasi — selalu lewat kontrak `domain/repositories/*.dart`. Praktiknya
di project ini, instance konkret (`TaskRepositoryImpl`, dsb) dirakit manual di
`initState` tiap halaman (manual dependency injection, tanpa framework DI
seperti `get_it`) — cukup untuk skala app ini, dan halaman tetap hanya
"berbicara" lewat tipe interface `TaskRepository`.

**Keuntungan pola ini:** kalau suatu saat backend diganti (misal dari
`restful-api.dev` ke backend Golang sendiri), cukup buat implementasi baru
dari `TaskRepository`/`AuthRepository`/`ProfileRepository` — seluruh kode
`presentation` tidak perlu disentuh sama sekali.

### Detail tiap layer

**`core/`** — murni utility, tidak tahu soal Task/User:

- `network/api_client.dart`: wrapper di atas `http`, urus header
  (`x-api-key`, `Authorization`), dan mapping status code HTTP →
  `ApiException` yang jelas (`UnauthorizedException`, `NotFoundException`,
  dst).
- `utils/task_change_notifier.dart`: event bus sederhana untuk
  sinkronisasi antar tab (dijelaskan lebih lanjut di bawah).
- `routing/app_routes.dart`: semua nama route terpusat satu file.

**`data/`** — tahu semua detail kotor:

- `models/task_model.dart`: titik **translasi schema** — restful-api.dev
  hanya punya schema generik `{ id, name, data: {...} }`, sedangkan app
  butuh `title, description, status, dueDate, priority`. Semua mapping
  dua arah dikerjakan di `TaskModel.fromApiJson()` / `toApiJson()`.
- `datasources/`: tahu persis endpoint API, tidak tahu dari mana
  token/collection name berasal.
- `repositories/`: implementasi konkret, mengorkestrasi
  datasource + local storage (ambil token, lalu panggil datasource).

**`domain/`** — kontrak murni (`abstract class`), nol implementasi.

**`presentation/`** — dijelaskan detail di bagian State Management.

---

## State Management Explanation

App ini memakai **`StatefulWidget` + `setState`** sebagai mekanisme
reaktivitas utama (native Flutter, tanpa Bloc/Provider/Riverpod), sesuai
keahlian dan preferensi yang diminta.

### Pola: Controller terpisah dari Widget

Supaya tetap "rapih dan scalable" walau native, logic dipisah dari UI lewat
pola **plain Dart Controller class**:

```dart
class TaskListController {
  bool isLoading = false;
  String? errorMessage;
  List<TaskModel> _allTasks = [];

  Future<void> loadTasks() async { ... }   // ubah state internal
  Future<bool> toggleStatus(...) async { ... }
}
```

```dart
class _TaskListPageState extends State<TaskListPage> {
  late final TaskListController _controller;

  Future<void> _loadTasks() async {
    setState(() {});               // tampilkan loading
    await _controller.loadTasks(); // controller ubah state internalnya
    setState(() {});               // widget rebuild baca state terbaru
  }
}
```

- **Controller** = bukan widget, bukan `ChangeNotifier` — cuma class biasa
  yang menyimpan state (`isLoading`, `tasks`, `errorMessage`) dan punya
  method `Future<...>` yang mengubah state itu.
- **Widget (`State`)** = murni render + memanggil method controller, lalu
  `setState(() {})` untuk memberi tahu Flutter "render ulang, baca state
  terbaru dari controller".

Halaman yang sangat sederhana (`EditNamePage`, `TaskDetailPage`) tidak
dibuatkan Controller terpisah — logic-nya ditangani langsung di `State`
memakai Repository, supaya tidak over-engineering untuk kasus trivial.
Aturan yang dipegang konsisten: _Controller dipakai bila ada logic
non-trivial (search, filter, sorting, multiple state field); halaman
read-mostly cukup state lokal di `State`._

### Real-time sync antar tab tanpa pull-to-refresh manual

**Masalah:** karena tiap tab (`Home`, `Task`, `Date`) punya Controller dan
fetch data sendiri-sendiri secara independen, saat `TaskListPage` berhasil
tambah/edit/hapus task, `HomePage` di tab sebelah tidak otomatis tahu data
sudah berubah (karena tidak ada _single source of truth_ reaktif seperti
yang otomatis didapat dari Bloc/Provider).

**Solusi — `TaskChangeNotifier`** (`lib/core/utils/task_change_notifier.dart`):
sebuah singleton event bus tanpa payload (bukan `ChangeNotifier` Flutter):

```dart
class TaskChangeNotifier {
  factory TaskChangeNotifier() => _instance;   // singleton
  void addListener(VoidCallback l);
  void removeListener(VoidCallback l);
  void notify();   // panggil semua listener
}
```

Alurnya:

1. Setelah `addTask` / `updateTask` / `deleteTask` / `updateStatus`
   berhasil di Controller manapun, dipanggil `TaskChangeNotifier().notify()`.
2. `MainShellPage` (pemegang bottom navigation) mendaftar sebagai listener
   sejak `initState`. Saat `notify()` diterima, ia menaikkan counter
   `_refreshTick` lalu `setState`.
3. `HomePage` dan `DatePage` diberi `ValueKey('home_$_refreshTick')` /
   `ValueKey('date_$_refreshTick')`. Flutter mendeteksi key berubah →
   widget lama di-_dispose_, widget baru dibuat dari nol → `initState`
   terpanggil lagi → otomatis fetch data terbaru.
4. `TaskListPage` (sumber perubahan) **tidak** diberi key baru karena
   sudah memperbarui state lokalnya sendiri saat aksi terjadi — tidak perlu
   re-fetch dari API lagi.

Pendekatan ini dipilih (dibanding `ChangeNotifier`/`InheritedWidget`
manual) karena tetap konsisten dengan filosofi "native `setState`" —
`TaskChangeNotifier` murni jadi _lonceng_ untuk memicu `setState`, bukan
pembawa data/state itu sendiri.

---

## Alasan Memilih Approach Tertentu

| Keputusan                                                                                  | Alasan                                                                                                                                                                                                |
| ------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **StatefulWidget + setState** (bukan Bloc/Provider)                                        | Sesuai instruksi & keahlian; dibuktikan tetap bisa scalable lewat pola Controller terpisah                                                                                                            |
| **Layered architecture ringan**, bukan Clean Architecture penuh                            | Cukup untuk scope app ini: tetap ada separation jelas (presentation/domain/data) tanpa over-engineering (skip use-case layer terpisah)                                                                |
| **Manual dependency injection** (rakit instance di `initState`), bukan `get_it`/`Provider` | Konsisten dengan keputusan "native", dan scope app masih kecil sehingga DI framework belum perlu                                                                                                      |
| **Collection per-user** (`tasks_<base64(email)>`) di restful-api.dev                       | API ini menyimpan collection secara global per API key, bukan otomatis per user — supaya task user A tidak campur dengan user B                                                                       |
| **PATCH untuk update status**, PUT untuk update penuh                                      | Sesuai requirement teknikal test ("PATCH/PUT update status"); PATCH lebih ringkas secara intent walau tetap mengirim semua field `data` karena API ini tidak mendukung merge per-key di nested object |
| **`TaskChangeNotifier`** event bus untuk sync antar tab                                    | Solusi paling minimal untuk masalah "banyak Controller independen tidak saling tahu", tanpa harus migrasi ke state management reaktif                                                                 |
| **`table_calendar` package** untuk Date Page                                               | Menghindari reinvent grid kalender manual; agregasi task-per-tanggal tetap dikerjakan sendiri secara lokal (`DateController`) dari data yang sudah di-fetch, tanpa endpoint khusus                    |
| **Foto profil disimpan lokal** (path file, bukan upload ke API)                            | restful-api.dev tidak punya endpoint upload file/image                                                                                                                                                |
| **Ubah password sebagai simulasi lokal**                                                   | restful-api.dev tidak punya endpoint update password — didokumentasikan jujur sebagai limitasi, bukan disembunyikan                                                                                   |

---

## API yang Digunakan

[restful-api.dev](https://restful-api.dev) — versi **authenticated**.

| Kebutuhan App           | Endpoint                                            |
| ----------------------- | --------------------------------------------------- |
| Register                | `POST /register`                                    |
| Login                   | `POST /login`                                       |
| Get semua task          | `GET /collections/{collectionName}/objects`         |
| Get detail task         | `GET /collections/{collectionName}/objects/{id}`    |
| Tambah task             | `POST /collections/{collectionName}/objects`        |
| Update task (full)      | `PUT /collections/{collectionName}/objects/{id}`    |
| Update status (partial) | `PATCH /collections/{collectionName}/objects/{id}`  |
| Hapus task              | `DELETE /collections/{collectionName}/objects/{id}` |

Karena schema asli API hanya `{ id, name, data: {...bebas} }`, field app
(`title`, `description`, `status`, `dueDate`, `priority`) dipetakan ke
`name` dan isi `data` — lihat `lib/data/models/task_model.dart`.

---

## Known Limitations

Didokumentasikan secara jujur, bukan disembunyikan:

1. **Ubah password** bersifat simulasi lokal (`shared_preferences`), bukan
   benar-benar memvalidasi/mengubah password di server — karena
   restful-api.dev tidak menyediakan endpoint untuk itu.
2. **Foto profil** hanya tersimpan sebagai path file lokal di device. Jika
   app di-uninstall atau pindah device, foto akan hilang (nama tetap
   tersimpan terpisah sesuai keputusan yang sama).
3. **Tidak ada refresh token** — saat token JWT expired, user akan
   menerima `UnauthorizedException` dan perlu login ulang manual (tidak
   ada silent re-auth).
4. **Rate limit API**: akun authenticated restful-api.dev punya limit
   request harian, jadi testing intensif dapat menyentuh limit tersebut.

---

## Struktur Folder Lengkap

```
lib/
├── main.dart
├── app/
│   └── app.dart                       # MaterialApp + onGenerateRoute terpusat
│
├── core/
│   ├── constants/                     # api_constants, app_colors, app_text_styles
│   ├── network/                       # api_client.dart, api_exception.dart
│   ├── routing/                       # app_routes.dart
│   └── utils/                         # date_formatter, validators,
│                                       # collection_name_helper, task_change_notifier
│
├── data/
│   ├── models/                        # task_model, task_status, task_priority,
│   │                                   # user_model, auth_response_model
│   ├── datasources/                   # task_remote_, auth_remote_, profile_local_
│   ├── local/                         # session_storage.dart
│   └── repositories/                  # task_, auth_, profile_repository_impl.dart
│
├── domain/
│   └── repositories/                  # task_, auth_, profile_repository.dart (abstract)
│
└── presentation/
    ├── splash/
    ├── auth/                          # login_, register_ (page + controller)
    ├── shell/                         # main_shell_page.dart (bottom navigation)
    ├── home/                          # home_page.dart, home_controller.dart
    ├── task/                          # task_list_, task_form_, task_detail_
    ├── date/                          # date_page.dart, date_controller.dart
    ├── profile/                       # profile_, edit_name_, edit_photo_, change_password_
    └── widgets/                       # task_card, status_badge, priority_badge,
                                        # app_loading, app_empty_state, app_error_view,
                                        # app_search_bar, summary_stat_card
```
