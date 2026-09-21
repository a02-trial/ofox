# OrangeFox device tree - Samsung Galaxy A02 (a02 / SM-A022F, MT6739)

Device tree recovery buat OrangeFox (branch `fox_12.1`), kernel prebuilt (4.14.186, arm32).

## Build (GitHub Actions)
Tab **Actions** -> **OrangeFox Build** -> **Run workflow**. Hasil di artifact `orangefox-a02`.

## Build (lokal / Codespaces)
```bash
bash ulti.sh        # setup + sync + build (pertama kali)
./z                 # rebuild cepat
bash note.sh        # briefing proyek (buat di-paste ke AI)
```

## Flash (Odin)
Recovery `.tar` di AP + `vbmeta_disabled.tar`, uncheck *Auto Reboot*, lalu langsung
tahan Vol Up + Power buat masuk recovery. Format data, lalu jalanin `multidisabler`.

Lihat `note.sh` buat detail & aturan penting tree ini.
