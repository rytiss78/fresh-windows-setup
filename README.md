# Fresh Windows Setup

Lietuviška grafinė priemonė, skirta greitai paruošti ką tik įdiegtą **Windows 11** sistemą. Programa leidžia viename lange pasirinkti Windows nustatymus, pašalinti nereikalingas integruotas programas ir įdiegti dažniausiai naudojamas darbalaukio programas.

> Rekomenduojama naudoti tik švariai įdiegtoje Windows sistemoje. Prieš vykdydami pakeitimus peržiūrėkite pažymėtas parinktis.

## Pagrindinės galimybės

- Nauja tamsi sąsaja (v2.0): skiltys šoniniame meniu, prie kiekvienos parinkties – aprašymas ir žymos (šaltinis, ar reikia perkrauti, ar pakeitimas rizikingas).
- Paieška kiekvienoje skiltyje (**Ctrl+F**), mygtukai „Pažymėti visus“, „Nuimti visus“ ir „Numatytieji“.
- **Peržiūra prieš vykdymą**: suvestinė, rizikingų pakeitimų sąrašas ir priminimas, kuriems pakeitimams reikės atsijungti ar paleisti Windows iš naujo.
- **Bandomasis režimas** (jungiklis šoniniame meniu): nieko nekeičia, žurnale tik parodo, kas būtų padaryta.
- Vykdymas fone: langas nesustingsta, matoma eiga, vykdymą galima sustabdyti po dabartinio veiksmo.
- Pasirinkimų **importas ir eksportas** į JSON failą.
- Programų diegimas per **WinGet**, iš **GitHub** leidimų (su SHA256 patikra) arba atveriant oficialų gamintojo puslapį.
- Vivaldi plėtinių registravimas per naršyklės politiką.
- Integruotų Windows programėlių šalinimas.
- Paleisties programų ir suplanuotų užduočių šalinimas su atsarginėmis kopijomis.
- Kiekvieno pritaikyto nustatymo **nuskaitymas ir patikrinimas**, vykdymo žurnalas su spalvomis pažymėtomis klaidomis ir įspėjimais.

## Atsisiuntimas ir paleidimas

### EXE versija

1. Atsisiųskite [`FreshWindowsSetup.UI.exe`](https://github.com/rytiss78/fresh-windows-setup/raw/main/FreshWindowsSetup.UI.exe). Tai vienas failas – jokių papildomų failų (pvz., `.config`) nebereikia.
2. Paleiskite failą ir patvirtinkite administratoriaus teisių užklausą.
3. Pasirinkite norimus veiksmus, spauskite **Peržiūrėti ir vykdyti**, o peržiūroje – **Pradėti vykdymą**.

EXE failas nėra pasirašytas skaitmeniniu sertifikatu, todėl Windows gali parodyti "Nežinomas leidėjas" arba "Windows apsaugojo jūsų kompiuterį" įspėjimą. Tokiu atveju pasirinkite **Daugiau informacijos** → **Vykdyti vis tiek**, jei failą atsisiuntėte iš šios saugyklos.

### PowerShell versija

1. Atsisiųskite `FreshWindowsSetup.UI.ps1`.
2. Atidarykite "Windows PowerShell" ir pereikite į katalogą, kuriame yra failas.
3. Vykdykite:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\FreshWindowsSetup.UI.ps1"
```

Programa pati patikrina administratoriaus teises ir, jei reikia, paprašo jas suteikti. `FreshWindowsSetup.UI.ps1` yra programos šaltinis – iš jo sukompiliuotas ir EXE failas.

### Komandinės eilutės parametrai

| Parametras | Paskirtis |
|------------|-----------|
| `-DryRun` | Paleidžia su įjungtu bandomuoju režimu. |
| `-ImportConfig kelias.json` | Paleidus įkelia pasirinkimus iš failo. |
| `-ExportConfig kelias.json` | Mygtukas **Eksportuoti** išsaugo į šį failą be dialogo lango. |
| `-Uninstall` | Atkūrimo režimas: pažymėtos programos įdiegiamos iš naujo, kitos skiltys nevykdomos. |
| `-ValidateOnly` | Tik patikrina, ar sąsaja įsikelia (be administratoriaus teisių, nieko nekeičia). |

Parametrai perduodami ir tada, kai programa persikrauna su administratoriaus teisėmis.

## Programos

Programos suskirstytos į grupes. Jau įdiegtos WinGet programos praleidžiamos.

- **Naršyklės ir bendravimas:** Vivaldi, qBittorrent, Discord, Bitwarden, ChatGPT (oficialus puslapis).
- **Medija ir HDR:** PotPlayer, VLC, Stremio, yt-dlp (su FFmpeg), OBS Studio, ShareX, **Smart HDR Manager**, Windows HDR Calibration (Microsoft Store).
- **Žaidimai:** Steam, Epic Games Launcher, MSI Afterburner.
- **Įrankiai:** 7-Zip, Notepad++, Everything, PowerToys, Icaros, HWiNFO, OpenRGB, OpenRGB Effects Plugin.
- **Programavimas ir komponentai:** Python 3.14, Visual Studio Code, Git, Visual C++ Redistributable.
- **Tvarkyklės (oficialūs puslapiai):** AMD, NVIDIA app, TP-Link Archer TBE550E.

### Smart HDR Manager

[Smart HDR Manager](https://github.com/VantaCode420/SmartHdrManager) automatiškai įjungia Windows HDR paleidus HDR žaidimą ar vaizdo įrašą. Diegiant:

- parenkamas naujausias **stabilus** GitHub leidimas ir jūsų procesoriaus architektūrai (x64 / ARM64) tinkamas savarankiškas paketas (.NET diegti nereikia);
- archyvo SHA256 suma tikrinama pagal leidimo `SHA256SUMS.txt` – nesutapus diegimas nutraukiamas;
- programa įdiegiama į `%LOCALAPPDATA%\Programs\SmartHdrManager`, sukuriama Start meniu nuoroda; ta pati versija antrą kartą nediegiama;
- žurnale pateikiama nuoroda į YouTube HDR aptikimo naudotojo scenarijų, kurį reikia įdiegti per **Tampermonkey**.

Kūrėjas programą išbandė tik su NVIDIA vaizdo plokšte; AMD ir Intel palaikymas nepatvirtintas.

## Vivaldi plėtiniai

Bitwarden, **Tampermonkey**, Hide Scrollbar, Imagus Reborn, SponsorBlock, YouTube Inline Fullscreen; papildomai galima pasirinkti uBlock Origin Lite, Dark Reader, Return YouTube Dislike ir DeArrow.

Plėtiniai registruojami per `HKLM\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist` ir įdiegiami kitą kartą paleidus Vivaldi. Esami kitų įrankių įrašai paliekami, nauji pridedami į pirmą laisvą vietą. Taip įdiegtų plėtinių negalima pašalinti naršyklėje – tik ištrynus įrašą registre.

**Tampermonkey:** Vivaldi / Chromium 138+ naudotojo scenarijai veikia tik atvėrus `vivaldi://extensions` → Tampermonkey → **Details** ir įjungus **Allow User Scripts**.

## Integruotų programėlių šalinimas

Galima pašalinti Clipchamp, Dev Home, Feedback Hub, Microsoft 365 programėlę, naujienas, orus, Solitaire, Notepad, Xbox programėles, OneDrive, Microsoft Edge (WebView2 paliekamas) ir išjungti Windows Backup. Papildomai (pagal nutylėjimą nepažymėta): Copilot, naujasis Outlook, Teams, To Do, Power Automate, Get Help, Tips, Bing paieška, Žemėlapiai, Phone Link, Quick Assist, Sticky Notes.

**Xbox Identity Provider** ir **Xbox TCUI** nuo v2.0 pagal nutylėjimą nepažymėti: be jų neveikia prisijungimas Game Pass ir kai kuriuose Steam žaidimuose, naudojančiuose Xbox paskyrą.

## Windows nustatymai

Nustatymai suskirstyti į 7 skiltis: užduočių juosta ir Start, failų naršyklė, išvaizda, privatumas, sistema ir naujinimai, žaidimai ir tinklas, regionas. Kiekviena parinktis turi aprašymą; žymos rodo, ar pakeitimui įsigalioti reikia perkrauti Explorer, atsijungti ar paleisti Windows iš naujo. Explorer galima perkrauti mygtuku skiltyje **Žurnalas**.

Nauji v2.0 nustatymai (pagal nutylėjimą nepažymėti): užduočių rodinio mygtuko slėpimas, „Baigti užduotį“ užduočių juostoje, sekundės laikrodyje, daugiau Start meniu prisegtų programų, greitosios prieigos naujausių failų slėpimas, OneDrive reklamų naršyklėje išjungimas, „Šis kompiuteris“ darbalaukyje, permatomumo išjungimas, lipniųjų klavišų lango išjungimas, internetinio kalbos atpažinimo, Copilot ir Recall išjungimas, užmigdymo išjungimas, didelio našumo maitinimo schema, ilgi failų keliai, tvarkyklių nediegimas per Windows Update, automatinio perkrovimo atidėjimas, naujinimų dalijimosi išjungimas ir aparatinis GPU planavimas.

## Paleisties programos ir suplanuotos užduotys

Skiltys **Paleisties programos** ir **Suplanuotos užduotys** įkeliamos jas atvėrus. Visi įrašai iš pradžių nepažymėti; šalinama mygtuku **Pašalinti pažymėtus**, atskirai nuo pagrindinio vykdymo. Šie pasirinkimai neįtraukiami į konfigūracijos importą / eksportą. Bandomasis režimas tik parodo planuojamą šalinimą žurnale.

- Paleisties sąraše rodomi HKCU ir HKLM `Run` / `RunOnce` įrašai (32 ir 64 bitų registro rodiniai) bei dabartinio naudotojo ir visų naudotojų paleisties aplankų failai. Šalinamas automatinio paleidimo įrašas arba paleisties failas; pati programa neišdiegiama.
- Užduočių sąraše rodomas kelias, būsena ir veiksmai. Windows sisteminės užduotys (`\Microsoft\`) pagal nutylėjimą paslėptos ir pažymėtos žyma **Windows**. Vykdomos užduotys nešalinamos.
- Prieš šalinimą tikrinama, ar įrašas nepasikeitė, ir išsaugoma atsarginė kopija. Jei kopijos išsaugoti nepavyksta, įrašas nešalinamas.

Kopijų vieta: `%LOCALAPPDATA%\FreshWindowsSetup\RemovalBackups\`. Kiekvienas pašalinimas turi atskirą aplanką, kurio kelias įrašomas žurnale.

**Atkūrimas:** paleisties failą nukopijuokite į pradinį kelią, nurodytą `startup.xml` (šį failą galima perskaityti su `Import-Clixml`). Registro įrašui administratoriaus PowerShell lange naudokite:

```powershell
$entry = Import-Clixml -LiteralPath 'C:\kelias\iki\kopijos\startup.xml'
$base = [Microsoft.Win32.RegistryKey]::OpenBaseKey(
    [Microsoft.Win32.RegistryHive]$entry.Hive,
    [Microsoft.Win32.RegistryView]$entry.View)
try {
    $key = $base.CreateSubKey($entry.Path)
    try { $key.SetValue($entry.ValueName, $entry.Value, [Microsoft.Win32.RegistryValueKind]$entry.ValueKind) }
    finally { $key.Dispose() }
} finally { $base.Dispose() }
```

Užduočių planuoklyje pasirinkite **Import Task** ir atverkite `task.xml`. Pradinį užduoties aplanką ir pavadinimą rasite `task-location.xml` su `Import-Clixml`. Slaptažodžiai ir užduoties prieigos leidimai neįtraukiami į XML; juos gali reikėti nustatyti iš naujo.

## Patikra ir žurnalas

Po kiekvieno Windows nustatymo programa perskaito faktinę reikšmę ir palygina ją su numatyta. Rezultatai rodomi skiltyje **Žurnalas**: klaidos – raudonai, įspėjimai – geltonai. Žurnalo failas:

```text
%TEMP%\FreshWindowsSetup-*.log
```

Jei programa paleista kita administratoriaus paskyra nei prisijungęs naudotojas, viršuje rodomas įspėjimas: naudotojo nustatymai (HKCU) tokiu atveju pritaikomi administratoriaus paskyrai.

## Reikalavimai

- Windows 11;
- administratoriaus teisės;
- interneto ryšys programoms diegti;
- Windows PowerShell 5.1;
- WinGet (jei nerastas, programa bando užregistruoti Microsoft App Installer).

## Kūrėjams

Testai (Windows PowerShell 5.1, administratoriaus teisių nereikia, sistema nekeičiama):

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Catalog.Tests.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Removal.Tests.ps1
```

`Catalog.Tests.ps1` tikrina, ar visos parinktys turi aprašymus ir unikalius raktus, ar kiekvienam nustatymui yra apdorojimo šaka, ar teisingi plėtinių ID, WinGet išėjimo kodų apdorojimą, lietuviškų kabučių klaidas eilutėse ir ar sąsaja įsikelia.

EXE kūrimas su [PS2EXE](https://github.com/MScholtes/PS2EXE) (sąsajai būtinas `-STA`):

```powershell
Invoke-PS2EXE -InputFile .\FreshWindowsSetup.UI.ps1 -OutputFile .\FreshWindowsSetup.UI.exe -STA -NoConsole -RequireAdmin -DPIAware -Title 'Fresh Windows Setup' -Description 'Fresh Windows Setup' -Product 'Fresh Windows Setup' -Company 'Emocinis Taikinys' -Version '2.0.0'
```

`-NoConsole` – jokio konsolės lango; WinGet išvestis skaitoma tiesiogiai UTF-8 koduote, todėl lietuviški ir kiti simboliai žurnale nesugadinami. Nenaudokite `-winFormsDPIAware` ar `-configFile` – tada `.config` failas nekuriamas ir lieka vienas EXE. Sukūrę EXE, atnaujinkite `SHA256SUMS.txt`.

## Svarbu

- Prieš vykdydami peržiūrėkite skiltį **Peržiūra prieš vykdymą**, ypač „Atkreipkite dėmesį“ sąrašą.
- Sistemos atkūrimo ir atsarginių kopijų išjungimas sumažina atkūrimo galimybes gedimo atveju.
- Programų šalinimas ir sistemos politikų keitimas gali paveikti kitų programų veikimą.

## Versijos istorija

| Versija | Data       | Aprašymas                                      |
|---------|------------|------------------------------------------------|
| 1.0.0   | ?          | Pradinis leidimas                              |
| 1.2.0   | ?          | Ankstesnis pažymėtas leidimas                  |
| 1.3.0   | 2026-09-12 | Pagrindiniai pataisymai, klaidų taisymai, UI  |
| 1.4.0   | 2026-10-05 | Paleisties programų ir suplanuotų užduočių šalinimas su kopijomis |
| 2.0.0   | 2026-10-25 | Nauja sąsaja, aprašymai, peržiūra, bandomasis režimas, Smart HDR Manager, Tampermonkey, daugiau parinkčių |

### v2.0.0

- **Nauja WPF sąsaja**: šoninis meniu, parinkčių kortelės su aprašymais ir žymomis, paieška, peržiūra prieš vykdymą, bandomojo režimo jungiklis, importo / eksporto mygtukai, vykdymas fone su eiga ir stabdymu.
- **Smart HDR Manager** diegimas iš stabilaus GitHub leidimo su SHA256 patikra, architektūros parinkimu ir pakartotinio diegimo praleidimu.
- **Tampermonkey** ir dar 4 papildomi Vivaldi plėtiniai; esami politikos įrašai nebeperrašomi.
- 15 naujų programų, 12 naujų šalinamų programėlių, 19 naujų Windows nustatymų – visi pagal nutylėjimą nepažymėti.
- Pataisyta: v1.4.x skriptai nebuvo paleidžiami dėl pasikartojančio kodo failo gale.
- Pataisyta: suplanuotų užduočių sąraše buvo rodomos tik šakninio aplanko užduotys.
- Pataisyta: paleidus be administratoriaus teisių, persikraunant prarasdavo `-DryRun` ir kitus parametrus (bandomasis paleidimas tapdavo tikru).
- Pataisyta: `-DryRun` ir eksportas užstrigdavo, kai buvo pažymėti oficialių puslapių įrašai; importas neatkurdavo nustatymų ir nenuimdavo numatytųjų pažymėjimų.
- Pataisyta: WinGet „reikia perkrauti“ (3010) ir „jau įdiegta“ kodai laikomi sėkme, kartojamos tik laikinos klaidos; įdiegimo patikra naudoja išėjimo kodą vietoj sutrumpintos lentelės.
- Pataisyta: valdiklių išjungimas Windows 11 24H2+ (UCPD blokuoja `TaskbarDa`) – naudojama politika.
- Supaprastinta: vienas šaltinis `FreshWindowsSetup.UI.ps1` ir vienas EXE failas be konsolės lango ir be `.config`; pasikartojanti `FreshWindowsSetup.ps1` kopija pašalinta.
- `Xbox Identity Provider` ir `Xbox TCUI` pagal nutylėjimą nebešalinami.

### v1.3.0 pataisymai

- **OneDrive šalinimas**: Dabar sustabdo vykstantį `OneDrive` procesą prieš `/uninstall`, kad išvengtų 0x80070005 prieigos klaidos. Klaidos pranešamos kaip WARN vietoj crash'ų.
- **Edge registras**: `MicrosoftEdgeAutoLaunch` šalinimas apsaugotas try/catch — raktas gali neegzistuoti švariose sistemose.
- **HideWidgets (Dsh politika)**: HKLM rašymas apsaugotas try/catch su WARN, jei trūksta administratoriaus teisių. HKCU pusė vis tiek taikoma.
- **yt-dlp klaidos**: Null-safe išimties pranešimo fiksavimas neleidžia tuščio eilutės crash'ui įvykti.

---

**Versija:** 2.0.0
**Autorius:** Emocinis Taikinys
