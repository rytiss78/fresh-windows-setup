# Fresh Windows Setup

Lietuviška grafinė priemonė, skirta greitai paruošti ką tik įdiegtą **Windows 11** sistemą. Programa leidžia viename lange pasirinkti Windows nustatymus, pašalinti nereikalingas integruotas programas ir įdiegti dažniausiai naudojamas darbalaukio programas.

> Rekomenduojama naudoti tik švariai įdiegtoje Windows sistemoje. Prieš vykdydami pakeitimus peržiūrėkite pažymėtas parinktis.

## Pagrindinės galimybės

- Lietuviška, tamsaus režimo grafinė sąsaja.
- Windows nustatymai suskirstyti aiškiomis grupėmis.
- Integruotų Windows programų šalinimas.
- Programų diegimas naudojant **WinGet** arba oficialius kūrėjų puslapius.
- Pasirinktų Vivaldi plėtinių registravimas per naršyklės politiką.
- Kiekvieno pritaikyto nustatymo **nuskaitymas ir patikrinimas**.
- Vykdymo žurnalas su aiškiai pažymėtomis klaidomis.
- Galimos **PowerShell (.ps1)** ir **vykdomoji (.exe)** versijos.

## Atsisiundimas ir paleidimas

### EXE versija (rekomenduojama)

1. Atsisiųskite `FreshWindowsSetup.UI.exe` iš [GitHub releases](https://github.com/rytiss78/fresh-windows-setup/releases).
2. Paleiskite failą.
3. Patvirtinkite administratoriaus teisių užklausą.
4. Pasirinkite norimus veiksmus ir pradėkite vykdymą.

EXE failas nėra pasirašytas skaitmeniniu sertifikatu, todėl Windows gali parodyti "Nežinomas leidėjas" arba "Windows apsaugojo jūsų kompiuterį" įspėjimą. Tokiu atveju pasirinkite **Daugiau informacijos** → **Vykdyti vis tiek**, jei failą atsisiuntėte iš šios saugyklos.

### PowerShell versija

1. Atsisiųskite `FreshWindowsSetup.UI.ps1`.
2. Atidarykite "Windows PowerShell" kaip administratorius.
3. Pereikite į katalogą, kuriame yra failas.
4. Vykdykite:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\FreshWindowsSetup.UI.ps1"
```

Programa pati patikrina administratoriaus teises ir, jei reikia, paprašo jas suteikti.

## Windows nustatymai

Priemonė gali, be kita ko:

- lygiuoti užduočių juostą kairėje;
- paslėpti paiešką ir valdiklius;
- išjungti pradžios meniu rekomendacijas ir neseniai atidarytų elementų rodymą;
- atkurti klasikinį dešiniojo pelės mygtuko meniu;
- įjungti kompaktišką failų naršyklės rodinį;
- paslėpti "Gallery" ir "Home" elementus;
- išjungti spartųjį paleidimą;
- nustatyti aktyvius tinklus kaip privačius;
- išjungti "Xbox Game Bar" įrašymą;
- pritaikyti privatumo ir kitus sistemos nustatymus;
- išjungti sistemos atkūrimą ir Windows atsarginį kopijavimą.

Kai kuriems pakeitimams įsigalioti reikės atsijungti nuo paskyros arba iš naujo paleisti kompiuterį.

## Integruotų programų šalinimas

Galima pašalinti arba išjungti:

- "Microsoft Edge" naršyklę ir jos atnaujinimo užduotis;
- "Microsoft Office";
- "Notepad";
- "OneDrive";
- "Windows Backup";
- "Xbox" programas.

Šalinant "Microsoft Edge", **WebView2 paliekamas**, nes jo gali reikėti kitoms Windows ir trečiųjų šalių programoms.

## Diegiamos programos

Programų sąrašas pateikiamas abėcėlės tvarka:

- AMD tvarkyklių diegimo priemonė;
- ChatGPT;
- Icaros;
- Notepad++;
- OpenRGB;
- OpenRGB Effects Plugin;
- PotPlayer 64-bit;
- Python;
- qBittorrent;
- Steam;
- Stremio;
- TP-Link Archer TBE550E Bluetooth ir Wi-Fi tvarkyklės;
- Vivaldi;
- Windows HDR Calibration;
- yt-dlp.

Kai kurioms programoms ar tvarkyklėms atidaromas oficialus atsisiuntimo puslapis, todėl diegimą reikia užbaigti rankiniu būdu. "Windows HDR Calibration" diegiama iš "Microsoft Store".

## Vivaldi plėtiniai

Programa gali pridėti šiuos plėtinius:

- Bitwarden Password Manager;
- Hide Scrollbar;
- Imagus Reborn;
- SponsorBlock for YouTube;
- YouTube Inline Fullscreen.

Plėtiniai registruojami naudojant Vivaldi / Chromium politiką. Ši funkcija yra eksperimentinė: naršyklės versija ar organizacijos politika gali neleisti jų įdiegti automatiškai.

## Patikra ir žurnalas

Po kiekvieno Windows nustatymo programa perskaito faktinę reikšmę ir palygina ją su numatyta. Rezultatai rodomi vykdymo žurnale, o klaidos pažymimos raudonu fonu.

Žurnalo failas išsaugomas laikinojoje sistemos vietoje:

```text
%TEMP%\FreshWindowsSetup-*.log
```

## Reikalavimai

- Windows 11;
- administratoriaus teisės;
- interneto ryšys programoms diegti;
- Windows PowerShell 5.1;
- WinGet (programoms, kurios jį palaiko).

## Svarbu

- Prieš vykdydami patikrinkite visas pažymėtas parinktis.
- Sistemos atkūrimo ir atsarginių kopijų išjungimas sumažina atkūrimo galimybes gedimo atveju.
- Programų šalinimas ir sistemos politikų keitimas gali paveikti kitų programų veikimą.

## Versijos istorija

| Versija | Data       | Aprašymas                                      |
|---------|------------|------------------------------------------------|
| 1.0.0   | ?          | Pradinis leidimas                              |
| 1.2.0   | ?          | Ankstesnis pažymėtas leidimas                  |
| 1.3.0   | 2026-09-12 | Pagrindiniai pataisymai, klaidų taisymai, UI  |

### v1.3.0 pataisymai

- **OneDrive šalinimas**: Dabar sustabdo vykstantį `OneDrive` procesą prieš `/uninstall`, kad išvengtų 0x80070005 prieigos klaidos. Klaidos pranešamos kaip WARN vietoj crash'ų.
- **Edge registras**: `MicrosoftEdgeAutoLaunch` šalinimas apsaugotas try/catch — raktas gali neegzistuoti švariose sistemose.
- **HideWidgets (Dsh politika)**: HKLM rašymas apsaugotas try/catch su WARN, jei trūksta administratoriaus teisių. HKCU pusė vis tiek taikoma.
- **yt-dlp klaidos**: Null-safe išimties pranešimo fiksavimas neleidžia tuščio eilutės crash'ui įvykti.

---

**Versija:** 1.3.0  
**Autorius:** Emocinis Taikinys
