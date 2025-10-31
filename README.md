# Superior Animator

**Superior Animator** adalah sebuah plugin animasi canggih untuk Roblox Studio yang dirancang untuk memberikan alur kerja yang modern, intuitif, dan kuat bagi para animator, baik pemula maupun profesional.

## ✨ Fitur Utama

- **Timeline Multi-Track:** Animasikan beberapa objek sekaligus, masing-masing dengan trek propertinya sendiri.
- **Animasi Properti Lanjutan:** Dukungan untuk menganimasikan properti kompleks seperti `CFrame`, `Vector3`, `Color3`, dan `UDim2`, dengan kemampuan untuk mengontrol komponen individual (misalnya, hanya sumbu Y dari `Vector3`).
- **Pustaka Easing Lengkap:** Lebih dari 30+ fungsi easing (Sine, Quad, Elastic, Bounce, dll.) untuk menciptakan animasi yang dinamis dan hidup.
- **Auto-Keyframing:** Secara otomatis membuat keyframe saat Anda memanipulasi objek di viewport, mempercepat alur kerja Anda secara signifikan.
- **Simpan & Muat Proyek:** Simpan sesi animasi Anda dan muat kembali kapan saja untuk melanjutkannya nanti.
- **Ekspor ke Roblox Animation:** Ekspor kreasi Anda menjadi objek `Animation` standar yang siap digunakan di dalam game Anda.
- **UI yang Intuitif:** Antarmuka yang bersih dan terorganisir yang dirancang untuk kemudahan penggunaan.

### Alur Kerja Efisien
- **Pencarian Properti:** Gunakan kotak pencarian di menu "Tambah Properti" untuk memfilter dan menemukan properti yang Anda butuhkan dengan cepat.
- **Menu Konteks Klik Kanan:** Klik kanan pada keyframe atau track untuk mengakses tindakan cepat seperti "Hapus".
- **Salin & Tempel Keyframe:** Percepat proses animasi dengan menyalin (`Ctrl+C`) satu keyframe dan menempelkannya (`Ctrl+V`) di lokasi baru pada track yang kompatibel.
- **Seleksi Multi-Keyframe:**
    - **Seleksi Kotak:** Klik dan seret di area kosong pada timeline untuk menggambar kotak seleksi dan memilih beberapa keyframe sekaligus.
    - **Seleksi Individual:** Tahan `Shift` sambil mengklik beberapa keyframe untuk menambah atau menghapus dari seleksi.
    - **Manipulasi Massal:** Seret (`drag`) salah satu keyframe yang dipilih untuk memindahkan seluruh grup, atau tekan `Delete` untuk menghapus semuanya.
- **Editor Properti Interaktif:**
    - **Color Picker:** Klik pada kotak warna di editor properti untuk membuka color picker bawaan Roblox Studio, memungkinkan pemilihan warna yang cepat dan visual.
    - **Checkbox Boolean:** Ubah nilai properti `true`/`false` (seperti `Visible` atau `Enabled`) dengan satu klik pada checkbox.

## 🚀 Cara Penggunaan

1.  **Instalasi:**
    -   Instal plugin melalui Roblox Studio.

2.  **Membuka Plugin:**
    -   Setelah terinstal, buka tab **PLUGINS** di Roblox Studio.
    -   Klik tombol **Superior Animator** untuk membuka jendela utama plugin.

3.  **Membuat Animasi:**
    -   **Pilih Objek:** Pilih sebuah `Part`, `Model`, `UI Element`, atau objek lain yang ingin Anda animasikan di Explorer.
    -   **Tambah Objek ke Timeline:** Klik tombol **"Tambah Objek"** di Superior Animator untuk membuat trek baru untuk objek tersebut.
    -   **Tambah Trek Properti:** Klik tombol **"+"** pada trek objek untuk memilih properti yang ingin dianimasikan (misalnya, `Size`, `Color`, `Transparency`).
    -   **Buat Keyframe:**
        -   Pindahkan *playhead* (garis merah) ke posisi waktu yang diinginkan.
        -   Ubah nilai properti objek di jendela Properties Roblox.
        -   Klik tombol **"+" (Tambah Keyframe)** untuk membuat keyframe baru.
    -   **Ulangi:** Terus tambahkan keyframe di waktu yang berbeda untuk membangun animasi Anda.

4.  **Menyimpan dan Memuat:**
    -   Gunakan tombol **"Save"** untuk menyimpan progres animasi Anda. Beri nama, dan animasi akan disimpan di dalam `ServerStorage > SuperiorAnimator_Saves`.
    -   Gunakan tombol **"Load"** untuk membuka dan melanjutkan proyek animasi yang telah disimpan.

5.  **Ekspor Animasi:**
    -   Setelah selesai, klik tombol **"Export"**.
    -   Beri nama pada animasi Anda. Plugin akan membuat objek `Animation` yang dapat digunakan di `AnimationController` atau `Humanoid`. Animasi yang diekspor akan disimpan di `ServerStorage > SuperiorAnimator_Exports`.
