#Requires -Version 5.1
<#
Fresh Windows Setup
A single-file, first-boot Windows configuration utility.
All system changes are selectable in the interface and logged.

Made by Emocinis Taikinys
#>

[CmdletBinding()]
param(
    [switch]$ValidateOnly,
    [switch]$DryRun,
    [string]$ExportConfig,
    [string]$ImportConfig,
    [switch]$Uninstall
)

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'
$AppName = 'Fresh Windows Setup'
$AppVersion = '2.0.0'
$AppAuthor = 'Emocinis Taikinys'

# Relative paths must survive the elevated relaunch, which starts in System32.
if ($ExportConfig) { $ExportConfig = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ExportConfig) }
if ($ImportConfig) { $ImportConfig = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($ImportConfig) }

# Optional item fields: Description, Category, Risk ('Caution' | 'High'), Effect ('Explorer' | 'SignOut' | 'Reboot').
$ProgramCatalog = @(
    [pscustomobject]@{ Category = 'Naršyklės ir bendravimas'; Name = 'Vivaldi'; InstallType = 'WinGet'; Id = 'Vivaldi.Vivaldi'; Source = 'winget'; Default = $true; Description = 'Greita ir labai pritaikoma Chromium pagrindo naršyklė su integruotu reklamų blokavimu. Skilties „Vivaldi plėtiniai“ plėtiniai įdiegiami būtent jai.' }
    [pscustomobject]@{ Category = 'Naršyklės ir bendravimas'; Name = 'qBittorrent'; InstallType = 'WinGet'; Id = 'qBittorrent.qBittorrent'; Source = 'winget'; Default = $true; Description = 'Atvirojo kodo BitTorrent klientas be reklamų, su integruota paieška ir atsisiuntimų planavimu.' }
    [pscustomobject]@{ Category = 'Naršyklės ir bendravimas'; Name = 'Discord'; InstallType = 'WinGet'; Id = 'Discord.Discord'; Source = 'winget'; Default = $false; Description = 'Balso, vaizdo ir teksto pokalbiai draugams, bendruomenėms ir žaidimams.' }
    [pscustomobject]@{ Category = 'Naršyklės ir bendravimas'; Name = 'Bitwarden (darbalaukio programa)'; InstallType = 'WinGet'; Id = 'Bitwarden.Bitwarden'; Source = 'winget'; Default = $false; Description = 'Atvirojo kodo slaptažodžių tvarkyklė kompiuteriui. Naršyklės plėtinys pažymimas atskirai skiltyje „Vivaldi plėtiniai“.' }
    [pscustomobject]@{ Category = 'Naršyklės ir bendravimas'; Name = 'ChatGPT'; InstallType = 'OfficialPage'; Url = 'https://chatgpt.com/download/'; Default = $true; Description = 'Atveriamas oficialus OpenAI atsisiuntimo puslapis. Programą atsisiųskite ir įdiekite rankiniu būdu.' }

    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'PotPlayer (64 bitų)'; InstallType = 'WinGet'; Id = 'Daum.PotPlayer'; Source = 'winget'; Default = $true; Description = 'Galingas vaizdo grotuvas su plačiu kodekų palaikymu, HDR išvestimi ir išsamiais subtitrų nustatymais.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'VLC media player'; InstallType = 'WinGet'; Id = 'VideoLAN.VLC'; Source = 'winget'; Default = $false; Description = 'Universalus atvirojo kodo grotuvas, atkuriantis beveik bet kokį failą, diską ar tinklo srautą.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'Stremio'; InstallType = 'WinGet'; Id = 'Stremio.Stremio'; Source = 'winget'; Default = $true; Description = 'Filmų ir serialų katalogas su papildiniais, žiūrėjimo istorija ir sinchronizavimu tarp įrenginių.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'yt-dlp'; InstallType = 'WinGet'; Id = 'yt-dlp.yt-dlp'; Source = 'winget'; Default = $true; Description = 'Komandinės eilutės įrankis vaizdo ir garso atsisiuntimui iš YouTube ir tūkstančių kitų svetainių. WinGet kartu įdiegia FFmpeg ir Deno.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'OBS Studio'; InstallType = 'WinGet'; Id = 'OBSProject.OBSStudio'; Source = 'winget'; Default = $false; Description = 'Ekrano ir žaidimų įrašymas bei tiesioginės transliacijos į Twitch, YouTube ir kitas platformas.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'ShareX'; InstallType = 'WinGet'; Id = 'ShareX.ShareX'; Source = 'winget'; Default = $false; Description = 'Ekrano nuotraukos, GIF ir trumpi ekrano įrašai su žymėjimu ir automatiniu įkėlimu.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'Smart HDR Manager'; InstallType = 'GitHubReleaseZip'; Repository = 'VantaCode420/SmartHdrManager'; AssetPattern = '-win-{arch}-standalone\.zip$'; Executable = 'SmartHdrManager.exe'; InstallFolder = 'SmartHdrManager'; UserScript = 'SmartHdrManager_YouTube.user.js'; Risk = 'Caution'; Default = $false; Description = 'Sistemos dėklo programa, kuri automatiškai įjungia Windows HDR paleidus HDR žaidimą ar vaizdo įrašą ir grąžina SDR, kai jie baigiasi. Diegiama naujausia stabili versija iš GitHub (savarankiškas paketas, .NET nereikia), tikrinama SHA256 suma. Kūrėjas išbandė tik su NVIDIA; AMD ir Intel nepatvirtinta. YouTube aptikimui reikia Tampermonkey.' }
    [pscustomobject]@{ Category = 'Medija ir HDR'; Name = 'Windows HDR Calibration'; InstallType = 'WinGet'; Id = '9N7F2SM5D1LR'; Source = 'msstore'; Default = $true; Description = 'Oficiali Microsoft programa HDR ekrano ryškumui ir spalvų sodrumui sukalibruoti. Rekomenduojama prieš pradedant naudoti HDR.' }

    [pscustomobject]@{ Category = 'Žaidimai'; Name = 'Steam'; InstallType = 'WinGet'; Id = 'Valve.Steam'; Source = 'winget'; Default = $true; Description = 'Valve žaidimų parduotuvė, biblioteka ir bendruomenė.' }
    [pscustomobject]@{ Category = 'Žaidimai'; Name = 'Epic Games Launcher'; InstallType = 'WinGet'; Id = 'EpicGames.EpicGamesLauncher'; Source = 'winget'; Default = $false; Description = 'Epic Games parduotuvė, įskaitant kas savaitę dalijamus nemokamus žaidimus.' }
    [pscustomobject]@{ Category = 'Žaidimai'; Name = 'MSI Afterburner'; InstallType = 'WinGet'; Id = 'Guru3D.Afterburner'; Source = 'winget'; Default = $false; Description = 'Vaizdo plokštės stebėjimas, ventiliatorių kreivės, įtampos ir dažnių reguliavimas. Veikia su bet kurio gamintojo plokštėmis.' }

    [pscustomobject]@{ Category = 'Įrankiai'; Name = '7-Zip'; InstallType = 'WinGet'; Id = '7zip.7zip'; Source = 'winget'; Default = $false; Description = 'Archyvų tvarkyklė (7z, ZIP, RAR, TAR ir kt.) su integracija į failų naršyklės kontekstinį meniu.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'Notepad++'; InstallType = 'WinGet'; Id = 'Notepad++.Notepad++'; Source = 'winget'; Default = $true; Description = 'Lengvas teksto ir kodo redaktorius su sintaksės paryškinimu ir kortelėmis. Gera alternatyva pašalinamam Windows Notepad.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'Everything'; InstallType = 'WinGet'; Id = 'voidtools.Everything'; Source = 'winget'; Default = $false; Description = 'Akimirksniu randa failus ir aplankus pagal pavadinimą visuose NTFS diskuose.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'PowerToys'; InstallType = 'WinGet'; Id = 'Microsoft.PowerToys'; Source = 'winget'; Default = $false; Description = 'Microsoft įrankių rinkinys: FancyZones langų išdėstymui, PowerRename, spalvų parinkiklis, Peek, klaviatūros perskirstymas ir kt.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'Icaros'; InstallType = 'WinGet'; Id = 'Xanashi.Icaros'; Source = 'winget'; Default = $true; Description = 'Failų naršyklei prideda miniatiūras ir savybes MKV, FLAC, WebM ir kitiems formatams.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'HWiNFO'; InstallType = 'WinGet'; Id = 'REALiX.HWiNFO'; Source = 'winget'; Default = $false; Description = 'Išsami aparatinės įrangos informacija ir jutiklių (temperatūrų, įtampų, dažnių) stebėjimas realiu laiku.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'OpenRGB'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGB'; Source = 'winget'; Default = $true; Description = 'Viena programa skirtingų gamintojų RGB apšvietimui valdyti be gamintojų programų.' }
    [pscustomobject]@{ Category = 'Įrankiai'; Name = 'OpenRGB Effects Plugin'; InstallType = 'WinGet'; Id = 'OpenRGB.OpenRGBEffectsPlugin'; Source = 'winget'; Default = $true; Description = 'Papildomi animuoti apšvietimo efektai OpenRGB programai.' }

    [pscustomobject]@{ Category = 'Programavimas ir komponentai'; Name = 'Python 3.14'; InstallType = 'WinGet'; Id = 'Python.Python.3.14'; Source = 'winget'; Default = $true; Description = 'Python interpretatorius su pip paketų tvarkykle.' }
    [pscustomobject]@{ Category = 'Programavimas ir komponentai'; Name = 'Visual Studio Code'; InstallType = 'WinGet'; Id = 'Microsoft.VisualStudioCode'; Source = 'winget'; Default = $false; Description = 'Nemokamas Microsoft kodo redaktorius su tūkstančiais plėtinių.' }
    [pscustomobject]@{ Category = 'Programavimas ir komponentai'; Name = 'Git'; InstallType = 'WinGet'; Id = 'Git.Git'; Source = 'winget'; Default = $false; Description = 'Versijų kontrolės sistema; kartu įdiegiamas Git Bash.' }
    [pscustomobject]@{ Category = 'Programavimas ir komponentai'; Name = 'Visual C++ 2015–2022 Redistributable (x64)'; InstallType = 'WinGet'; Id = 'Microsoft.VCRedist.2015+.x64'; Source = 'winget'; Default = $false; Description = 'Bibliotekos, kurių reikia daugeliui žaidimų ir programų. Dažniausiai jos įdiegiamos kartu su programomis, bet iš anksto įdiegtos padeda išvengti „VCRUNTIME140.dll nerastas“ klaidų.' }

    [pscustomobject]@{ Category = 'Tvarkyklės (oficialūs puslapiai)'; Name = 'AMD tvarkyklės'; InstallType = 'OfficialPage'; Url = 'https://www.amd.com/en/support/download/drivers.html'; Default = $true; Description = 'Atveriamas AMD tvarkyklių puslapis. Atsisiųskite „AMD Software: Adrenalin Edition“ automatinio aptikimo įrankį ir įdiekite rankiniu būdu.' }
    [pscustomobject]@{ Category = 'Tvarkyklės (oficialūs puslapiai)'; Name = 'NVIDIA app'; InstallType = 'OfficialPage'; Url = 'https://www.nvidia.com/en-us/software/nvidia-app/'; Default = $false; Description = 'Atveriamas NVIDIA app puslapis: GeForce tvarkyklės, žaidimų nustatymai ir RTX Video HDR.' }
    [pscustomobject]@{ Category = 'Tvarkyklės (oficialūs puslapiai)'; Name = 'TP-Link Archer TBE550E tvarkyklės'; InstallType = 'OfficialPage'; Url = 'https://www.tp-link.com/en/support/download/archer-tbe550e/'; Default = $true; Description = 'Atveriamas TP-Link palaikymo puslapis su Wi-Fi 7 ir Bluetooth tvarkyklėmis šiai PCIe plokštei.' }
)

$VivaldiExtensionCatalog = @(
    [pscustomobject]@{ Name = 'Bitwarden slaptažodžių tvarkyklė'; Id = 'nngceckbapebfimnlniiiahkandclblb'; Default = $true; Description = 'Slaptažodžių tvarkyklė naršyklėje: automatinis prisijungimo duomenų įvedimas, saugių slaptažodžių generavimas ir sinchronizavimas.' }
    [pscustomobject]@{ Name = 'Tampermonkey'; Id = 'dhdgffkkebhmkfjojejmpbldmpobfkfo'; Default = $true; Description = 'Naudotojo scenarijų (userscript) tvarkyklė. Reikalinga Smart HDR Manager YouTube HDR aptikimui ir kitiems scenarijams. Vivaldi / Chromium 138+ po įdiegimo atverkite vivaldi://extensions → Tampermonkey → „Details“ ir įjunkite „Allow User Scripts“.'; PostInstallNote = 'Tampermonkey: po pirmo Vivaldi paleidimo atverkite vivaldi://extensions → Tampermonkey → „Details“ ir įjunkite „Allow User Scripts“, kitaip scenarijai neveiks.' }
    [pscustomobject]@{ Name = 'Hide Scrollbar'; Id = 'gngenlhkmpneoiicndbjghjhpogdcncl'; Default = $true; Description = 'Paslepia slinkties juostas tinklalapiuose; slinkimas pele ir klaviatūra veikia kaip įprasta.' }
    [pscustomobject]@{ Name = 'Imagus Reborn'; Id = 'fcjmgeodgobggcppooncdagfkogfffdm'; Default = $true; Description = 'Užvedus pelę ant miniatiūros ar nuorodos parodo pilno dydžio paveikslėlį ar vaizdo įrašą.' }
    [pscustomobject]@{ Name = 'SponsorBlock for YouTube'; Id = 'mnjggcdmjocbbbhaepdhchncahnbgone'; Default = $true; Description = 'Praleidžia rėmėjų intarpus, raginimus prenumeruoti ir kitus bendruomenės pažymėtus YouTube vaizdo įrašų segmentus.' }
    [pscustomobject]@{ Name = 'YouTube Inline Fullscreen'; Id = 'mfpkbigjnlcgngkdbmnchfnenfmibkig'; Default = $true; Description = 'YouTube vaizdo įrašą išplečia per visą naršyklės langą, neperjungiant viso ekrano režimo.' }
    [pscustomobject]@{ Name = 'uBlock Origin Lite'; Id = 'ddkjiahejlhfcafbddmgiahcphecmpfh'; Default = $false; Description = 'Lengvas reklamų ir sekiklių blokatorius (Manifest V3). Vivaldi turi savo blokatorių, todėl naudokite tik vieną iš jų.' }
    [pscustomobject]@{ Name = 'Dark Reader'; Id = 'eimadpbcbfnmbkopoojfekhnkhdbieeh'; Default = $false; Description = 'Tamsus režimas bet kuriai svetainei su ryškumo ir kontrasto nustatymais.' }
    [pscustomobject]@{ Name = 'Return YouTube Dislike'; Id = 'gebbhagfogifgggkldgodflihgfeippi'; Default = $false; Description = 'Grąžina „Nepatinka“ skaičių YouTube vaizdo įrašuose (bendruomenės duomenys).' }
    [pscustomobject]@{ Name = 'DeArrow'; Id = 'enamippconapkdmgfgjchkhakpfinmaj'; Default = $false; Description = 'Pakeičia klaidinančius YouTube pavadinimus ir miniatiūras bendruomenės sukurtais. SponsorBlock kūrėjų projektas.' }
)

# This is intentionally conservative. Core components and frameworks are excluded.
$BundledAppCatalog = @(
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Clipchamp'; Package = 'Clipchamp.Clipchamp'; Default = $true; Description = 'Iš anksto įdiegtas Microsoft vaizdo įrašų redaktorius.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Dev Home'; Package = 'Microsoft.Windows.DevHome'; Default = $true; Description = 'Programuotojams skirtas valdymo skydelis, kurio Microsoft nebeplėtoja.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Atsiliepimų telkinys (Feedback Hub)'; Package = 'Microsoft.WindowsFeedbackHub'; Default = $true; Description = 'Atsiliepimų ir klaidų pranešimų siuntimas Microsoft. Reikalingas tik Windows Insider dalyviams.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft 365 (Office) programėlė'; Package = 'Microsoft.MicrosoftOfficeHub'; Default = $true; Description = 'Office paleidimo ir prenumeratos reklamos programėlė (ne pats Office paketas).' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft naujienos'; Package = 'Microsoft.BingNews'; Default = $true; Description = 'MSN naujienų programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft orai'; Package = 'Microsoft.BingWeather'; Default = $true; Description = 'MSN orų programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft Solitaire Collection'; Package = 'Microsoft.MicrosoftSolitaireCollection'; Default = $true; Description = 'Kortų žaidimai su reklamomis ir prenumerata.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Žmonės (People)'; Package = 'Microsoft.People'; Default = $true; Description = 'Kontaktų programėlė; naujose Windows versijose dažniausiai jau nebeįdiegta.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Užrašinė (Notepad)'; Package = 'Microsoft.WindowsNotepad'; Default = $true; Description = 'Windows Notepad. Pažymėkite, jei vietoj jo naudosite Notepad++ ar kitą redaktorių.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Copilot'; Package = 'Microsoft.Copilot'; Default = $false; Description = 'Microsoft Copilot dirbtinio intelekto asistento programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Outlook (naujasis)'; Package = 'Microsoft.OutlookForWindows'; Default = $false; Description = 'Naujoji Outlook pašto programėlė, pakeitusi „Mail and Calendar“.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft Teams (asmeninė)'; Package = 'MSTeams'; Default = $false; Description = 'Iš anksto įdiegta Teams programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Microsoft To Do'; Package = 'Microsoft.Todos'; Default = $false; Description = 'Užduočių sąrašų programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Power Automate'; Package = 'Microsoft.PowerAutomateDesktop'; Default = $false; Description = 'Darbalaukio veiksmų automatizavimo įrankis.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Gauti pagalbos (Get Help)'; Package = 'Microsoft.GetHelp'; Default = $false; Description = 'Microsoft pagalbos ir trikčių šalinimo programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Patarimai (Tips)'; Package = 'Microsoft.Getstarted'; Default = $false; Description = 'Windows patarimų ir pristatymo programėlė.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Bing paieška'; Package = 'Microsoft.BingSearch'; Default = $false; Description = 'Bing paieškos programėlė, kurią Microsoft įdiegia kartu su naujinimais.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Žemėlapiai'; Package = 'Microsoft.WindowsMaps'; Default = $false; Description = 'Windows žemėlapių programėlė, kurią Microsoft nutraukia.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Telefono saitas (Phone Link)'; Package = 'Microsoft.YourPhone'; Default = $false; Description = 'Telefono susiejimas: SMS, pranešimai ir nuotraukos kompiuteryje. Pašalinkite, jei nenaudojate.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Greitoji pagalba (Quick Assist)'; Package = 'MicrosoftCorporationII.QuickAssist'; Default = $false; Description = 'Nuotolinė pagalba per Microsoft paskyrą. Ją dažnai išnaudoja sukčiai, apsimetę techninės pagalbos darbuotojais.' }
    [pscustomobject]@{ Category = 'Microsoft programėlės'; Name = 'Lipnieji lapeliai (Sticky Notes)'; Package = 'Microsoft.MicrosoftStickyNotes'; Default = $false; Description = 'Darbalaukio užrašų lapeliai.' }

    [pscustomobject]@{ Category = 'Xbox'; Name = 'Xbox programėlė'; Package = 'Microsoft.GamingApp'; Default = $true; Description = 'Xbox / PC Game Pass programėlė. Reikalinga Game Pass žaidimams diegti.' }
    [pscustomobject]@{ Category = 'Xbox'; Name = 'Xbox Game Bar'; Package = 'Microsoft.XboxGamingOverlay'; Risk = 'Caution'; Default = $true; Description = 'Win+G perdanga su našumo valdikliais, įrašymu ir Xbox pokalbiais. Pašalinus Win+G nebeveiks.' }
    [pscustomobject]@{ Category = 'Xbox'; Name = 'Xbox Identity Provider'; Package = 'Microsoft.XboxIdentityProvider'; Risk = 'High'; Default = $false; Description = 'Xbox paskyros prisijungimas žaidimuose. Pašalinus nebeveiks prisijungimas Game Pass, Microsoft Store ir kai kuriuose Steam žaidimuose, naudojančiuose Xbox paskyrą.' }
    [pscustomobject]@{ Category = 'Xbox'; Name = 'Xbox Speech-to-Text Overlay'; Package = 'Microsoft.XboxSpeechToTextOverlay'; Default = $true; Description = 'Kalbos vertimo į tekstą perdanga Xbox pokalbiams.' }
    [pscustomobject]@{ Category = 'Xbox'; Name = 'Xbox TCUI'; Package = 'Microsoft.Xbox.TCUI'; Risk = 'Caution'; Default = $false; Description = 'Xbox draugų, pokalbių ir profilio langai žaidimuose. Kai kurie Xbox paskyrą naudojantys žaidimai be jo neprisijungia.' }

    [pscustomobject]@{ Category = 'Naršyklė, debesis ir atsarginės kopijos'; Name = 'OneDrive'; Package = 'OneDriveDesktop'; Kind = 'OneDrive'; Default = $true; Description = 'Microsoft debesies saugykla. Debesyje esantys failai lieka, bet nebesinchronizuojami su kompiuteriu.' }
    [pscustomobject]@{ Category = 'Naršyklė, debesis ir atsarginės kopijos'; Name = 'Microsoft Office darbalaukio paketas'; Package = 'Microsoft.Office.Desktop'; Default = $true; Description = 'Iš anksto įdiegtas Office darbalaukio paketas, jei jį pridėjo kompiuterio gamintojas.' }
    [pscustomobject]@{ Category = 'Naršyklė, debesis ir atsarginės kopijos'; Name = 'Windows atsarginis kopijavimas'; Package = 'WindowsBackup'; Kind = 'WindowsBackup'; Risk = 'Caution'; Default = $true; Description = 'Windows Backup ir nustatymų sinchronizavimas išjungiami per politiką. Pati programėlė yra bendro Windows apvalkalo paketo dalis, todėl paliekama.' }
    [pscustomobject]@{ Category = 'Naršyklė, debesis ir atsarginės kopijos'; Name = 'Microsoft Edge'; Package = 'MicrosoftEdge'; Kind = 'Edge'; Risk = 'High'; Default = $true; Description = 'Pašalinama Edge naršyklė, užblokuojamas jos pakartotinis diegimas ir naujinimai. WebView2 paliekamas, nes jo reikia kitoms programoms. Už EEE ribų Microsoft gali neleisti Edge pašalinti.' }
)

$PrivacyCatalog = @(
    [pscustomobject]@{ Name = 'Sumažinti diagnostikos duomenis iki mažiausio palaikomo lygio'; Key = 'DiagnosticData'; Default = $true; Description = 'Diagnostikos duomenys nustatomi į mažiausią leidimo palaikomą lygį (Home ir Pro – „Būtini“), apribojamas žurnalų ir atminties išklotinių siuntimas.' }
    [pscustomobject]@{ Name = 'Išjungti reklamos ID ir suasmenintas reklamas'; Key = 'Advertising'; Default = $true; Description = 'Programos nebegauna reklamos identifikatoriaus ir nerodo pagal jį suasmenintų reklamų.' }
    [pscustomobject]@{ Name = 'Išjungti pagal diagnostikos duomenis pritaikytas funkcijas'; Key = 'TailoredExperiences'; Default = $true; Description = 'Microsoft nenaudos diagnostikos duomenų patarimams, reklamai ir rekomendacijoms suasmeninti.' }
    [pscustomobject]@{ Name = 'Išjungti Windows pasiūlymus ir reklaminį turinį'; Key = 'Suggestions'; Default = $true; Description = 'Išjungia automatinį reklaminių programėlių diegimą ir pasiūlymus Start meniu bei nustatymuose.' }
    [pscustomobject]@{ Name = 'Išjungti atsiliepimų prašymus'; Key = 'Feedback'; Default = $true; Description = 'Windows nebeprašys įvertinti sistemos ar pateikti atsiliepimų.' }
    [pscustomobject]@{ Name = 'Išjungti veiklos istorijos skelbimą ir siuntimą'; Key = 'ActivityHistory'; Default = $true; Description = 'Atidarytų programų ir failų istorija nebekaupiama ir nesiunčiama Microsoft.' }
    [pscustomobject]@{ Name = 'Sumažinti rašymo ir braižymo suasmeninimo duomenų rinkimą'; Key = 'InputPersonalization'; Default = $true; Description = 'Ribojamas renkamas rašymo ir ranka rašyto teksto duomenų kiekis klaviatūros pasiūlymams.' }
    [pscustomobject]@{ Name = 'Išjungti internetinį kalbos atpažinimą'; Key = 'DisableOnlineSpeech'; Default = $false; Description = 'Balso įvestis ir diktavimas nebesiunčia įrašų į Microsoft debesį; veikia tik vietiniai modeliai.' }
    [pscustomobject]@{ Name = 'Išjungti Windows Copilot'; Key = 'DisableCopilot'; Effect = 'SignOut'; Default = $false; Description = 'Politika išjungia integruotą Windows Copilot. Naujose versijose Copilot yra atskira programėlė – ją pašalinkite skiltyje „Integruotos programėlės“.' }
    [pscustomobject]@{ Name = 'Išjungti Windows Recall'; Key = 'DisableRecall'; Effect = 'Reboot'; Default = $false; Description = 'Copilot+ kompiuteriuose išjungia Recall ekrano momentinių kopijų kaupimą ir jų dirbtinio intelekto analizę.' }
)

$WindowsSettingsSections = @(
    [pscustomobject]@{ Title = 'Užduočių juosta ir Start'; Glyph = [char]0xE7C4; Description = 'Užduočių juostos išvaizda, Start meniu turinys ir pagalbiniai mygtukai. Dauguma pakeitimų matomi iškart.'; Items = @(
        [pscustomobject]@{ Name = 'Lygiuoti užduočių juostą kairėje'; Key = 'TaskbarLeft'; Default = $true; Description = 'Start mygtukas ir programų piktogramos perkeliami į kairę, kaip Windows 10.' }
        [pscustomobject]@{ Name = 'Slėpti paiešką užduočių juostoje'; Key = 'HideSearch'; Default = $true; Description = 'Paslepia paieškos laukelį. Paieška vis tiek veikia paspaudus Win ir pradėjus rašyti.' }
        [pscustomobject]@{ Name = 'Slėpti užduočių rodinio mygtuką'; Key = 'HideTaskView'; Default = $false; Description = 'Paslepia „Užduočių rodinio“ mygtuką. Virtualūs darbalaukiai lieka pasiekiami per Win+Tab.' }
        [pscustomobject]@{ Name = 'Slėpti valdiklius užduočių juostoje'; Key = 'HideWidgets'; Default = $true; Description = 'Paslepia valdiklių (orų, naujienų) mygtuką ir politika išjungia naujienų sklaidą.' }
        [pscustomobject]@{ Name = 'Išjungti Start meniu rekomendacijas'; Key = 'DisableStartRecommendations'; Default = $true; Description = 'Start meniu neberodo rekomenduojamų programų ir Microsoft paskyros pranešimų.' }
        [pscustomobject]@{ Name = 'Išjungti neseniai atidarytų elementų rodymą'; Key = 'DisableRecentItems'; Effect = 'Explorer'; Default = $true; Description = 'Start meniu, šuoliniuose sąrašuose ir failų naršyklėje nebekaupiami ir nerodomi neseniai atidaryti failai.' }
        [pscustomobject]@{ Name = 'Start meniu rodyti daugiau prisegtų programų'; Key = 'StartMorePins'; Default = $false; Description = 'Start meniu skiria daugiau vietos prisegtoms programoms ir mažiau rekomendacijoms.' }
        [pscustomobject]@{ Name = 'Įjungti „Baigti užduotį“ užduočių juostoje'; Key = 'TaskbarEndTask'; Default = $false; Description = 'Dešiniuoju pelės mygtuku spustelėjus programą užduočių juostoje atsiranda „Baigti užduotį“ – užstrigusią programą galima uždaryti be užduočių tvarkyklės.' }
        [pscustomobject]@{ Name = 'Rodyti sekundes laikrodyje'; Key = 'ShowSecondsInClock'; Default = $false; Description = 'Užduočių juostos laikrodis rodo ir sekundes.' }
        [pscustomobject]@{ Name = 'Automatiškai slėpti užduočių juostą'; Key = 'TaskbarAutoHide'; Effect = 'Explorer'; Default = $true; Description = 'Užduočių juosta paslepiama ir parodoma užvedus pelę ekrano apačioje – daugiau vietos programoms.' }
    ) }
    [pscustomobject]@{ Title = 'Failų naršyklė'; Glyph = [char]0xEC50; Description = 'Failų naršyklės rodinys, naršymo sritis ir kontekstinis meniu.'; Items = @(
        [pscustomobject]@{ Name = 'Rodyti failų plėtinius'; Key = 'ShowFileExtensions'; Default = $true; Description = 'Rodo .exe, .pdf, .jpg ir kitus plėtinius – lengviau atpažinti tikrąjį failo tipą ir pastebėti apgaulingus failus.' }
        [pscustomobject]@{ Name = 'Rodyti paslėptus failus'; Key = 'ShowHiddenFiles'; Default = $false; Description = 'Rodo paslėptus failus ir aplankus, pavyzdžiui, AppData.' }
        [pscustomobject]@{ Name = 'Failų naršyklę atverti ties „Šis kompiuteris“'; Key = 'ExplorerThisPC'; Default = $true; Description = 'Atidarius failų naršyklę iškart rodomi diskai, o ne „Pagrindinis“.' }
        [pscustomobject]@{ Name = 'Naudoti kompaktišką rodinį'; Key = 'CompactView'; Default = $true; Description = 'Mažesni tarpai tarp failų sąrašo eilučių – telpa daugiau failų.' }
        [pscustomobject]@{ Name = 'Grąžinti klasikinį dešiniojo pelės mygtuko meniu'; Key = 'ClassicContextMenu'; Effect = 'Explorer'; Default = $true; Description = 'Kontekstinis meniu iškart rodo visas parinktis, nereikia spausti „Rodyti daugiau parinkčių“.' }
        [pscustomobject]@{ Name = 'Pašalinti „Galeriją“ iš failų naršyklės'; Key = 'RemoveGallery'; Effect = 'Explorer'; Default = $true; Description = 'Pašalina „Galeriją“ iš naršymo srities kairėje.' }
        [pscustomobject]@{ Name = 'Pašalinti „Pagrindinį“ iš failų naršyklės'; Key = 'RemoveHome'; Effect = 'Explorer'; Default = $true; Description = 'Pašalina „Pagrindinį“ (Home) iš naršymo srities kairėje.' }
        [pscustomobject]@{ Name = 'Greitojoje prieigoje nerodyti naujausių failų'; Key = 'DisableQuickAccessRecent'; Effect = 'Explorer'; Default = $false; Description = 'Greitoji prieiga neberodo neseniai naudotų failų ir dažnai naudojamų aplankų – lieka tik prisegti.' }
        [pscustomobject]@{ Name = 'Išjungti OneDrive ir Microsoft 365 reklamas naršyklėje'; Key = 'DisableSyncProviderAds'; Default = $false; Description = 'Failų naršyklė neberodo sinchronizavimo paslaugų reklaminių pranešimų.' }
        [pscustomobject]@{ Name = 'Rodyti „Šis kompiuteris“ darbalaukyje'; Key = 'ThisPCOnDesktop'; Effect = 'Explorer'; Default = $false; Description = 'Darbalaukyje atsiranda „Šis kompiuteris“ piktograma.' }
    ) }
    [pscustomobject]@{ Title = 'Išvaizda ir naudojimas'; Glyph = [char]0xE790; Description = 'Tema, efektai, paieška ir įvesties įrenginiai.'; Items = @(
        [pscustomobject]@{ Name = 'Įjungti Windows tamsųjį režimą'; Key = 'DarkMode'; Default = $true; Description = 'Tamsus režimas sistemai ir programoms.' }
        [pscustomobject]@{ Name = 'Išjungti permatomumo efektus'; Key = 'DisableTransparency'; Default = $false; Description = 'Užduočių juosta, Start meniu ir langai tampa vienspalviai; šiek tiek sumažėja GPU apkrova.' }
        [pscustomobject]@{ Name = 'Išjungti Bing ir interneto rezultatus Start paieškoje'; Key = 'DisableWebSearch'; Effect = 'SignOut'; Default = $true; Description = 'Start paieška ieško tik kompiuteryje, be Bing rezultatų ir pasiūlymų.' }
        [pscustomobject]@{ Name = 'Išjungti Windows patarimus ir pasiūlymus'; Key = 'DisableTips'; Default = $true; Description = 'Išjungia patarimų, gudrybių ir pasiūlymų pranešimus.' }
        [pscustomobject]@{ Name = 'Išjungti užrakinimo ekrano pasiūlymus'; Key = 'DisableLockScreenSuggestions'; Default = $true; Description = 'Užrakinimo ekrane neberodomi faktai, patarimai ir reklamos.' }
        [pscustomobject]@{ Name = 'Išjungti programų paleidimo delsą'; Key = 'DisableStartupDelay'; Default = $true; Description = 'Paleisties programos paleidžiamos iškart po prisijungimo, be dirbtinio kelių sekundžių laukimo.' }
        [pscustomobject]@{ Name = 'Išjungti pelės pagreitį'; Key = 'DisableMouseAcceleration'; Effect = 'SignOut'; Default = $true; Description = 'Išjungia „Pagerinti žymiklio tikslumą“: žymiklis juda proporcingai pelės judesiui – svarbu žaidimams.' }
        [pscustomobject]@{ Name = 'Išjungti lipniųjų klavišų langą'; Key = 'DisableStickyKeys'; Effect = 'SignOut'; Default = $false; Description = 'Penkis kartus paspaudus Shift neberodomas lipniųjų, perjungimo ir filtro klavišų pasiūlymas – patogu žaidžiant.' }
    ) }
    [pscustomobject]@{ Title = 'Privatumas'; Glyph = [char]0xE72E; Description = 'Telemetrija, reklama, AI funkcijos ir duomenų siuntimas Microsoft.'; Items = $PrivacyCatalog }
    [pscustomobject]@{ Title = 'Sistema ir naujinimai'; Glyph = [char]0xE770; Description = 'Maitinimas, Windows Update elgsena, atkūrimas ir atsarginės kopijos.'; Items = @(
        [pscustomobject]@{ Name = 'Išjungti greitąjį paleidimą'; Key = 'DisableFastStartup'; Default = $true; Description = 'Išjungimas tampa tikru išjungimu: tvarkyklės ir naujinimai įkeliami švariai, nekyla problemų su dviem operacinėmis sistemomis.' }
        [pscustomobject]@{ Name = 'Išjungti užmigdymą (hibernaciją)'; Key = 'DisableHibernation'; Default = $false; Description = 'Ištrinamas hiberfil.sys failas (atlaisvina kelis GB). Kartu išsijungia greitasis paleidimas. Nešiojamuosiuose kompiuteriuose nebeliks užmigdymo režimo.' }
        [pscustomobject]@{ Name = 'Didelio našumo maitinimo schema'; Key = 'HighPerformancePlan'; Default = $false; Description = 'Aktyvuoja „Didelio našumo“ schemą. Nešiojamuosiuose greičiau senka baterija; kai kuriuose įrenginiuose ši schema nepasiekiama.' }
        [pscustomobject]@{ Name = 'Leisti ilgus failų kelius'; Key = 'EnableLongPaths'; Default = $false; Description = 'Leidžia programoms naudoti ilgesnius nei 260 simbolių kelius – naudinga programuotojams (Node.js, Python, Git).' }
        [pscustomobject]@{ Name = 'Nediegti tvarkyklių per Windows Update'; Key = 'ExcludeDriversFromWU'; Risk = 'Caution'; Default = $false; Description = 'Windows Update nebeatnaujins tvarkyklių. Naudinga, kai GPU ir kitas tvarkykles diegiate patys, bet tada už jų atnaujinimą atsakote jūs.' }
        [pscustomobject]@{ Name = 'Neperkrauti automatiškai, kol esu prisijungęs'; Key = 'NoAutoRebootWhileSignedIn'; Default = $false; Description = 'Windows nepaleis kompiuterio iš naujo naujinimams įdiegti, kol esate prisijungę.' }
        [pscustomobject]@{ Name = 'Išjungti naujinimų dalijimąsi su kitais kompiuteriais'; Key = 'DisableDeliveryOptimizationP2P'; Default = $false; Description = 'Naujinimai atsisiunčiami tik iš Microsoft serverių; kompiuteris jais nesidalija su kitais tinklo ar interneto įrenginiais.' }
        [pscustomobject]@{ Name = 'Išjungti sistemos atkūrimą'; Key = 'DisableSystemRestore'; Risk = 'High'; Default = $true; Description = 'Išjungiamas sistemos atkūrimas sistemos diske ir ištrinami esami atkūrimo taškai. Gedimo atveju nebebus galima grąžinti ankstesnės būsenos.' }
        [pscustomobject]@{ Name = 'Išjungti Windows atsarginį kopijavimą ir nustatymų sinchronizavimą'; Key = 'DisableWindowsBackup'; Risk = 'Caution'; Default = $true; Description = 'Išjungiama Windows Backup bei nustatymų, slaptažodžių ir personalizavimo sinchronizavimas su Microsoft paskyra.' }
    ) }
    [pscustomobject]@{ Title = 'Žaidimai ir tinklas'; Glyph = [char]0xE7FC; Description = 'Žaidimų našumas ir namų tinklo nustatymai.'; Items = @(
        [pscustomobject]@{ Name = 'Išjungti Xbox Game Bar įrašymą'; Key = 'DisableGameBarRecording'; Default = $true; Description = 'Išjungia Game DVR fono įrašymą, kuris gali mažinti FPS.' }
        [pscustomobject]@{ Name = 'Įjungti aparatinį GPU planavimą'; Key = 'HardwareGpuScheduling'; Effect = 'Reboot'; Default = $false; Description = 'Įjungia HAGS: mažesnė delsa, reikalinga DLSS kadrų generavimui. Veikia su naujomis AMD ir NVIDIA tvarkyklėmis.' }
        [pscustomobject]@{ Name = 'Nustatyti prijungtus tinklus kaip privačius'; Key = 'PrivateNetwork'; Risk = 'Caution'; Default = $true; Description = 'Prijungti tinklai pažymimi kaip privatūs: veikia failų bendrinimas ir įrenginių aptikimas. Naudokite tik namų tinkle.' }
    ) }
    [pscustomobject]@{ Title = 'Regionas'; Glyph = [char]0xE909; Description = 'Kalbos, regiono ir laiko nustatymai.'; Items = @(
        [pscustomobject]@{ Name = 'Nustatyti Lietuvos regioną ir Vilniaus laiko juostą'; Key = 'LithuaniaRegion'; Effect = 'Reboot'; Default = $true; Description = 'Lietuviškas datos, laiko ir skaičių formatas, namų vieta Lietuva, sistemos lokalė lt-LT (senoms programoms be Unicode) ir Vilniaus laiko juosta.' }
    ) }
)

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not $ValidateOnly -and -not (Test-IsAdministrator)) {
    # Forward every switch and path, otherwise e.g. -DryRun would silently become a real run.
    $forwarded = @()
    foreach ($parameter in $PSBoundParameters.GetEnumerator()) {
        if ($parameter.Value -is [switch]) {
            if ($parameter.Value.IsPresent) { $forwarded += '-' + $parameter.Key }
        } else {
            $forwarded += '-' + $parameter.Key
            $forwarded += '"{0}"' -f $parameter.Value
        }
    }
    $hostProcess = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if (-not $PSCommandPath -and [IO.Path]::GetFileNameWithoutExtension($hostProcess) -in @('powershell', 'pwsh', 'powershell_ise')) {
        throw 'Prieš paleisdami įrašykite šį scenarijų į failą.'
    }
    try {
        if ($PSCommandPath) {
            $arguments = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-STA', '-WindowStyle', 'Hidden', '-File', ('"{0}"' -f $PSCommandPath)) + $forwarded
            Start-Process -FilePath (Join-Path $PSHOME 'powershell.exe') -Verb RunAs -ArgumentList $arguments
        } elseif ($forwarded.Count -gt 0) {
            # Compiled PS2EXE build: relaunch the executable itself.
            Start-Process -FilePath $hostProcess -Verb RunAs -ArgumentList $forwarded
        } else {
            Start-Process -FilePath $hostProcess -Verb RunAs
        }
    } catch {
        Add-Type -AssemblyName PresentationFramework
        [void][System.Windows.MessageBox]::Show('Programai reikia administratoriaus teisių. Paleiskite ją dar kartą ir patvirtinkite užklausą.', $AppName, 'OK', 'Warning')
    }
    exit
}

if ([Threading.Thread]::CurrentThread.GetApartmentState() -ne [Threading.ApartmentState]::STA) {
    throw 'Grafinei sąsajai reikia STA režimo. Paleiskite: powershell.exe -STA -File FreshWindowsSetup.UI.ps1'
}

$script:LogPath = Join-Path $env:TEMP ('FreshWindowsSetup-{0:yyyyMMdd-HHmmss}.log' -f (Get-Date))
# Shared with the background runspace that performs all system changes.
$script:LogQueue = [System.Collections.Concurrent.ConcurrentQueue[object]]::new()
$script:Sync = [hashtable]::Synchronized(@{ Cancel = $false; DryRun = $false; Done = 0; Total = 0; Current = '' })

# Every function defined between here and $BackendFunctionNames is copied into the background runspace.
$functionsBeforeBackend = @(Get-ChildItem -Path function: | ForEach-Object Name)

function Write-SetupLog {
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string]$Message,
        [ValidateSet('INFO', 'OK', 'WARN', 'ERROR')][string]$Level = 'INFO'
    )
    $line = '[{0:HH:mm:ss}] [{1}] {2}' -f (Get-Date), $Level, $Message
    [System.Threading.Monitor]::Enter($script:Sync.SyncRoot)
    try {
        [IO.File]::AppendAllText($script:LogPath, $line + [Environment]::NewLine, [Text.UTF8Encoding]::new($true))
    } catch {
        # Logging must never interrupt a setup step.
    } finally {
        [System.Threading.Monitor]::Exit($script:Sync.SyncRoot)
    }
    $script:LogQueue.Enqueue([pscustomobject]@{ Line = $line; Level = $Level })
}

function Get-OptionalProperty {
    param([Parameter(Mandatory)]$InputObject, [Parameter(Mandatory)][string]$Name)
    $property = $InputObject.PSObject.Properties[$Name]
    if ($null -ne $property) { return $property.Value }
    return $null
}

function Get-CatalogKey {
    param([Parameter(Mandatory)]$Item)
    foreach ($name in @('Key', 'Package', 'Id', 'Repository', 'Url')) {
        $value = Get-OptionalProperty $Item $name
        if (-not [string]::IsNullOrWhiteSpace([string]$value)) { return [string]$value }
    }
    return [string]$Item.Name
}

function Set-RegistryValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet('DWord', 'QWord', 'String', 'ExpandString', 'MultiString', 'Binary')][string]$Type = 'DWord'
    )
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -LiteralPath $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null

    $actual = Get-ItemPropertyValue -LiteralPath $Path -Name $Name -ErrorAction Stop
    if ($Value -is [array]) {
        $expectedText = ($Value | ForEach-Object { [string]$_ }) -join '|'
        $actualText = ($actual | ForEach-Object { [string]$_ }) -join '|'
        $isMatch = $expectedText -ceq $actualText
    } else {
        $isMatch = ([string]$Value) -ceq ([string]$actual)
    }
    if (-not $isMatch) {
        throw "Nepavyko patikrinti $Path\$Name. Tikėtasi '$Value', rasta '$actual'."
    }
    Write-SetupLog "Patikrinta: $Path\$Name = $actual."
}

function Set-RegistryDefaultValue {
    param([Parameter(Mandatory)][string]$Path, [AllowEmptyString()][string]$Value)
    if (-not (Test-Path -LiteralPath $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-Item -LiteralPath $Path -Value $Value -Force
    $actual = (Get-Item -LiteralPath $Path -ErrorAction Stop).GetValue('')
    if ([string]$actual -cne [string]$Value) {
        throw "Nepavyko patikrinti numatytosios registro reikšmės ties $Path."
    }
    Write-SetupLog "Patikrinta numatytoji registro reikšmė: $Path."
}

function Remove-RegistryValue {
    param([Parameter(Mandatory)][string]$Path, [Parameter(Mandatory)][string]$Name)
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-SetupLog "Registro rakto nėra, šalinti nereikia: $Path."
        return
    }
    if ((Get-Item -LiteralPath $Path).GetValueNames() -contains $Name) {
        Remove-ItemProperty -LiteralPath $Path -Name $Name -Force -ErrorAction Stop
    }
    if ((Get-Item -LiteralPath $Path).GetValueNames() -contains $Name) { throw "Nepavyko patikrinti registro reikšmės pašalinimo: $Path\$Name." }
    Write-SetupLog "Patikrinta, kad registro reikšmės nėra: $Path\$Name."
}

function Invoke-LoggedAction {
    param([Parameter(Mandatory)][string]$Description, [Parameter(Mandatory)][scriptblock]$Action)
    if ($script:Sync.Cancel) {
        Write-SetupLog "$Description – praleista (vykdymas sustabdytas)." 'WARN'
        $script:Sync.Done++
        return
    }
    $script:Sync.Current = $Description
    try {
        if ($script:Sync.DryRun) {
            Write-SetupLog "Bandomasis režimas – būtų vykdoma: $Description"
            return
        }
        Write-SetupLog "$Description..."
        & $Action
        Write-SetupLog "$Description – atlikta." 'OK'
    } catch {
        $message = [string]$_.Exception.Message
        if ([string]::IsNullOrWhiteSpace($message)) { $message = 'Nežinoma klaida.' }
        Write-SetupLog "$Description – nepavyko: $message" 'ERROR'
    } finally {
        $script:Sync.Done++
    }
}

function Invoke-NativeCommand {
    param([Parameter(Mandatory)][string]$FilePath, [Parameter(Mandatory)][string[]]$Arguments)
    & $FilePath @Arguments 2>&1 | ForEach-Object { Write-SetupLog ([string]$_) }
    if ($LASTEXITCODE -ne 0) { throw "$FilePath baigė darbą su kodu $LASTEXITCODE." }
}

function Get-WinGetPath {
    $command = Get-Command 'winget.exe' -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }
    # On a fresh install App Installer is present but not yet registered for this account.
    Write-SetupLog 'WinGet nerastas. Bandoma užregistruoti Microsoft App Installer...' 'WARN'
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe' -ErrorAction Stop
    } catch {
        Write-SetupLog "App Installer registracija nepavyko: $($_.Exception.Message)" 'WARN'
    }
    $alias = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
    if (Test-Path -LiteralPath $alias) { return $alias }
    return $null
}

function Invoke-WinGet {
    param([Parameter(Mandatory)][string]$WinGet, [Parameter(Mandatory)][string[]]$Arguments, [int]$MaxAttempts = 3)
    # https://github.com/microsoft/winget-cli/blob/master/doc/windows/package-manager/winget/returnCodes.md
    $successCodes = @{
        0 = $null
        3010 = 'Diegimui užbaigti reikia paleisti Windows iš naujo.'
        1641 = 'Diegimo programa inicijavo Windows paleidimą iš naujo.'
        -1978335189 = 'Naujinimas netaikomas – jau įdiegta naujausia versija.'
        -1978335135 = 'Paketas jau įdiegtas.'
        -1978334967 = 'Diegimui užbaigti reikia paleisti Windows iš naujo.'
    }
    # MSI busy, download failed, another install in progress, no network, service unavailable.
    $transientCodes = @(1618, -1978335224, -1978334974, -1978334969, -1978335123)
    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        & $WinGet @Arguments 2>&1 | ForEach-Object {
            $text = ([string]$_).Trim()
            # Drop spinner frames and progress bars that WinGet prints even when redirected.
            if ($text -and $text -notmatch '^[-\\|/]$' -and $text -notmatch '[█▒]') { Write-SetupLog $text }
        }
        $exitCode = $LASTEXITCODE
        if ($successCodes.ContainsKey($exitCode)) {
            if ($successCodes[$exitCode]) { Write-SetupLog $successCodes[$exitCode] 'WARN' }
            return $exitCode
        }
        $codeText = '{0} (0x{0:X8})' -f $exitCode
        if ($transientCodes -notcontains $exitCode -or $attempt -eq $MaxAttempts) {
            throw "WinGet baigė darbą su kodu $codeText."
        }
        Write-SetupLog "Laikina WinGet klaida $codeText. Bandoma iš naujo ($attempt/$($MaxAttempts - 1))..." 'WARN'
        Start-Sleep -Seconds (5 * $attempt)
    }
}

function Test-WinGetPackageInstalled {
    param([Parameter(Mandatory)][string]$WinGet, [Parameter(Mandatory)][string]$Id, [string]$Source = 'winget')
    # Exit code is reliable; the table output truncates long IDs.
    $null = & $WinGet list --id $Id --exact --source $Source --accept-source-agreements --disable-interactivity 2>&1
    return ($LASTEXITCODE -eq 0)
}

function Install-GitHubReleaseZip {
    param([Parameter(Mandatory)]$Item)
    $nativeArchitecture = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITEW6432')
    if (-not $nativeArchitecture) { $nativeArchitecture = [Environment]::GetEnvironmentVariable('PROCESSOR_ARCHITECTURE') }
    $architecture = if ($nativeArchitecture -eq 'ARM64') { 'arm64' } else { 'x64' }
    $assetPattern = $Item.AssetPattern.Replace('{arch}', $architecture)
    $installPath = Join-Path $env:LOCALAPPDATA ('Programs\' + $Item.InstallFolder)
    $installedExe = Join-Path $installPath $Item.Executable
    $versionMarker = Join-Path $installPath '.fresh-windows-setup-version'
    $headers = @{ 'User-Agent' = 'FreshWindowsSetup'; 'Accept' = 'application/vnd.github+json' }
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

    $response = Invoke-RestMethod -Uri ('https://api.github.com/repos/{0}/releases?per_page=20' -f $Item.Repository) -Headers $headers -Method Get
    # Windows PowerShell returns a JSON array as one pipeline object; unroll it into releases.
    $releases = @($response | ForEach-Object { $_ })
    $release = $null
    $asset = $null
    foreach ($candidate in $releases) {
        if ($candidate.draft -or $candidate.prerelease) { continue }
        $asset = @($candidate.assets | Where-Object { $_.name -match $assetPattern }) | Select-Object -First 1
        if ($null -ne $asset) { $release = $candidate; break }
    }
    if ($null -eq $asset) { throw "Stabiliuose GitHub leidimuose nerastas tinkamas failas ($assetPattern)." }

    if ((Test-Path -LiteralPath $installedExe) -and (Test-Path -LiteralPath $versionMarker) -and ((Get-Content -LiteralPath $versionMarker -Raw).Trim() -eq $release.tag_name)) {
        Write-SetupLog "$($Item.Name) $($release.tag_name) jau įdiegta. Praleidžiama." 'OK'
        return
    }

    $workPath = Join-Path $env:TEMP ('FreshWindowsSetup-' + [guid]::NewGuid().ToString('N'))
    $zipPath = Join-Path $workPath $asset.name
    $stagingPath = Join-Path $workPath 'extracted'
    $previousProgressPreference = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    try {
        [void][IO.Directory]::CreateDirectory($stagingPath)
        Write-SetupLog ('Atsisiunčiama {0} ({1}, {2:N1} MB)...' -f $asset.name, $release.tag_name, ($asset.size / 1MB))
        Invoke-WebRequest -Uri $asset.browser_download_url -Headers @{ 'User-Agent' = 'FreshWindowsSetup' } -OutFile $zipPath -UseBasicParsing
        if ((Get-Item -LiteralPath $zipPath).Length -ne [int64]$asset.size) { throw 'Atsisiųsto archyvo dydis nesutampa su GitHub nurodytu.' }

        $checksumAsset = @($release.assets | Where-Object { $_.name -eq 'SHA256SUMS.txt' }) | Select-Object -First 1
        if ($null -ne $checksumAsset) {
            $sumsPath = Join-Path $workPath 'SHA256SUMS.txt'
            Invoke-WebRequest -Uri $checksumAsset.browser_download_url -Headers @{ 'User-Agent' = 'FreshWindowsSetup' } -OutFile $sumsPath -UseBasicParsing
            $expected = $null
            foreach ($line in [IO.File]::ReadAllLines($sumsPath)) {
                if ($line -match '^\s*([0-9a-fA-F]{64})\s+\*?(.+?)\s*$' -and $Matches[2] -eq $asset.name) { $expected = $Matches[1]; break }
            }
            if (-not $expected) { throw "SHA256SUMS.txt neturi įrašo failui $($asset.name)." }
            $actual = (Get-FileHash -LiteralPath $zipPath -Algorithm SHA256).Hash
            if ($actual -ne $expected) { throw "SHA256 nesutampa: tikėtasi $expected, gauta $actual. Diegimas nutrauktas." }
            Write-SetupLog "SHA256 patikrinta: $actual."
        } else {
            Write-SetupLog 'Leidime nėra SHA256SUMS.txt, todėl kontrolinė suma netikrinta.' 'WARN'
        }

        Expand-Archive -LiteralPath $zipPath -DestinationPath $stagingPath -Force
        $sourceExe = Get-ChildItem -LiteralPath $stagingPath -Filter $Item.Executable -File -Recurse | Select-Object -First 1
        if ($null -eq $sourceExe) { throw "Archyve nerastas $($Item.Executable); diegimas nutrauktas." }

        # Only stop the copy this tool manages; a copy the user runs from elsewhere is left alone.
        $installRoot = [IO.Path]::GetFullPath($installPath).TrimEnd('\') + '\'
        $running = @(Get-Process -Name ([IO.Path]::GetFileNameWithoutExtension($Item.Executable)) -ErrorAction SilentlyContinue |
            Where-Object { $_.Path -and $_.Path.StartsWith($installRoot, [StringComparison]::OrdinalIgnoreCase) })
        foreach ($process in $running) {
            Write-SetupLog "Uždaroma veikianti $($Item.Executable), kad ją būtų galima atnaujinti." 'WARN'
            $process | Stop-Process -Force
            [void]$process.WaitForExit(5000)
        }
        [void][IO.Directory]::CreateDirectory($installPath)
        Copy-Item -Path (Join-Path $sourceExe.DirectoryName '*') -Destination $installPath -Recurse -Force
        if (-not (Test-Path -LiteralPath $installedExe)) { throw "Įdiegtoje vietoje nerastas $($Item.Executable)." }
        Set-Content -LiteralPath $versionMarker -Value $release.tag_name -Encoding ASCII

        $shortcutPath = Join-Path ([Environment]::GetFolderPath('Programs')) ($Item.Name + '.lnk')
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $installedExe
        $shortcut.WorkingDirectory = $installPath
        $shortcut.Save()
        Write-SetupLog ('Įdiegta {0} {1} į {2}; Start meniu nuoroda sukurta.' -f $Item.Name, $release.tag_name, $installPath) 'OK'

        $userScript = Get-OptionalProperty $Item 'UserScript'
        if ($userScript) {
            $userScriptUrl = 'https://raw.githubusercontent.com/{0}/{1}/{2}' -f $Item.Repository, $release.tag_name, $userScript
            # Single quotes on purpose: PowerShell treats the Lithuanian quotes „ “ as string delimiters inside double quotes.
            Write-SetupLog ('YouTube HDR aptikimui: kai Vivaldi bus įdiegtas Tampermonkey (su įjungtu „Allow User Scripts“), atverkite {0} ir patvirtinkite scenarijaus diegimą.' -f $userScriptUrl) 'WARN'
        }
    } finally {
        $ProgressPreference = $previousProgressPreference
        if (Test-Path -LiteralPath $workPath) { Remove-Item -LiteralPath $workPath -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Install-Programs {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Programos: niekas nepasirinkta.'; return }
    $winget = $null
    if (-not $script:Sync.DryRun -and @($Items | Where-Object { $_.InstallType -eq 'WinGet' }).Count -gt 0) { $winget = Get-WinGetPath }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Diegti: $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Start-Process -FilePath $item.Url
                Write-SetupLog "Atvertas oficialus puslapis: $($item.Url). Diegimą užbaikite rankiniu būdu." 'WARN'
                return
            }
            if ($item.InstallType -eq 'GitHubReleaseZip') {
                Install-GitHubReleaseZip -Item $item
                return
            }
            if (-not $winget) { throw 'WinGet nepasiekiamas. Įdiekite arba atnaujinkite Microsoft App Installer ir bandykite dar kartą.' }
            if (Test-WinGetPackageInstalled -WinGet $winget -Id $item.Id -Source $item.Source) {
                Write-SetupLog "Paketas $($item.Id) jau įdiegtas. Praleidžiama." 'OK'
                return
            }
            [void](Invoke-WinGet -WinGet $winget -Arguments @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity'))
            if (Test-WinGetPackageInstalled -WinGet $winget -Id $item.Id -Source $item.Source) {
                Write-SetupLog "Patikrintas įdiegtas paketas: $($item.Id)."
            } else {
                Write-SetupLog "WinGet patikra nerado $($item.Id). Paketas gali būti iš dalies įdiegtas." 'WARN'
            }
        }
    }
}

function Invoke-ReinstallPrograms {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Atkūrimas: niekas nepasirinkta.' 'WARN'; return }
    $winget = $null
    if (-not $script:Sync.DryRun -and @($Items | Where-Object { $_.InstallType -eq 'WinGet' }).Count -gt 0) { $winget = Get-WinGetPath }
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Įdiegti iš naujo: $($item.Name)" -Action {
            if ($item.InstallType -eq 'OfficialPage') {
                Start-Process -FilePath $item.Url
                Write-SetupLog "Atvertas oficialus puslapis rankiniam diegimui: $($item.Url)." 'WARN'
                return
            }
            if ($item.InstallType -eq 'GitHubReleaseZip') {
                $marker = Join-Path $env:LOCALAPPDATA ('Programs\{0}\.fresh-windows-setup-version' -f $item.InstallFolder)
                if (Test-Path -LiteralPath $marker) { Remove-Item -LiteralPath $marker -Force }
                Install-GitHubReleaseZip -Item $item
                return
            }
            if (-not $winget) { throw 'WinGet nepasiekiamas.' }
            [void](Invoke-WinGet -WinGet $winget -Arguments @('install', '--id', $item.Id, '--exact', '--source', $item.Source, '--force', '--silent', '--accept-package-agreements', '--accept-source-agreements', '--disable-interactivity'))
        }
    }
}

function Configure-VivaldiExtensions {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Vivaldi plėtiniai: niekas nepasirinkta.'; return }
    $policyPath = 'HKLM:\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist'
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Vivaldi plėtinys: $($item.Name)" -Action {
            if (-not (Test-Path -LiteralPath $policyPath)) { New-Item -Path $policyPath -Force | Out-Null }
            # Keep entries written by other tools; append at the first free index.
            $key = Get-Item -LiteralPath $policyPath
            $names = @($key.GetValueNames() | Where-Object { $_ })
            $existing = $names | Where-Object { ([string]$key.GetValue($_)).Split(';')[0] -eq $item.Id } | Select-Object -First 1
            if ($existing) {
                Write-SetupLog "Plėtinys jau yra Vivaldi politikoje (įrašas $existing)."
                return
            }
            $index = 1
            while ($names -contains [string]$index) { $index++ }
            Set-RegistryValue -Path $policyPath -Name ([string]$index) -Value ('{0};https://clients2.google.com/service/update2/crx' -f $item.Id) -Type String
            $note = Get-OptionalProperty $item 'PostInstallNote'
            if ($note) { Write-SetupLog $note 'WARN' }
        }
    }
    if (-not $script:Sync.DryRun) {
        Write-SetupLog 'Plėtiniai įdiegiami kitą kartą paleidus Vivaldi. Priverstinai įdiegtų plėtinių negalima pašalinti naršyklėje – tik ištrynus įrašą iš HKLM\SOFTWARE\Policies\Vivaldi\ExtensionInstallForcelist.' 'WARN'
    }
}

function Set-PrivacyOption {
    param([Parameter(Mandatory)][string]$Key)
    switch ($Key) {
        'DiagnosticData' {
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'AllowTelemetry' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDiagnosticLogCollection' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'LimitDumpCollection' 1
            Write-SetupLog 'Diagnostikos duomenys nustatyti į mažiausią įprastai palaikomą lygį; vis tiek galioja Windows leidimo apribojimai.' 'WARN'
        }
        'Advertising' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' 'Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo' 'DisabledByGroupPolicy' 1
        }
        'TailoredExperiences' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' 'TailoredExperiencesWithDiagnosticDataEnabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableTailoredExperiencesWithDiagnosticData' 1
        }
        'Suggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            foreach ($name in @('ContentDeliveryAllowed', 'FeatureManagementEnabled', 'OemPreInstalledAppsEnabled', 'PreInstalledAppsEnabled', 'PreInstalledAppsEverEnabled', 'SilentInstalledAppsEnabled', 'SubscribedContent-338388Enabled', 'SubscribedContent-338389Enabled', 'SubscribedContent-353694Enabled', 'SubscribedContent-353696Enabled', 'SystemPaneSuggestionsEnabled')) {
                Set-RegistryValue $contentPath $name 0
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent' 'DisableWindowsConsumerFeatures' 1
        }
        'Feedback' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Siuf\Rules' 'NumberOfSIUFInPeriod' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection' 'DoNotShowFeedbackNotifications' 1
        }
        'ActivityHistory' {
            $activityPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\System'
            Set-RegistryValue $activityPath 'EnableActivityFeed' 0
            Set-RegistryValue $activityPath 'PublishUserActivities' 0
            Set-RegistryValue $activityPath 'UploadUserActivities' 0
        }
        'InputPersonalization' {
            $inputPath = 'HKLM:\SOFTWARE\Policies\Microsoft\InputPersonalization'
            Set-RegistryValue $inputPath 'AllowInputPersonalization' 0
            Set-RegistryValue $inputPath 'RestrictImplicitInkCollection' 1
            Set-RegistryValue $inputPath 'RestrictImplicitTextCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitInkCollection' 1
            Set-RegistryValue 'HKCU:\Software\Microsoft\InputPersonalization' 'RestrictImplicitTextCollection' 1
        }
        'DisableOnlineSpeech' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy' 'HasAccepted' 0
        }
        'DisableCopilot' {
            Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot' 'TurnOffWindowsCopilot' 1
        }
        'DisableRecall' {
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'AllowRecallEnablement' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
            Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\WindowsAI' 'DisableAIDataAnalysis' 1
        }
        default { throw "Neatpažinta privatumo parinktis: $Key" }
    }
}

function Remove-OneDrive {
    Get-Process -Name 'OneDrive' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    $setup = @(
        (Join-Path $env:SystemRoot 'SysWOW64\OneDriveSetup.exe')
        (Join-Path $env:SystemRoot 'System32\OneDriveSetup.exe')
    ) | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
    if ($setup) {
        $process = Start-Process -FilePath $setup -ArgumentList @('/uninstall') -Wait -PassThru
        # Exit code 19: already uninstalled.
        if ($process.ExitCode -notin @(0, 19)) { throw "OneDrive šalinimo programa baigė darbą su kodu $($process.ExitCode)." }
    }
    $oneDriveExecutables = @(
        (Join-Path $env:LOCALAPPDATA 'Microsoft\OneDrive\OneDrive.exe')
        (Join-Path $env:ProgramFiles 'Microsoft OneDrive\OneDrive.exe')
    )
    if ($oneDriveExecutables | Where-Object { Test-Path -LiteralPath $_ }) {
        throw 'OneDrive patikra vis dar aptiko įdiegtą vykdomąjį failą.'
    }
    Write-SetupLog 'Patikrinta: OneDrive vykdomojo failo nėra.'
}

function Remove-MicrosoftEdge {
    $edgeGuid = '{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}'
    $webViewGuid = '{F3017226-FE2A-4295-8BDF-00C3A9A7E4C5}'
    $edgePolicy = 'HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate'
    Set-RegistryValue $edgePolicy ("Install$edgeGuid") 0
    Set-RegistryValue $edgePolicy ("Update$edgeGuid") 0
    Set-RegistryValue $edgePolicy ("Uninstall$($edgeGuid.ToLowerInvariant())") 1
    Set-RegistryValue $edgePolicy ("Install$webViewGuid") 1
    Set-RegistryValue $edgePolicy ("Update$webViewGuid") 1

    Get-Process -Name 'msedge' -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    $edgeRoot = Join-Path ${env:ProgramFiles(x86)} 'Microsoft\Edge\Application'
    $setup = Get-ChildItem -LiteralPath $edgeRoot -Filter 'setup.exe' -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -match '\\Installer\\setup\.exe$' } |
        Sort-Object FullName -Descending |
        Select-Object -First 1
    if ($setup) {
        $process = Start-Process -FilePath $setup.FullName -ArgumentList @('--uninstall', '--system-level', '--verbose-logging', '--force-uninstall') -Wait -PassThru
        if ($process.ExitCode -ne 0) { throw "Microsoft Edge šalinimo programa baigė darbą su kodu $($process.ExitCode). Kodas 93 dažniausiai reiškia, kad šiame regione Microsoft neleidžia pašalinti Edge." }
    }

    foreach ($runPath in @(
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'
    )) {
        Remove-RegistryValue $runPath 'MicrosoftEdgeAutoLaunch'
    }

    foreach ($shortcut in @(
        (Join-Path $env:PUBLIC 'Desktop\Microsoft Edge.lnk'),
        (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk'),
        (Join-Path $env:ProgramData 'Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk')
    )) {
        if (Test-Path -LiteralPath $shortcut) { Remove-Item -LiteralPath $shortcut -Force }
        if (Test-Path -LiteralPath $shortcut) { throw "Nepavyko pašalinti nuorodos: $shortcut" }
    }

    $edgeExecutable = Join-Path $edgeRoot 'msedge.exe'
    $versionedEdge = @(Get-ChildItem -LiteralPath $edgeRoot -Filter 'msedge.exe' -Recurse -ErrorAction SilentlyContinue)
    if ((Test-Path -LiteralPath $edgeExecutable) -or $versionedEdge.Count -gt 0) {
        throw 'Microsoft Edge pašalinimo patikra vis dar aptiko msedge.exe.'
    }
    Write-SetupLog 'Patikrinta: Edge naršyklė pašalinta, jos diegimas ir naujinimai užblokuoti; WebView2 ir jo naujinimai palikti.'
}

function Remove-AppxEverywhere {
    param([Parameter(Mandatory)][string]$Package, [Parameter(Mandatory)][hashtable]$Cache)
    foreach ($installed in @(Get-AppxPackage -AllUsers -Name $Package -ErrorAction SilentlyContinue)) {
        Remove-AppxPackage -Package $installed.PackageFullName -AllUsers -ErrorAction Stop
    }
    # Get-AppxProvisionedPackage is slow, so query it once per run and again only after a change.
    if (-not $Cache.ContainsKey('Provisioned')) { $Cache.Provisioned = @(Get-AppxProvisionedPackage -Online) }
    $provisioned = @($Cache.Provisioned | Where-Object { $_.DisplayName -eq $Package })
    foreach ($entry in $provisioned) {
        Remove-AppxProvisionedPackage -Online -PackageName $entry.PackageName -AllUsers -ErrorAction Stop | Out-Null
    }
    if ($provisioned.Count -gt 0) { $Cache.Provisioned = @(Get-AppxProvisionedPackage -Online) }

    $remainingInstalled = @(Get-AppxPackage -AllUsers -Name $Package -ErrorAction SilentlyContinue)
    $remainingProvisioned = @($Cache.Provisioned | Where-Object { $_.DisplayName -eq $Package })
    if ($remainingInstalled.Count -gt 0 -or $remainingProvisioned.Count -gt 0) {
        throw "Programėlės pašalinimo patikra vis dar aptiko $Package."
    }
    Write-SetupLog "Patikrinta, kad pašalinta arba nebuvo įdiegta: $Package."
}

function Remove-BundledApps {
    param([object[]]$Items)
    if ($Items.Count -eq 0) { Write-SetupLog 'Integruotos programėlės: niekas nepasirinkta.'; return }
    $cache = @{}
    foreach ($item in $Items) {
        Invoke-LoggedAction -Description "Pašalinti: $($item.Name)" -Action {
            switch (Get-OptionalProperty $item 'Kind') {
                'OneDrive' { Remove-OneDrive; return }
                'Edge' { Remove-MicrosoftEdge; return }
                'WindowsBackup' {
                    Set-WindowsOption -Key 'DisableWindowsBackup'
                    Write-SetupLog 'Windows atsarginio kopijavimo programa yra bendro Windows apvalkalo paketo dalis, todėl pats paketas paliktas.' 'WARN'
                    return
                }
            }
            Remove-AppxEverywhere -Package $item.Package -Cache $cache
        }
    }
}

function Set-TaskbarAutoHide {
    $path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3'
    $settings = [byte[]](Get-ItemPropertyValue -LiteralPath $path -Name 'Settings' -ErrorAction Stop)
    if ($settings.Length -lt 9) { throw 'Užduočių juostos nustatymo reikšmės formatas neatpažintas.' }
    $settings[8] = 3
    Set-RegistryValue $path 'Settings' $settings 'Binary'
    Write-SetupLog 'Automatinis užduočių juostos slėpimas visiškai įsigalios perkrovus Explorer arba kitą kartą prisijungus.' 'WARN'
}

function Set-LithuaniaRegion {
    Set-Culture -CultureInfo 'lt-LT'
    Set-WinHomeLocation -GeoId 140
    Set-WinSystemLocale -SystemLocale 'lt-LT'
    Set-TimeZone -Id 'FLE Standard Time'
    if ((Get-TimeZone).Id -ne 'FLE Standard Time') { throw 'Nepavyko patikrinti laiko juostos.' }
    if ((Get-WinSystemLocale).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti sistemos lokalės.' }
    if ((Get-WinHomeLocation).GeoId -ne 140) { throw 'Nepavyko patikrinti namų regiono.' }
    if ((Get-Culture).Name -ne 'lt-LT') { throw 'Nepavyko patikrinti regioninio formato.' }
    Write-SetupLog 'Patikrintas Lietuvos regionas, lietuviška sistemos lokalė ir Vilniaus laiko juosta.'
    Write-SetupLog 'Kai kuriems lietuviškos lokalės pakeitimams gali reikėti atsijungti arba paleisti Windows iš naujo.' 'WARN'
}

function Set-ConnectedNetworksPrivate {
    $profiles = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { $_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected' })
    if ($profiles.Count -eq 0) { throw 'Nerastas nė vienas prijungtas tinklo profilis.' }
    foreach ($profile in $profiles) {
        Set-NetConnectionProfile -InterfaceIndex $profile.InterfaceIndex -NetworkCategory Private -ErrorAction Stop
    }
    $remaining = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object { ($_.IPv4Connectivity -ne 'Disconnected' -or $_.IPv6Connectivity -ne 'Disconnected') -and $_.NetworkCategory -ne 'Private' })
    if ($remaining.Count -gt 0) { throw 'Tinklo kategorijos patikra aptiko prijungtą profilį, kuris nėra privatus.' }
    Write-SetupLog 'Patikrinta: visi prijungti tinklo profiliai yra privatūs.'
}

function Set-WindowsOption {
    param([Parameter(Mandatory)][string]$Key)
    if ($Key -in @($PrivacyCatalog.Key)) {
        Set-PrivacyOption -Key $Key
        return
    }
    $advanced = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
    switch ($Key) {
        'TaskbarLeft' { Set-RegistryValue $advanced 'TaskbarAl' 0 }
        'HideSearch' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'SearchboxTaskbarMode' 0 }
        'HideTaskView' { Set-RegistryValue $advanced 'ShowTaskViewButton' 0 }
        'HideWidgets' {
            # The policy is the reliable switch: on 24H2+ the UCPD driver blocks scripted writes to TaskbarDa.
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Dsh' 'AllowNewsAndInterests' 0
            try { Set-RegistryValue $advanced 'TaskbarDa' 0 }
            catch { Write-SetupLog 'TaskbarDa reikšmės Windows neleidžia keisti; valdiklius išjungia politika.' 'WARN' }
        }
        'DisableStartRecommendations' {
            Set-RegistryValue $advanced 'Start_IrisRecommendations' 0
            Set-RegistryValue $advanced 'Start_AccountNotifications' 0
        }
        'DisableRecentItems' {
            Set-RegistryValue $advanced 'Start_TrackDocs' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' 'NoRecentDocsHistory' 1
        }
        'StartMorePins' { Set-RegistryValue $advanced 'Start_Layout' 1 }
        'TaskbarEndTask' { Set-RegistryValue "$advanced\TaskbarDeveloperSettings" 'TaskbarEndTask' 1 }
        'ShowSecondsInClock' { Set-RegistryValue $advanced 'ShowSecondsInSystemClock' 1 }
        'TaskbarAutoHide' { Set-TaskbarAutoHide }
        'ShowFileExtensions' { Set-RegistryValue $advanced 'HideFileExt' 0 }
        'ShowHiddenFiles' { Set-RegistryValue $advanced 'Hidden' 1 }
        'ExplorerThisPC' { Set-RegistryValue $advanced 'LaunchTo' 1 }
        'CompactView' { Set-RegistryValue $advanced 'UseCompactMode' 1 }
        'ClassicContextMenu' {
            Set-RegistryDefaultValue 'HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32' ''
        }
        'RemoveGallery' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'RemoveHome' {
            Set-RegistryValue 'HKCU:\Software\Classes\CLSID\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}' 'System.IsPinnedToNameSpaceTree' 0
        }
        'DisableQuickAccessRecent' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowRecent' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer' 'ShowFrequent' 0
        }
        'DisableSyncProviderAds' { Set-RegistryValue $advanced 'ShowSyncProviderNotifications' 0 }
        'ThisPCOnDesktop' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel' '{20D04FE0-3AEA-1069-A2D8-08002B30309D}' 0
        }
        'DarkMode' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'AppsUseLightTheme' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'SystemUsesLightTheme' 0
        }
        'DisableTransparency' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize' 'EnableTransparency' 0 }
        'DisableWebSearch' {
            Set-RegistryValue 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' 'DisableSearchBoxSuggestions' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search' 'DisableWebSearch' 1
        }
        'DisableTips' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SoftLandingEnabled' 0
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
        }
        'DisableLockScreenSuggestions' {
            $contentPath = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager'
            Set-RegistryValue $contentPath 'RotatingLockScreenEnabled' 0
            Set-RegistryValue $contentPath 'RotatingLockScreenOverlayEnabled' 0
            Set-RegistryValue $contentPath 'SubscribedContent-338387Enabled' 0
        }
        'DisableStartupDelay' { Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize' 'StartupDelayInMSec' 0 }
        'DisableMouseAcceleration' {
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseSpeed' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold1' '0' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Mouse' 'MouseThreshold2' '0' 'String'
        }
        'DisableStickyKeys' {
            Set-RegistryValue 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' '506' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Accessibility\ToggleKeys' 'Flags' '58' 'String'
            Set-RegistryValue 'HKCU:\Control Panel\Accessibility\Keyboard Response' 'Flags' '122' 'String'
        }
        'DisableFastStartup' {
            Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power' 'HiberbootEnabled' 0
        }
        'DisableHibernation' {
            Invoke-NativeCommand -FilePath 'powercfg.exe' -Arguments @('/hibernate', 'off')
            if ((Get-ItemPropertyValue -LiteralPath 'HKLM:\SYSTEM\CurrentControlSet\Control\Power' -Name 'HibernateEnabled') -ne 0) { throw 'Nepavyko patikrinti, kad užmigdymas išjungtas.' }
            Write-SetupLog 'Patikrinta: užmigdymas išjungtas.'
        }
        'HighPerformancePlan' {
            $highPerformance = '8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c'
            Invoke-NativeCommand -FilePath 'powercfg.exe' -Arguments @('/setactive', $highPerformance)
            if ((powercfg.exe /getactivescheme | Out-String) -notmatch $highPerformance) { throw 'Didelio našumo schema neaktyvi.' }
            Write-SetupLog 'Patikrinta: aktyvi didelio našumo maitinimo schema.'
        }
        'EnableLongPaths' { Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' 'LongPathsEnabled' 1 }
        'ExcludeDriversFromWU' { Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate' 'ExcludeWUDriversInQualityUpdate' 1 }
        'NoAutoRebootWhileSignedIn' { Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU' 'NoAutoRebootWithLoggedOnUsers' 1 }
        'DisableDeliveryOptimizationP2P' { Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization' 'DODownloadMode' 0 }
        'DisableSystemRestore' {
            $systemDrive = [Environment]::GetEnvironmentVariable('SystemDrive') + '\'
            Disable-ComputerRestore -Drive $systemDrive -ErrorAction SilentlyContinue
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableSR' 1
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\SystemRestore' 'DisableConfig' 1
        }
        'DisableWindowsBackup' {
            $syncPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\SettingSync'
            Set-RegistryValue $syncPath 'EnableWindowsBackup' 0
            foreach ($name in @('DisableSettingSync', 'DisableApplicationSettingSync', 'DisableCredentialsSettingSync', 'DisablePersonalizationSettingSync', 'DisableWindowsSettingSync')) {
                Set-RegistryValue $syncPath $name 2
                Set-RegistryValue $syncPath ($name + 'UserOverride') 1
            }
            Set-RegistryValue 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsBackup' 'DisableMonitoring' 1
        }
        'DisableGameBarRecording' {
            Set-RegistryValue 'HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR' 'AppCaptureEnabled' 0
            Set-RegistryValue 'HKCU:\System\GameConfigStore' 'GameDVR_Enabled' 0
            Set-RegistryValue 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR' 'AllowGameDVR' 0
        }
        'HardwareGpuScheduling' { Set-RegistryValue 'HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers' 'HwSchMode' 2 }
        'PrivateNetwork' { Set-ConnectedNetworksPrivate }
        'LithuaniaRegion' { Set-LithuaniaRegion }
        default { throw "Neatpažintas Windows nustatymas: $Key" }
    }
}

function Get-StartupEntries {
    foreach ($hive in @([Microsoft.Win32.RegistryHive]::CurrentUser, [Microsoft.Win32.RegistryHive]::LocalMachine)) {
        foreach ($view in @([Microsoft.Win32.RegistryView]::Registry64, [Microsoft.Win32.RegistryView]::Registry32)) {
            if (-not [Environment]::Is64BitOperatingSystem -and $view -eq [Microsoft.Win32.RegistryView]::Registry64) { continue }
            $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($hive, $view)
            try {
                foreach ($suffix in @('Run', 'RunOnce')) {
                    $path = 'Software\Microsoft\Windows\CurrentVersion\' + $suffix
                    $key = $base.OpenSubKey($path)
                    if ($null -eq $key) { continue }
                    try {
                        foreach ($valueName in $key.GetValueNames()) {
                            $value = $key.GetValue($valueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                            [pscustomobject]@{
                                Name = "$valueName [$hive / $view / $suffix] — $value"
                                Title = $valueName; Detail = [string]$value
                                Scope = $(if ($hive -eq [Microsoft.Win32.RegistryHive]::CurrentUser) { 'HKCU' } else { 'HKLM' })
                                Bitness = $(if ($view -eq [Microsoft.Win32.RegistryView]::Registry64) { '64 bit' } else { '32 bit' })
                                Kind = 'Registry'; Hive = $hive; View = $view; Path = $path; Suffix = $suffix
                                ValueName = $valueName; Value = $value; ValueKind = $key.GetValueKind($valueName)
                                Default = $false
                            }
                        }
                    } finally { $key.Dispose() }
                }
            } finally { $base.Dispose() }
        }
    }
    foreach ($folder in @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))) {
        if (-not $folder -or -not (Test-Path -LiteralPath $folder)) { continue }
        foreach ($file in @(Get-ChildItem -LiteralPath $folder -File -Force -ErrorAction Stop)) {
            if ($file.Name -eq 'desktop.ini') { continue }
            [pscustomobject]@{
                Name = "$($file.Name) [$folder]"; Title = $file.Name; Detail = $file.FullName
                Scope = $(if ($folder -eq [Environment]::GetFolderPath('Startup')) { 'Naudotojo aplankas' } else { 'Visų naudotojų aplankas' })
                Kind = 'File'; Path = $file.FullName
                Hash = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash; Default = $false
            }
        }
    }
}

function Get-TaskEntries {
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    foreach ($task in @(Get-ScheduledTask -ErrorAction Stop | Sort-Object TaskPath, TaskName)) {
        try {
            # Schedule.Service rejects a trailing backslash on every folder except the root.
            $folderPath = if ($task.TaskPath -eq '\') { '\' } else { $task.TaskPath.TrimEnd('\') }
            $registered = $service.GetFolder($folderPath).GetTask($task.TaskName)
            $actions = @($task.Actions | ForEach-Object {
                if ($_.PSObject.Properties['Execute']) { "$($_.Execute) $($_.Arguments)" } else { $_.CimClass.CimClassName }
            }) -join '; '
            [pscustomobject]@{
                Name = "$($task.TaskPath)$($task.TaskName) [$($task.State)] — $actions"
                Title = $task.TaskName; Detail = $(if ($task.TaskPath -eq '\') { $actions } else { "$($task.TaskPath) — $actions" }); State = [string]$task.State
                IsSystem = $task.TaskPath -like '\Microsoft\*'
                Kind = 'Task'; TaskPath = $task.TaskPath; TaskName = $task.TaskName
                Xml = [string]$registered.Xml; Default = $false
            }
        } catch { Write-SetupLog "Užduoties nuskaitymo klaida: $($task.TaskPath)$($task.TaskName): $($_.Exception.Message)" 'WARN' }
    }
}

function New-RemovalBackupDirectory {
    $path = Join-Path ([Environment]::GetFolderPath('LocalApplicationData')) ('FreshWindowsSetup\RemovalBackups\' + [guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($path)
    return $path
}

function Remove-StartupEntry {
    param([Parameter(Mandatory)]$Item)
    if ($Item.Kind -eq 'Registry') {
        $base = [Microsoft.Win32.RegistryKey]::OpenBaseKey($Item.Hive, $Item.View)
        try {
            $key = $base.OpenSubKey($Item.Path, $true)
            if ($null -eq $key) { throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.' }
            try {
                $value = $key.GetValue($Item.ValueName, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                if ($key.GetValueNames() -cnotcontains $Item.ValueName -or $key.GetValueKind($Item.ValueName) -ne $Item.ValueKind -or (ConvertTo-Json -InputObject $value -Compress) -cne (ConvertTo-Json -InputObject $Item.Value -Compress)) {
                    throw 'Įrašas pasikeitė. Atnaujinkite sąrašą.'
                }
                $backup = New-RemovalBackupDirectory
                $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
                Write-SetupLog "Atsarginė kopija: $backup"
                $key.DeleteValue($Item.ValueName, $true)
                if ($key.GetValueNames() -ccontains $Item.ValueName) { throw 'Registro įrašas nepašalintas.' }
            } finally { $key.Dispose() }
        } finally { $base.Dispose() }
    } elseif ($Item.Kind -eq 'File') {
        $allowed = @([Environment]::GetFolderPath('Startup'), [Environment]::GetFolderPath('CommonStartup'))
        $parent = [IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($Item.Path))
        if ($allowed -notcontains $parent) { throw 'Failas nėra paleisties aplanke.' }
        if ((Get-FileHash -LiteralPath $Item.Path -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Failas pasikeitė. Atnaujinkite sąrašą.' }
        $backup = New-RemovalBackupDirectory
        Copy-Item -LiteralPath $Item.Path -Destination (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -ErrorAction Stop
        $Item | Export-Clixml -LiteralPath (Join-Path $backup 'startup.xml') -Depth 5
        if ((Get-FileHash -LiteralPath (Join-Path $backup ([IO.Path]::GetFileName($Item.Path))) -Algorithm SHA256).Hash -cne $Item.Hash) { throw 'Atsarginės kopijos patikra nepavyko.' }
        Write-SetupLog "Atsarginė kopija: $backup"
        Remove-Item -LiteralPath $Item.Path -Force -ErrorAction Stop
        if (Test-Path -LiteralPath $Item.Path) { throw 'Paleisties failas nepašalintas.' }
    } else { throw 'Neatpažintas paleisties įrašo tipas.' }
}

function Remove-TaskEntry {
    param([Parameter(Mandatory)]$Item)
    $service = New-Object -ComObject 'Schedule.Service'
    $service.Connect()
    $folder = $service.GetFolder($(if ($Item.TaskPath -eq '\') { '\' } else { $Item.TaskPath.TrimEnd('\') }))
    $task = $folder.GetTask($Item.TaskName)
    if ([string]$task.Xml -cne $Item.Xml) { throw 'Užduotis pasikeitė. Atnaujinkite sąrašą.' }
    if ([int]$task.State -eq 4) { throw 'Užduotis vykdoma. Sustabdykite ją užduočių planuoklyje ir bandykite dar kartą.' }
    $backup = New-RemovalBackupDirectory
    [IO.File]::WriteAllText((Join-Path $backup 'task.xml'), $Item.Xml, [Text.Encoding]::Unicode)
    $Item | Select-Object TaskPath, TaskName | Export-Clixml -LiteralPath (Join-Path $backup 'task-location.xml')
    Write-SetupLog "Atsarginė kopija: $backup"
    $folder.DeleteTask($Item.TaskName, 0)
    $remaining = @($folder.GetTasks(1) | Where-Object { $_.Name -ceq $Item.TaskName })
    if ($remaining.Count -gt 0) { throw 'Užduotis nepašalinta.' }
}

function Invoke-EntryRemoval {
    param([Parameter(Mandatory)][ValidateSet('Startup', 'Task')][string]$Kind, [Parameter(Mandatory)][object[]]$Entries)
    foreach ($entry in $Entries) {
        Invoke-LoggedAction -Description "Pašalinti: $($entry.Name)" -Action {
            if ($Kind -eq 'Startup') { Remove-StartupEntry $entry } else { Remove-TaskEntry $entry }
        }
    }
}

function Invoke-SetupPlan {
    param([Parameter(Mandatory)]$Plan)
    $script:Sync.Total = @($Plan.Programs).Count + @($Plan.Extensions).Count + @($Plan.Apps).Count + @($Plan.Settings).Count
    $script:Sync.Done = 0
    $suffix = if ($script:Sync.DryRun) { ' Bandomasis režimas: sistema nebus keičiama.' } else { '' }
    Write-SetupLog "$AppName v$AppVersion pradėta. Žurnalo failas: $script:LogPath.$suffix" 'OK'
    if ($Plan.Mode -eq 'Reinstall') {
        try { Invoke-ReinstallPrograms -Items @($Plan.Programs) }
        catch { Write-SetupLog "Atkūrimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
    } else {
        try { Install-Programs -Items @($Plan.Programs) }
        catch { Write-SetupLog "Programų diegimo dalies klaida: $($_.Exception.Message)" 'ERROR' }
        try { Configure-VivaldiExtensions -Items @($Plan.Extensions) }
        catch { Write-SetupLog "Vivaldi plėtinių dalies klaida: $($_.Exception.Message)" 'ERROR' }
        try { Remove-BundledApps -Items @($Plan.Apps) }
        catch { Write-SetupLog "Integruotų programėlių dalies klaida: $($_.Exception.Message)" 'ERROR' }
        foreach ($item in @($Plan.Settings)) {
            Invoke-LoggedAction -Description $item.Name -Action { Set-WindowsOption -Key $item.Key }
        }
    }
    if ($script:Sync.Cancel) {
        Write-SetupLog 'Vykdymas sustabdytas. Likę veiksmai praleisti.' 'WARN'
    } elseif ($script:Sync.DryRun) {
        Write-SetupLog 'Bandomasis vykdymas baigtas. Jokių pakeitimų neatlikta.' 'OK'
    } else {
        Write-SetupLog 'Vykdymas baigtas. Peržiūrėkite įspėjimus bei klaidas ir paleiskite Windows iš naujo.' 'OK'
    }
}

function Restart-Explorer {
    $session = (Get-Process -Id $PID).SessionId
    Write-SetupLog 'Perkraunamas Explorer...'
    Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $session } | Stop-Process -Force
    # Windows restarts the shell by itself; starting it from this elevated process would run it elevated.
    $deadline = (Get-Date).AddSeconds(8)
    while ((Get-Date) -lt $deadline -and -not (Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $session })) {
        Start-Sleep -Milliseconds 300
    }
    if (Get-Process -Name 'explorer' -ErrorAction SilentlyContinue | Where-Object { $_.SessionId -eq $session }) {
        Write-SetupLog 'Explorer perkrautas.' 'OK'
    } else {
        Write-SetupLog 'Explorer automatiškai nepasileido. Paspauskite Ctrl+Shift+Esc → „Vykdyti naują užduotį“ → explorer.exe.' 'WARN'
    }
}

$script:BackendFunctionNames = @(Get-ChildItem -Path function: | ForEach-Object Name | Where-Object { $functionsBeforeBackend -notcontains $_ })

# ---------------------------------------------------------------------------------------------
# User interface
# ---------------------------------------------------------------------------------------------

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Fresh Windows Setup" Width="1220" Height="820" MinWidth="980" MinHeight="640"
        WindowStartupLocation="CenterScreen" Background="#17171A" Foreground="#EDEDF0"
        FontFamily="Segoe UI" FontSize="13.5" UseLayoutRounding="True" SnapsToDevicePixels="True">
  <Window.Resources>
    <FontFamily x:Key="IconFont">Segoe Fluent Icons, Segoe MDL2 Assets</FontFamily>
    <SolidColorBrush x:Key="MutedBrush" Color="#A3A3AD"/>
    <SolidColorBrush x:Key="SubtleBrush" Color="#7A7A85"/>

    <Style x:Key="ScrollThumb" TargetType="Thumb">
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Thumb">
            <Border CornerRadius="4" Background="#45454E" Margin="2"/>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="ScrollBar">
      <Setter Property="Width" Value="10"/>
      <Setter Property="MinWidth" Value="10"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ScrollBar">
            <Track x:Name="PART_Track" Orientation="{TemplateBinding Orientation}" IsDirectionReversed="True">
              <Track.Thumb><Thumb Style="{StaticResource ScrollThumb}"/></Track.Thumb>
            </Track>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
      <Style.Triggers>
        <Trigger Property="Orientation" Value="Horizontal">
          <Setter Property="Width" Value="Auto"/>
          <Setter Property="MinWidth" Value="0"/>
          <Setter Property="Height" Value="10"/>
          <Setter Property="MinHeight" Value="10"/>
          <Setter Property="Template">
            <Setter.Value>
              <ControlTemplate TargetType="ScrollBar">
                <Track x:Name="PART_Track" Orientation="{TemplateBinding Orientation}">
                  <Track.Thumb><Thumb Style="{StaticResource ScrollThumb}"/></Track.Thumb>
                </Track>
              </ControlTemplate>
            </Setter.Value>
          </Setter>
        </Trigger>
      </Style.Triggers>
    </Style>

    <Style TargetType="ToolTip">
      <Setter Property="Background" Value="#2B2B32"/>
      <Setter Property="Foreground" Value="#EDEDF0"/>
      <Setter Property="BorderBrush" Value="#3A3A42"/>
      <Setter Property="Padding" Value="10,6"/>
      <Setter Property="MaxWidth" Value="420"/>
    </Style>

    <Style x:Key="BaseButton" TargetType="Button">
      <Setter Property="Foreground" Value="#EDEDF0"/>
      <Setter Property="Background" Value="#28282E"/>
      <Setter Property="BorderBrush" Value="#38383F"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="14,7"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="Button">
            <Grid>
              <Border Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6"/>
              <Border x:Name="Overlay" CornerRadius="6" Background="#FFFFFF" Opacity="0"/>
              <ContentPresenter Margin="{TemplateBinding Padding}" HorizontalAlignment="Center" VerticalAlignment="Center" RecognizesAccessKey="True"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Overlay" Property="Opacity" Value="0.07"/></Trigger>
              <Trigger Property="IsKeyboardFocused" Value="True"><Setter TargetName="Overlay" Property="Opacity" Value="0.07"/></Trigger>
              <Trigger Property="IsPressed" Value="True"><Setter TargetName="Overlay" Property="Opacity" Value="0.02"/></Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.4"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="Button" BasedOn="{StaticResource BaseButton}"/>
    <Style x:Key="SmallButton" TargetType="Button" BasedOn="{StaticResource BaseButton}">
      <Setter Property="Padding" Value="12,5"/>
      <Setter Property="FontSize" Value="12.5"/>
      <Setter Property="Margin" Value="0,0,8,0"/>
    </Style>
    <Style x:Key="DangerButton" TargetType="Button" BasedOn="{StaticResource SmallButton}">
      <Setter Property="Background" Value="#3A2226"/>
      <Setter Property="BorderBrush" Value="#6A2C34"/>
      <Setter Property="Foreground" Value="#FFB4B4"/>
    </Style>
    <Style x:Key="PrimaryButton" TargetType="Button" BasedOn="{StaticResource BaseButton}">
      <Setter Property="Background" Value="#4CC2FF"/>
      <Setter Property="BorderBrush" Value="#4CC2FF"/>
      <Setter Property="Foreground" Value="#06131B"/>
      <Setter Property="FontWeight" Value="SemiBold"/>
      <Setter Property="Padding" Value="20,8"/>
    </Style>

    <Style x:Key="NavItem" TargetType="RadioButton">
      <Setter Property="Foreground" Value="#C4C4CC"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="GroupName" Value="Navigation"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="RadioButton">
            <Grid Margin="0,1">
              <Border x:Name="Bd" CornerRadius="6" Background="Transparent" Padding="12,6,10,6">
                <ContentPresenter/>
              </Border>
              <Border x:Name="Pill" Width="3" Height="16" CornerRadius="2" Background="#4CC2FF" HorizontalAlignment="Left" Visibility="Collapsed"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Bd" Property="Background" Value="#25252B"/></Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Bd" Property="Background" Value="#2B2B33"/>
                <Setter TargetName="Pill" Property="Visibility" Value="Visible"/>
                <Setter Property="Foreground" Value="#FFFFFF"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="OptionCard" TargetType="Border">
      <Setter Property="Background" Value="#212126"/>
      <Setter Property="BorderBrush" Value="#2B2B32"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="CornerRadius" Value="8"/>
      <Setter Property="Padding" Value="16,13,16,13"/>
      <Setter Property="Margin" Value="0,0,0,8"/>
      <Style.Triggers>
        <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#27272D"/></Trigger>
      </Style.Triggers>
    </Style>

    <Style x:Key="OptionCheck" TargetType="CheckBox">
      <Setter Property="Foreground" Value="#EDEDF0"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <Grid Background="Transparent">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
              </Grid.ColumnDefinitions>
              <Border x:Name="Box" Width="20" Height="20" CornerRadius="5" BorderThickness="1.5" BorderBrush="#6E6E78" Background="#1B1B1F" VerticalAlignment="Top" Margin="0,1,14,0">
                <TextBlock x:Name="Mark" Text="&#xE73E;" FontFamily="{StaticResource IconFont}" FontSize="12" Foreground="#06131B" HorizontalAlignment="Center" VerticalAlignment="Center" Visibility="Collapsed"/>
              </Border>
              <ContentPresenter Grid.Column="1" VerticalAlignment="Top"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="Box" Property="BorderBrush" Value="#A0A0AA"/></Trigger>
              <Trigger Property="IsKeyboardFocused" Value="True"><Setter TargetName="Box" Property="BorderBrush" Value="#4CC2FF"/></Trigger>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Box" Property="Background" Value="#4CC2FF"/>
                <Setter TargetName="Box" Property="BorderBrush" Value="#4CC2FF"/>
                <Setter TargetName="Mark" Property="Visibility" Value="Visible"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.55"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="Switch" TargetType="CheckBox">
      <Setter Property="Foreground" Value="#D6D6DD"/>
      <Setter Property="Cursor" Value="Hand"/>
      <Setter Property="FocusVisualStyle" Value="{x:Null}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="CheckBox">
            <Grid Background="Transparent">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="*"/>
              </Grid.ColumnDefinitions>
              <Border x:Name="Track" Width="38" Height="20" CornerRadius="10" BorderThickness="1.5" BorderBrush="#8A8A94" Background="Transparent" VerticalAlignment="Center" Margin="0,0,10,0">
                <Ellipse x:Name="Knob" Width="12" Height="12" Fill="#C8C8D0" HorizontalAlignment="Left" Margin="3,0,0,0"/>
              </Border>
              <ContentPresenter Grid.Column="1" VerticalAlignment="Center"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsChecked" Value="True">
                <Setter TargetName="Track" Property="Background" Value="#4CC2FF"/>
                <Setter TargetName="Track" Property="BorderBrush" Value="#4CC2FF"/>
                <Setter TargetName="Knob" Property="Fill" Value="#06131B"/>
                <Setter TargetName="Knob" Property="HorizontalAlignment" Value="Right"/>
                <Setter TargetName="Knob" Property="Margin" Value="0,0,3,0"/>
              </Trigger>
              <Trigger Property="IsEnabled" Value="False"><Setter Property="Opacity" Value="0.45"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style x:Key="SearchBox" TargetType="TextBox">
      <Setter Property="Foreground" Value="#EDEDF0"/>
      <Setter Property="Background" Value="#202025"/>
      <Setter Property="BorderBrush" Value="#34343B"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="CaretBrush" Value="#EDEDF0"/>
      <Setter Property="SelectionBrush" Value="#4CC2FF"/>
      <Setter Property="Padding" Value="32,7,10,7"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TextBox">
            <Border x:Name="Bd" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="6">
              <ScrollViewer x:Name="PART_ContentHost" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsKeyboardFocused" Value="True"><Setter TargetName="Bd" Property="BorderBrush" Value="#4CC2FF"/></Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <Style TargetType="ProgressBar">
      <Setter Property="Foreground" Value="#4CC2FF"/>
      <Setter Property="Background" Value="#2C2C33"/>
      <Setter Property="Height" Value="4"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ProgressBar">
            <Grid>
              <Border x:Name="PART_Track" CornerRadius="2" Background="{TemplateBinding Background}"/>
              <Border x:Name="PART_Indicator" CornerRadius="2" Background="{TemplateBinding Foreground}" HorizontalAlignment="Left"/>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
  </Window.Resources>

  <Grid>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="276"/>
      <ColumnDefinition Width="*"/>
    </Grid.ColumnDefinitions>

    <Border Background="#1D1D21" BorderBrush="#29292F" BorderThickness="0,0,1,0">
      <DockPanel Margin="12,18,12,14">
        <StackPanel DockPanel.Dock="Top" Orientation="Horizontal" Margin="8,0,0,4">
          <Border Width="34" Height="34" CornerRadius="8" Background="#4CC2FF" Margin="0,0,12,0">
            <TextBlock Text="&#xE770;" FontFamily="{StaticResource IconFont}" FontSize="17" Foreground="#06131B" HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <StackPanel VerticalAlignment="Center">
            <TextBlock Text="Fresh Windows Setup" FontSize="15" FontWeight="SemiBold"/>
            <TextBlock x:Name="VersionText" FontSize="11.5" Foreground="{StaticResource SubtleBrush}" Margin="0,1,0,0"/>
          </StackPanel>
        </StackPanel>
        <StackPanel DockPanel.Dock="Bottom" Margin="8,10,4,0">
          <Border Height="1" Background="#2A2A30" Margin="-8,0,-4,12"/>
          <CheckBox x:Name="DryRunToggle" Style="{StaticResource Switch}" Content="Bandomasis režimas"/>
          <TextBlock Text="Nieko nekeičia – žurnale tik parodo, kas būtų padaryta." FontSize="11.5" Foreground="{StaticResource SubtleBrush}" TextWrapping="Wrap" Margin="48,3,0,0"/>
        </StackPanel>
        <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Focusable="False">
          <StackPanel x:Name="NavPanel"/>
        </ScrollViewer>
      </DockPanel>
    </Border>

    <Grid Grid.Column="1">
      <Grid.RowDefinitions>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <Border x:Name="ModeBanner" Visibility="Collapsed" Background="#33290F" BorderBrush="#5E4A17" BorderThickness="0,0,0,1" Padding="36,9">
        <DockPanel>
          <TextBlock Text="&#xE7BA;" FontFamily="{StaticResource IconFont}" Foreground="#F5B544" VerticalAlignment="Top" Margin="0,2,10,0"/>
          <TextBlock x:Name="ModeBannerText" Foreground="#F5C766" TextWrapping="Wrap"/>
        </DockPanel>
      </Border>

      <Grid Grid.Row="1" Margin="36,24,36,14">
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
          <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <StackPanel Orientation="Horizontal">
          <TextBlock x:Name="SectionGlyph" FontFamily="{StaticResource IconFont}" FontSize="22" Foreground="#4CC2FF" VerticalAlignment="Center" Margin="0,3,12,0"/>
          <TextBlock x:Name="SectionTitle" FontSize="26" FontWeight="SemiBold" VerticalAlignment="Center"/>
        </StackPanel>
        <Grid x:Name="SearchHost" Grid.Column="1" Width="270" VerticalAlignment="Center">
          <TextBox x:Name="SearchBox" Style="{StaticResource SearchBox}"/>
          <TextBlock Text="&#xE721;" FontFamily="{StaticResource IconFont}" FontSize="13" Foreground="{StaticResource SubtleBrush}" Margin="12,0,0,0" VerticalAlignment="Center" IsHitTestVisible="False"/>
          <TextBlock x:Name="SearchPlaceholder" Text="Ieškoti (Ctrl+F)" Foreground="{StaticResource SubtleBrush}" Margin="33,0,0,0" VerticalAlignment="Center" IsHitTestVisible="False"/>
        </Grid>
        <TextBlock x:Name="SectionDescription" Grid.Row="1" Grid.ColumnSpan="2" Foreground="{StaticResource MutedBrush}" TextWrapping="Wrap" MaxWidth="860" HorizontalAlignment="Left" Margin="0,8,0,0" LineHeight="20"/>
        <DockPanel Grid.Row="2" Grid.ColumnSpan="2" Margin="0,16,0,0" LastChildFill="False">
          <StackPanel x:Name="ActionButtons" Orientation="Horizontal" DockPanel.Dock="Left">
            <Button x:Name="SelectAllButton" Style="{StaticResource SmallButton}" Content="Pažymėti visus"/>
            <Button x:Name="SelectNoneButton" Style="{StaticResource SmallButton}" Content="Nuimti visus"/>
            <Button x:Name="SelectDefaultsButton" Style="{StaticResource SmallButton}" Content="Numatytieji"/>
            <Button x:Name="RefreshButton" Style="{StaticResource SmallButton}" Content="Atnaujinti sąrašą"/>
            <Button x:Name="RemoveSelectedButton" Style="{StaticResource DangerButton}" Content="Pašalinti pažymėtus"/>
            <CheckBox x:Name="ShowSystemTasksToggle" Style="{StaticResource Switch}" Content="Rodyti Windows sistemines užduotis" VerticalAlignment="Center" Margin="8,0,0,0"/>
            <Button x:Name="RestartExplorerButton" Style="{StaticResource SmallButton}" Content="Perkrauti Explorer" ToolTip="Pritaiko užduočių juostos ir failų naršyklės pakeitimus be atsijungimo"/>
            <Button x:Name="OpenLogFileButton" Style="{StaticResource SmallButton}" Content="Atverti žurnalo failą"/>
            <Button x:Name="BackButton" Style="{StaticResource SmallButton}" Content="← Grįžti"/>
          </StackPanel>
          <TextBlock x:Name="ActionInfo" DockPanel.Dock="Right" Foreground="{StaticResource MutedBrush}" VerticalAlignment="Center" FontSize="12.5"/>
        </DockPanel>
      </Grid>

      <ScrollViewer x:Name="ContentScroll" Grid.Row="2" Padding="36,0,26,24" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Focusable="False"/>

      <Border Grid.Row="3" Background="#1B1B1F" BorderBrush="#29292F" BorderThickness="0,1,0,0" Padding="36,14">
        <Grid>
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <StackPanel VerticalAlignment="Center" Margin="0,0,24,0">
            <TextBlock x:Name="SummaryText" Foreground="#C9C9D1" TextTrimming="CharacterEllipsis"/>
            <TextBlock x:Name="SummaryRisk" Foreground="#F5B544" FontSize="12" Margin="0,3,0,0" Visibility="Collapsed" TextTrimming="CharacterEllipsis"/>
            <ProgressBar x:Name="RunProgress" Maximum="1" Margin="0,9,0,0" Visibility="Collapsed"/>
          </StackPanel>
          <StackPanel Grid.Column="1" Orientation="Horizontal">
            <Button x:Name="ImportButton" Margin="0,0,8,0" ToolTip="Įkelti pasirinkimus iš JSON failo">
              <StackPanel Orientation="Horizontal">
                <TextBlock Text="&#xE8E5;" FontFamily="{StaticResource IconFont}" VerticalAlignment="Center" Margin="0,0,8,0"/>
                <TextBlock Text="Importuoti"/>
              </StackPanel>
            </Button>
            <Button x:Name="ExportButton" Margin="0,0,14,0" ToolTip="Išsaugoti dabartinius pasirinkimus į JSON failą">
              <StackPanel Orientation="Horizontal">
                <TextBlock Text="&#xE78C;" FontFamily="{StaticResource IconFont}" VerticalAlignment="Center" Margin="0,0,8,0"/>
                <TextBlock Text="Eksportuoti"/>
              </StackPanel>
            </Button>
            <Button x:Name="PrimaryButton" Style="{StaticResource PrimaryButton}">
              <StackPanel Orientation="Horizontal">
                <TextBlock x:Name="PrimaryGlyph" FontFamily="{StaticResource IconFont}" VerticalAlignment="Center" Margin="0,0,9,0"/>
                <TextBlock x:Name="PrimaryText"/>
              </StackPanel>
            </Button>
          </StackPanel>
        </Grid>
      </Border>
    </Grid>
  </Grid>
</Window>
'@

$script:BrushCache = @{}
function Get-Brush {
    param([Parameter(Mandatory)][string]$Color, [byte]$Alpha = 255)
    $cacheKey = "$Color/$Alpha"
    if (-not $script:BrushCache.ContainsKey($cacheKey)) {
        $parsed = [System.Windows.Media.ColorConverter]::ConvertFromString($Color)
        $brush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromArgb($Alpha, $parsed.R, $parsed.G, $parsed.B))
        $brush.Freeze()
        $script:BrushCache[$cacheKey] = $brush
    }
    return $script:BrushCache[$cacheKey]
}

function New-TextBlock {
    param([string]$Text, [double]$Size = 13.5, [string]$Color = '#EDEDF0', [switch]$SemiBold, [switch]$Wrap)
    $block = [System.Windows.Controls.TextBlock]::new()
    $block.Text = $Text
    $block.FontSize = $Size
    $block.Foreground = Get-Brush $Color
    if ($SemiBold) { $block.FontWeight = 'SemiBold' }
    if ($Wrap) { $block.TextWrapping = 'Wrap' }
    return $block
}

function New-Tag {
    param([Parameter(Mandatory)][string]$Text, [Parameter(Mandatory)][string]$Color, [string]$ToolTip)
    $border = [System.Windows.Controls.Border]::new()
    $border.CornerRadius = [System.Windows.CornerRadius]::new(4)
    $border.Padding = '7,1,7,2'
    $border.Margin = '6,0,0,0'
    $border.VerticalAlignment = 'Top'
    $border.Background = Get-Brush $Color 36
    $border.Child = New-TextBlock -Text $Text -Size 11.5 -Color $Color
    if ($ToolTip) { $border.ToolTip = $ToolTip }
    return $border
}

function Get-ItemTags {
    param([Parameter(Mandatory)]$Item, [Parameter(Mandatory)][string]$Kind)
    $tags = [System.Collections.Generic.List[object]]::new()
    if ($Kind -eq 'Program') {
        switch ($Item.InstallType) {
            'WinGet' {
                if ($Item.Source -eq 'msstore') { $tags.Add(@('Microsoft Store', '#B39DFF', "Microsoft Store ID: $($Item.Id)")) }
                else { $tags.Add(@('WinGet', '#4CC2FF', "WinGet ID: $($Item.Id)")) }
            }
            'OfficialPage' { $tags.Add(@('Rankinis diegimas', '#5FD3C4', $Item.Url)) }
            'GitHubReleaseZip' { $tags.Add(@('GitHub', '#C9D1D9', "github.com/$($Item.Repository)")) }
        }
    }
    switch (Get-OptionalProperty $Item 'Effect') {
        'Explorer' { $tags.Add(@('Explorer', '#9EA7FF', 'Įsigalios perkrovus Explorer (mygtukas skiltyje „Žurnalas“) arba prisijungus iš naujo.')) }
        'SignOut' { $tags.Add(@('Atsijungimas', '#9EA7FF', 'Įsigalios atsijungus ir vėl prisijungus.')) }
        'Reboot' { $tags.Add(@('Perkrovimas', '#9EA7FF', 'Įsigalios paleidus Windows iš naujo.')) }
    }
    switch (Get-OptionalProperty $Item 'Risk') {
        'Caution' { $tags.Add(@('Atsargiai', '#F5B544', 'Perskaitykite aprašymą prieš pažymėdami.')) }
        'High' { $tags.Add(@('Rizikinga', '#FF7A7A', 'Sunkiai atkuriamas arba kitas programas paveikiantis pakeitimas.')) }
    }
    return , $tags.ToArray()
}

function Update-OptionVisual {
    param([Parameter(Mandatory)]$Option)
    if ($Option.CheckBox.IsChecked) {
        $color = if ($Option.Kind -in @('Startup', 'Task')) { '#FF7A7A' } else { '#4CC2FF' }
        $Option.Card.BorderBrush = Get-Brush $color 110
    } else {
        $Option.Card.ClearValue([System.Windows.Controls.Border]::BorderBrushProperty)
    }
}

function New-Option {
    param([Parameter(Mandatory)]$Section, [Parameter(Mandatory)]$Item, [Parameter(Mandatory)][string]$Title, [string]$Description, [object[]]$Tags = @(), [bool]$Checked, [string]$ToolTip)
    $titleBlock = New-TextBlock -Text $Title -Size 14 -SemiBold -Wrap
    $tagPanel = [System.Windows.Controls.StackPanel]::new()
    $tagPanel.Orientation = 'Horizontal'
    $tagPanel.Margin = '12,1,0,0'
    foreach ($tag in $Tags) { [void]$tagPanel.Children.Add((New-Tag -Text $tag[0] -Color $tag[1] -ToolTip $tag[2])) }
    $headerRow = [System.Windows.Controls.DockPanel]::new()
    [System.Windows.Controls.DockPanel]::SetDock($tagPanel, 'Right')
    [void]$headerRow.Children.Add($tagPanel)
    [void]$headerRow.Children.Add($titleBlock)
    $content = [System.Windows.Controls.StackPanel]::new()
    [void]$content.Children.Add($headerRow)
    if ($Description) {
        $descriptionBlock = New-TextBlock -Text $Description -Size 12.5 -Color '#A3A3AD' -Wrap
        $descriptionBlock.Margin = '0,4,0,0'
        $descriptionBlock.LineHeight = 19
        [void]$content.Children.Add($descriptionBlock)
    }

    $check = [System.Windows.Controls.CheckBox]::new()
    $check.Style = $script:Styles.OptionCheck
    $check.Content = $content
    $check.IsChecked = $Checked
    $card = [System.Windows.Controls.Border]::new()
    $card.Style = $script:Styles.OptionCard
    $card.Child = $check
    if ($ToolTip) { $card.ToolTip = $ToolTip }

    $option = [pscustomobject]@{ Section = $Section; Kind = $Section.OptionKind; Item = $Item; CheckBox = $check; Card = $card; SearchText = ("$Title $Description").ToLowerInvariant() }
    $check.Tag = $option
    $check.Add_Checked({ param($sender, $eventArgs) Update-OptionVisual $sender.Tag; Update-Counts })
    $check.Add_Unchecked({ param($sender, $eventArgs) Update-OptionVisual $sender.Tag; Update-Counts })
    Update-OptionVisual $option
    [void]$Section.Panel.Children.Add($card)
    $Section.Options.Add($option)
    return $option
}

function New-Section {
    param([Parameter(Mandatory)][string]$Id, [Parameter(Mandatory)][string]$Title, [string]$Glyph, [string]$Description, [Parameter(Mandatory)][string]$Kind, [string]$OptionKind)
    $panel = [System.Windows.Controls.StackPanel]::new()
    $section = [pscustomobject]@{
        Id = $Id; Title = $Title; Glyph = $Glyph; Description = $Description; Kind = $Kind; OptionKind = $OptionKind
        Panel = $panel; Options = [System.Collections.Generic.List[object]]::new(); Groups = [System.Collections.Generic.List[object]]::new()
        NavButton = $null; CountText = $null; EmptyText = $null; Loaded = $false
    }
    $script:Sections[$Id] = $section
    return $section
}

function Add-EmptyText {
    param([Parameter(Mandatory)]$Section, [string]$Text = 'Pagal paiešką nieko nerasta.')
    $Section.EmptyText = New-TextBlock -Text $Text -Color '#7A7A85'
    $Section.EmptyText.Margin = '2,8,0,0'
    $Section.EmptyText.Visibility = 'Collapsed'
    [void]$Section.Panel.Children.Add($Section.EmptyText)
}

function Add-CatalogSection {
    param([Parameter(Mandatory)]$Section, [Parameter(Mandatory)][object[]]$Items)
    $categories = [ordered]@{}
    foreach ($item in $Items) {
        $category = [string](Get-OptionalProperty $item 'Category')
        if (-not $categories.Contains($category)) { $categories[$category] = [System.Collections.Generic.List[object]]::new() }
        $categories[$category].Add($item)
    }
    foreach ($category in $categories.Keys) {
        $header = $null
        if ($category) {
            $header = New-TextBlock -Text $category.ToUpperInvariant() -Size 11.5 -Color '#8A8A95' -SemiBold
            $header.Margin = if ($Section.Groups.Count -eq 0) { '2,0,0,10' } else { '2,18,0,10' }
            [void]$Section.Panel.Children.Add($header)
        }
        $group = [pscustomobject]@{ Header = $header; Options = [System.Collections.Generic.List[object]]::new() }
        foreach ($item in $categories[$category]) {
            $option = New-Option -Section $Section -Item $item -Title $item.Name -Description (Get-OptionalProperty $item 'Description') -Tags (Get-ItemTags $item $Section.OptionKind) -Checked ([bool]$item.Default)
            $group.Options.Add($option)
        }
        $Section.Groups.Add($group)
    }
    Add-EmptyText $Section
}

function Add-NavGroupLabel {
    param([Parameter(Mandatory)][string]$Text)
    $label = New-TextBlock -Text $Text.ToUpperInvariant() -Size 11 -Color '#6F6F7A' -SemiBold
    $label.Margin = '12,12,0,4'
    [void]$ui.NavPanel.Children.Add($label)
}

function Add-NavItem {
    param([Parameter(Mandatory)]$Section)
    $icon = New-TextBlock -Text $Section.Glyph -Size 15 -Color '#9A9AA5'
    $icon.FontFamily = $script:IconFont
    $icon.Margin = '0,1,12,0'
    $icon.VerticalAlignment = 'Center'
    $count = New-TextBlock -Text '' -Size 12 -Color '#7A7A85'
    $count.VerticalAlignment = 'Center'
    $count.Margin = '8,0,0,0'
    $title = [System.Windows.Controls.TextBlock]::new()
    $title.Text = $Section.Title
    $title.TextTrimming = 'CharacterEllipsis'
    $title.VerticalAlignment = 'Center'
    $row = [System.Windows.Controls.DockPanel]::new()
    [System.Windows.Controls.DockPanel]::SetDock($icon, 'Left')
    [System.Windows.Controls.DockPanel]::SetDock($count, 'Right')
    [void]$row.Children.Add($icon)
    [void]$row.Children.Add($count)
    [void]$row.Children.Add($title)

    $radio = [System.Windows.Controls.RadioButton]::new()
    $radio.Style = $script:Styles.NavItem
    $radio.Content = $row
    $radio.Tag = $Section.Id
    $radio.Add_Checked({ param($sender, $eventArgs) if ($script:CurrentSection -ne $sender.Tag) { Show-Section -Id $sender.Tag } })
    $Section.NavButton = $radio
    $Section.CountText = $count
    [void]$ui.NavPanel.Children.Add($radio)
}

function Test-OptionAllowed {
    param([Parameter(Mandatory)]$Option)
    if ($Option.Kind -ne 'Task' -or $ui.ShowSystemTasksToggle.IsChecked) { return $true }
    return -not $Option.Item.IsSystem
}

function Update-SearchFilter {
    $ui.SearchPlaceholder.Visibility = if ($ui.SearchBox.Text) { 'Collapsed' } else { 'Visible' }
    $section = $script:Sections[$script:CurrentSection]
    if ($section.Kind -notin @('Catalog', 'Startup', 'Task')) { return }
    $query = $ui.SearchBox.Text.Trim().ToLowerInvariant()
    $visibleCount = 0
    foreach ($option in $section.Options) {
        $visible = (-not $query -or $option.SearchText.Contains($query)) -and (Test-OptionAllowed $option)
        $option.Card.Visibility = if ($visible) { 'Visible' } else { 'Collapsed' }
        if ($visible) { $visibleCount++ }
    }
    foreach ($group in $section.Groups) {
        if ($null -eq $group.Header) { continue }
        $hasVisible = @($group.Options | Where-Object { $_.Card.Visibility -eq 'Visible' }).Count -gt 0
        $group.Header.Visibility = if ($hasVisible) { 'Visible' } else { 'Collapsed' }
    }
    if ($section.EmptyText) { $section.EmptyText.Visibility = if ($visibleCount -eq 0 -and ($section.Loaded -or $section.Kind -eq 'Catalog')) { 'Visible' } else { 'Collapsed' } }
    Update-ActionInfo
}

function Update-ActionInfo {
    $section = $script:Sections[$script:CurrentSection]
    $checked = @($section.Options | Where-Object { $_.CheckBox.IsChecked }).Count
    switch ($section.Kind) {
        'Catalog' { $ui.ActionInfo.Text = 'Pažymėta {0} iš {1}' -f $checked, $section.Options.Count }
        { $_ -in @('Startup', 'Task') } {
            if (-not $section.Loaded) { $ui.ActionInfo.Text = ''; break }
            $hidden = @($section.Options | Where-Object { -not (Test-OptionAllowed $_) }).Count
            $ui.ActionInfo.Text = 'Įrašų: {0}{1}   ·   pažymėta: {2}' -f $section.Options.Count, $(if ($hidden) { " ($hidden paslėpta)" } else { '' }), $checked
        }
        'Log' { $ui.ActionInfo.Text = 'Klaidos: {0}   ·   Įspėjimai: {1}' -f $script:LogStats.ERROR, $script:LogStats.WARN }
        default { $ui.ActionInfo.Text = '' }
    }
}

function Update-Counts {
    if ($script:SuspendCounts) { return }
    $summary = @{ Program = 0; Extension = 0; App = 0; Setting = 0; Risk = 0 }
    foreach ($section in $script:Sections.Values) {
        $checked = 0
        foreach ($option in $section.Options) {
            if (-not $option.CheckBox.IsChecked) { continue }
            $checked++
            if ($section.Kind -eq 'Catalog') {
                $summary[$option.Kind]++
                if (Get-OptionalProperty $option.Item 'Risk') { $summary.Risk++ }
            }
        }
        if ($null -eq $section.CountText) { continue }
        if ($section.Kind -eq 'Catalog') {
            $section.CountText.Text = '{0}/{1}' -f $checked, $section.Options.Count
        } elseif ($section.Kind -eq 'Log') {
            $section.CountText.Text = if ($script:LogStats.ERROR) { [string]$script:LogStats.ERROR } else { '' }
            $section.CountText.Foreground = Get-Brush '#FF7A7A'
        } else {
            $section.CountText.Text = if ($checked) { [string]$checked } else { '' }
            $section.CountText.Foreground = Get-Brush '#FF7A7A'
        }
    }
    if ($null -eq $script:Job) {
        $text = 'Programos {0}  ·  Plėtiniai {1}  ·  Programėlės {2}  ·  Nustatymai {3}' -f $summary.Program, $summary.Extension, $summary.App, $summary.Setting
        if ($Uninstall) { $text = 'Atkūrimo režimas  ·  Programos {0}' -f $summary.Program }
        $ui.SummaryText.Text = $text
        $ui.SummaryRisk.Text = 'Reikalauja dėmesio: {0} – išvardyta peržiūroje.' -f $summary.Risk
        $ui.SummaryRisk.Visibility = if ($summary.Risk -and -not $Uninstall) { 'Visible' } else { 'Collapsed' }
    }
    if ($script:CurrentSection) { Update-ActionInfo }
}

function Update-Banner {
    $messages = @()
    if ($Uninstall) { $messages += 'Atkūrimo režimas (-Uninstall): pažymėtos programos bus įdiegtos iš naujo; kitos skiltys nevykdomos.' }
    if ($ui.DryRunToggle.IsChecked) { $messages += 'Bandomasis režimas įjungtas: niekas nebus pakeista, žurnale matysite planuojamus veiksmus.' }
    if ($script:AccountWarning) { $messages += $script:AccountWarning }
    $ui.ModeBannerText.Text = $messages -join "`n"
    $ui.ModeBanner.Visibility = if ($messages.Count) { 'Visible' } else { 'Collapsed' }
}

function Update-PrimaryButton {
    $ui.PrimaryButton.IsEnabled = $true
    if ($null -ne $script:Job) {
        if ($script:Job.Kind -eq 'Setup') {
            $ui.PrimaryGlyph.Text = [char]0xE71A
            $ui.PrimaryText.Text = if ($script:Sync.Cancel) { 'Stabdoma…' } else { 'Stabdyti' }
            $ui.PrimaryButton.IsEnabled = -not $script:Sync.Cancel
        } else {
            $ui.PrimaryGlyph.Text = [char]0xE895
            $ui.PrimaryText.Text = 'Vykdoma…'
            $ui.PrimaryButton.IsEnabled = $false
        }
        return
    }
    $dry = [bool]$ui.DryRunToggle.IsChecked
    if ($script:CurrentSection -eq 'review') {
        $ui.PrimaryGlyph.Text = [char]0xE768
        $ui.PrimaryText.Text = if ($dry) { 'Pradėti bandomąjį vykdymą' } else { 'Pradėti vykdymą' }
    } else {
        $ui.PrimaryGlyph.Text = [char]0xE8FD
        $ui.PrimaryText.Text = 'Peržiūrėti ir vykdyti'
    }
}

function Show-Section {
    param([Parameter(Mandatory)][string]$Id)
    $section = $script:Sections[$Id]
    $script:CurrentSection = $Id
    if ($section.NavButton) {
        if (-not $section.NavButton.IsChecked) { $section.NavButton.IsChecked = $true }
    } else {
        foreach ($other in $script:Sections.Values) { if ($other.NavButton) { $other.NavButton.IsChecked = $false } }
    }
    $ui.SectionGlyph.Text = $section.Glyph
    $ui.SectionTitle.Text = $section.Title
    $ui.SectionDescription.Text = $section.Description
    $ui.SearchHost.Visibility = if ($section.Kind -in @('Catalog', 'Startup', 'Task')) { 'Visible' } else { 'Collapsed' }
    $buttonKinds = @{
        SelectAllButton = @('Catalog'); SelectNoneButton = @('Catalog', 'Startup', 'Task'); SelectDefaultsButton = @('Catalog')
        RefreshButton = @('Startup', 'Task'); RemoveSelectedButton = @('Startup', 'Task'); ShowSystemTasksToggle = @('Task')
        RestartExplorerButton = @('Log'); OpenLogFileButton = @('Log'); BackButton = @('Review')
    }
    foreach ($name in $buttonKinds.Keys) {
        $ui[$name].Visibility = if ($buttonKinds[$name] -contains $section.Kind) { 'Visible' } else { 'Collapsed' }
    }
    $ui.ContentScroll.Content = $section.Panel
    if ($ui.SearchBox.Text) { $ui.SearchBox.Text = '' } else { Update-SearchFilter }
    if ($section.Kind -eq 'Log') {
        $script:FollowLog = $true
        $ui.ContentScroll.ScrollToEnd()
    } else {
        $ui.ContentScroll.ScrollToTop()
    }
    if ($section.Kind -in @('Startup', 'Task') -and -not $section.Loaded -and $null -eq $script:Job) { Update-RemovalSection $section }
    Update-ActionInfo
    Update-PrimaryButton
}

function Set-SectionSelection {
    param([Parameter(Mandatory)][ValidateSet('All', 'None', 'Defaults')][string]$Mode)
    $section = $script:Sections[$script:CurrentSection]
    $script:SuspendCounts = $true
    try {
        foreach ($option in $section.Options) {
            if ($option.Card.Visibility -ne 'Visible') { continue }
            $option.CheckBox.IsChecked = switch ($Mode) { 'All' { $true } 'None' { $false } 'Defaults' { [bool]$option.Item.Default } }
        }
    } finally { $script:SuspendCounts = $false }
    Update-Counts
}

function Add-LogLine {
    param([Parameter(Mandatory)]$Entry)
    $script:LogStats[$Entry.Level]++
    $block = [System.Windows.Controls.TextBlock]::new()
    $block.Text = $Entry.Line
    $block.TextWrapping = 'Wrap'
    $block.FontFamily = $script:MonoFont
    $block.FontSize = 12.5
    $block.Padding = '8,2,8,2'
    switch ($Entry.Level) {
        'OK' { $block.Foreground = Get-Brush '#6FD99A' }
        'WARN' { $block.Foreground = Get-Brush '#F5C15A' }
        'ERROR' { $block.Foreground = Get-Brush '#FFE0E0'; $block.Background = Get-Brush '#8A2433' 150 }
        default { $block.Foreground = Get-Brush '#C4C4CC' }
    }
    [void]$script:LogPanel.Children.Add($block)
    if ($script:LogPanel.Children.Count -gt 4000) { $script:LogPanel.Children.RemoveAt(0) }
}

function Receive-LogEntries {
    param([switch]$All)
    $entry = $null
    $added = 0
    while ($script:LogQueue.TryDequeue([ref]$entry)) {
        Add-LogLine $entry
        $added++
        if (-not $All -and $added -ge 300) { break }
    }
    if ($added -gt 0) {
        if ($script:CurrentSection -eq 'log' -and $script:FollowLog) { $ui.ContentScroll.ScrollToEnd() }
        Update-Counts
    }
}

function Start-Worker {
    param([Parameter(Mandatory)][string]$Kind, [Parameter(Mandatory)][string]$Script, $InputObject, [int]$Total = 0, [string]$Status = '', $Context, [Parameter(Mandatory)][scriptblock]$OnComplete)
    if ($null -ne $script:Job) { return $false }
    if ($null -eq $script:WorkerRunspace) {
        $sessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        $sessionState.ExecutionPolicy = [Microsoft.PowerShell.ExecutionPolicy]::Bypass
        foreach ($name in $script:BackendFunctionNames) {
            $sessionState.Commands.Add([System.Management.Automation.Runspaces.SessionStateFunctionEntry]::new($name, (Get-Item -LiteralPath "function:$name").Definition))
        }
        $shared = [ordered]@{ LogPath = $script:LogPath; LogQueue = $script:LogQueue; Sync = $script:Sync; AppName = $AppName; AppVersion = $AppVersion; PrivacyCatalog = $PrivacyCatalog }
        foreach ($variable in $shared.GetEnumerator()) {
            $sessionState.Variables.Add([System.Management.Automation.Runspaces.SessionStateVariableEntry]::new($variable.Key, $variable.Value, ''))
        }
        $script:WorkerRunspace = [runspacefactory]::CreateRunspace($sessionState)
        $script:WorkerRunspace.Open()
    }
    $script:WorkerRunspace.SessionStateProxy.SetVariable('JobInput', $InputObject)
    $script:Sync.Cancel = $false
    $script:Sync.Done = 0
    $script:Sync.Total = $Total
    $script:Sync.Current = ''
    $powershell = [powershell]::Create()
    $powershell.Runspace = $script:WorkerRunspace
    [void]$powershell.AddScript("Set-StrictMode -Version 3.0`n`$ErrorActionPreference = 'Stop'`n`$ProgressPreference = 'SilentlyContinue'`ntry { [Console]::OutputEncoding = [Text.Encoding]::UTF8 } catch { }`n$Script")
    $script:Job = [pscustomobject]@{ Kind = $Kind; Status = $Status; PowerShell = $powershell; Handle = $powershell.BeginInvoke(); OnComplete = $OnComplete; Context = $Context }
    Set-Busy $true
    return $true
}

function Set-Busy {
    param([Parameter(Mandatory)][bool]$Busy)
    foreach ($section in $script:Sections.Values) {
        if ($section.Kind -ne 'Log') { $section.Panel.IsEnabled = -not $Busy }
    }
    $controls = @('SelectAllButton', 'SelectNoneButton', 'SelectDefaultsButton', 'RefreshButton', 'RemoveSelectedButton', 'ShowSystemTasksToggle', 'RestartExplorerButton', 'BackButton', 'ImportButton', 'ExportButton', 'DryRunToggle')
    foreach ($name in $controls) { $ui[$name].IsEnabled = -not $Busy }
    $showProgress = $Busy -and $null -ne $script:Job -and $script:Job.Kind -in @('Setup', 'Removal')
    $ui.RunProgress.Visibility = if ($showProgress) { 'Visible' } else { 'Collapsed' }
    if ($Busy) { $ui.SummaryRisk.Visibility = 'Collapsed' }
    $ui.RunProgress.Value = 0
    Update-PrimaryButton
}

function Update-WorkerState {
    Receive-LogEntries
    $job = $script:Job
    if ($null -eq $job) { return }
    if ($job.Kind -in @('Setup', 'Removal')) {
        $total = [Math]::Max(1, [int]$script:Sync.Total)
        $done = [int]$script:Sync.Done
        $ui.RunProgress.Value = [Math]::Min(1.0, $done / $total)
        $ui.SummaryText.Text = 'Vykdoma {0} iš {1}   ·   {2}' -f [Math]::Min($done + 1, $total), $total, $script:Sync.Current
    } else {
        $ui.SummaryText.Text = $job.Status
    }
    if (-not $job.Handle.IsCompleted) { return }

    $script:Job = $null
    $output = @()
    $failure = $null
    try {
        $output = @($job.PowerShell.EndInvoke($job.Handle))
    } catch {
        $failure = $_.Exception
        while ($failure.InnerException) { $failure = $failure.InnerException }
    }
    foreach ($record in $job.PowerShell.Streams.Error) { Write-SetupLog "Fono užduoties klaida: $record" 'ERROR' }
    $job.PowerShell.Dispose()
    if ($failure) { Write-SetupLog "Fono užduotis nutrūko: $($failure.Message)" 'ERROR' }
    Receive-LogEntries -All
    Set-Busy $false
    try { & $job.OnComplete $output $failure $job.Context }
    catch { Write-SetupLog "Rezultato apdorojimo klaida: $($_.Exception.Message)" 'ERROR' }
    Receive-LogEntries -All
    Update-Counts
}

function Set-RemovalEntries {
    param([Parameter(Mandatory)]$Section, [object[]]$Entries)
    $script:SuspendCounts = $true
    try {
        $Section.Panel.Children.Clear()
        $Section.Options.Clear()
        $Section.Groups.Clear()
        $group = [pscustomobject]@{ Header = $null; Options = [System.Collections.Generic.List[object]]::new() }
        foreach ($entry in $Entries) {
            $tags = [System.Collections.Generic.List[object]]::new()
            if ($entry.Kind -eq 'Registry') {
                $tags.Add(@($entry.Scope, '#5FD3C4', $(if ($entry.Scope -eq 'HKCU') { 'Tik šiam naudotojui' } else { 'Visiems naudotojams' })))
                $tags.Add(@($entry.Bitness, '#8A8A95', 'Registro rodinys'))
                if ($entry.Suffix -eq 'RunOnce') { $tags.Add(@('RunOnce', '#B39DFF', 'Vykdoma vieną kartą kito prisijungimo metu')) }
            } elseif ($entry.Kind -eq 'File') {
                $tags.Add(@($entry.Scope, '#5FD3C4', 'Paleisties aplanko failas'))
            } elseif ($entry.Kind -eq 'Task') {
                $stateTag = switch ($entry.State) {
                    'Ready' { @('Paruošta', '#6FD99A', 'Užduotis aktyvi') }
                    'Disabled' { @('Išjungta', '#8A8A95', 'Užduotis išjungta') }
                    'Running' { @('Vykdoma', '#F5B544', 'Vykdomos užduotys nešalinamos') }
                    default { @($entry.State, '#8A8A95', 'Būsena') }
                }
                $tags.Add($stateTag)
                if ($entry.IsSystem) { $tags.Add(@('Windows', '#FF7A7A', 'Windows sisteminė užduotis – šalinkite tik tiksliai žinodami, ką ji daro.')) }
            }
            $title = if ($entry.Title) { $entry.Title } else { '(numatytoji reikšmė)' }
            $option = New-Option -Section $Section -Item $entry -Title $title -Description $entry.Detail -Tags $tags.ToArray() -Checked $false -ToolTip $entry.Name
            $group.Options.Add($option)
        }
        $Section.Groups.Add($group)
        Add-EmptyText $Section 'Įrašų nerasta.'
    } finally { $script:SuspendCounts = $false }
    if ($script:CurrentSection -eq $Section.Id) { Update-SearchFilter }
    Update-Counts
}

function Update-RemovalSection {
    param([Parameter(Mandatory)]$Section)
    if ($null -ne $script:Job) { return }
    $Section.Loaded = $true
    $Section.Panel.Children.Clear()
    $Section.Options.Clear()
    $Section.Groups.Clear()
    $Section.EmptyText = $null
    $loading = New-TextBlock -Text 'Įkeliamas sąrašas…' -Color '#7A7A85'
    $loading.Margin = '2,8,0,0'
    [void]$Section.Panel.Children.Add($loading)
    $workerScript = if ($Section.OptionKind -eq 'Startup') { '@(Get-StartupEntries)' } else { '@(Get-TaskEntries)' }
    [void](Start-Worker -Kind 'Refresh' -Script $workerScript -Status 'Įkeliamas sąrašas…' -Context $Section.Id -OnComplete {
        param($Output, $Failure, $Context)
        $target = $script:Sections[$Context]
        Set-RemovalEntries -Section $target -Entries @($Output)
        Write-SetupLog "Sąrašas atnaujintas ($($target.Title)): $(@($Output).Count) įrašų."
    })
}

function Invoke-SelectedRemoval {
    $section = $script:Sections[$script:CurrentSection]
    $selected = @($section.Options | Where-Object { $_.CheckBox.IsChecked } | ForEach-Object { $_.Item })
    if ($selected.Count -eq 0) {
        [void][System.Windows.MessageBox]::Show($window, 'Pirmiausia pažymėkite norimus pašalinti įrašus.', $AppName, 'OK', 'Information')
        return
    }
    $dry = [bool]$ui.DryRunToggle.IsChecked
    if (-not $dry) {
        $lines = @($selected | Select-Object -First 15 | ForEach-Object { '• ' + $_.Title })
        if ($selected.Count -gt 15) { $lines += "… ir dar $($selected.Count - 15)" }
        $system = @($selected | Where-Object { (Get-OptionalProperty $_ 'IsSystem') -eq $true }).Count
        $warning = if ($system) { "`r`n`r`nDĖMESIO: pažymėta Windows sisteminių užduočių: $system. Jų šalinimas gali sutrikdyti Windows veikimą ar naujinimus." } else { '' }
        $answer = [System.Windows.MessageBox]::Show($window, "Pašalinti $($selected.Count) pažymėtus įrašus? Prieš šalinimą bus išsaugotos atsarginės kopijos.$warning`r`n`r`n$($lines -join "`r`n")", 'Patvirtinkite šalinimą', 'YesNo', 'Warning')
        if ($answer -ne [System.Windows.MessageBoxResult]::Yes) { return }
    }
    $script:Sync.DryRun = $dry
    [void](Start-Worker -Kind 'Removal' -Script 'Invoke-EntryRemoval -Kind $JobInput.Kind -Entries $JobInput.Entries' -Status 'Šalinama…' -InputObject @{ Kind = $section.OptionKind; Entries = $selected } -Total $selected.Count -Context $section.Id -OnComplete {
        param($Output, $Failure, $Context)
        $target = $script:Sections[$Context]
        if (-not $script:Sync.DryRun) {
            [void][System.Windows.MessageBox]::Show($window, 'Šalinimas baigtas. Atsarginių kopijų vietos nurodytos žurnale.', $AppName, 'OK', 'Information')
        }
        Update-RemovalSection $target
    })
}

function Get-SelectedPlan {
    $plan = [pscustomobject]@{ Mode = $(if ($Uninstall) { 'Reinstall' } else { 'Apply' }); Programs = @(); Extensions = @(); Apps = @(); Settings = @() }
    foreach ($section in $script:Sections.Values) {
        if ($section.Kind -ne 'Catalog') { continue }
        foreach ($option in $section.Options) {
            if (-not $option.CheckBox.IsChecked) { continue }
            switch ($option.Kind) {
                'Program' { $plan.Programs += $option.Item }
                'Extension' { $plan.Extensions += $option.Item }
                'App' { $plan.Apps += $option.Item }
                'Setting' { $plan.Settings += $option.Item }
            }
        }
    }
    if ($Uninstall) { $plan.Extensions = @(); $plan.Apps = @(); $plan.Settings = @() }
    return $plan
}

function New-ReviewBlock {
    param([Parameter(Mandatory)][string]$Title, [Parameter(Mandatory)][object[]]$Items)
    $header = New-TextBlock -Text ('{0} ({1})' -f $Title.ToUpperInvariant(), $Items.Count) -Size 11.5 -Color '#8A8A95' -SemiBold
    $header.Margin = '2,18,0,10'
    [void]$script:ReviewPanel.Children.Add($header)
    $wrap = [System.Windows.Controls.WrapPanel]::new()
    foreach ($item in $Items) {
        $chip = [System.Windows.Controls.Border]::new()
        $chip.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $chip.Padding = '10,5,10,6'
        $chip.Margin = '0,0,6,6'
        $chip.Background = Get-Brush '#232329'
        $chip.BorderThickness = '1'
        $risk = Get-OptionalProperty $item 'Risk'
        $chip.BorderBrush = switch ($risk) { 'High' { Get-Brush '#FF7A7A' 140 } 'Caution' { Get-Brush '#F5B544' 120 } default { Get-Brush '#2E2E35' } }
        $chip.Child = New-TextBlock -Text $item.Name -Size 12.5 -Color '#D6D6DD'
        $description = Get-OptionalProperty $item 'Description'
        if ($description) { $chip.ToolTip = $description }
        [void]$wrap.Children.Add($chip)
    }
    [void]$script:ReviewPanel.Children.Add($wrap)
}

function Show-Review {
    $plan = Get-SelectedPlan
    if ($script:CurrentSection -ne 'review') { $script:ReturnSection = $script:CurrentSection }
    $script:ReviewPanel.Children.Clear()
    $groups = @(
        [pscustomobject]@{ Title = 'Programos'; Items = @($plan.Programs); Glyph = [char]0xE896 }
        [pscustomobject]@{ Title = 'Vivaldi plėtiniai'; Items = @($plan.Extensions); Glyph = [char]0xEA86 }
        [pscustomobject]@{ Title = 'Šalinamos programėlės'; Items = @($plan.Apps); Glyph = [char]0xE74D }
        [pscustomobject]@{ Title = 'Windows nustatymai'; Items = @($plan.Settings); Glyph = [char]0xE713 }
    )
    $total = 0
    foreach ($group in $groups) { $total += $group.Items.Count }
    if ($total -eq 0) {
        $empty = New-TextBlock -Text 'Niekas nepažymėta. Grįžkite į skiltis kairėje ir pažymėkite norimus veiksmus.' -Color '#A3A3AD' -Wrap
        [void]$script:ReviewPanel.Children.Add($empty)
        Show-Section 'review'
        return
    }

    $tiles = [System.Windows.Controls.Primitives.UniformGrid]::new()
    $tiles.Columns = 4
    $tiles.Margin = '0,0,0,8'
    foreach ($group in $groups) {
        $tile = [System.Windows.Controls.Border]::new()
        $tile.CornerRadius = [System.Windows.CornerRadius]::new(8)
        $tile.Background = Get-Brush '#212126'
        $tile.BorderBrush = Get-Brush '#2B2B32'
        $tile.BorderThickness = '1'
        $tile.Padding = '16,12,16,12'
        $tile.Margin = '0,0,10,0'
        $stack = [System.Windows.Controls.StackPanel]::new()
        $top = [System.Windows.Controls.StackPanel]::new()
        $top.Orientation = 'Horizontal'
        $glyph = New-TextBlock -Text $group.Glyph -Size 14 -Color '#4CC2FF'
        $glyph.FontFamily = $script:IconFont
        $glyph.Margin = '0,2,8,0'
        [void]$top.Children.Add($glyph)
        [void]$top.Children.Add((New-TextBlock -Text $group.Title -Size 12.5 -Color '#A3A3AD'))
        [void]$stack.Children.Add($top)
        $number = New-TextBlock -Text ([string]$group.Items.Count) -Size 26 -SemiBold
        $number.Margin = '0,4,0,0'
        [void]$stack.Children.Add($number)
        $tile.Child = $stack
        [void]$tiles.Children.Add($tile)
    }
    [void]$script:ReviewPanel.Children.Add($tiles)

    $all = @($plan.Programs) + @($plan.Extensions) + @($plan.Apps) + @($plan.Settings)
    $risky = @($all | Where-Object { Get-OptionalProperty $_ 'Risk' })
    if ($risky.Count -gt 0) {
        $box = [System.Windows.Controls.Border]::new()
        $box.CornerRadius = [System.Windows.CornerRadius]::new(8)
        $box.Background = Get-Brush '#F5B544' 22
        $box.BorderBrush = Get-Brush '#F5B544' 90
        $box.BorderThickness = '1'
        $box.Padding = '16,12,16,12'
        $box.Margin = '0,10,0,0'
        $stack = [System.Windows.Controls.StackPanel]::new()
        [void]$stack.Children.Add((New-TextBlock -Text 'Atkreipkite dėmesį' -Size 14 -Color '#F5C766' -SemiBold))
        foreach ($item in $risky) {
            $line = New-TextBlock -Text ('• {0} – {1}' -f $item.Name, (Get-OptionalProperty $item 'Description')) -Size 12.5 -Color '#E8D6AE' -Wrap
            $line.Margin = '0,6,0,0'
            [void]$stack.Children.Add($line)
        }
        $box.Child = $stack
        [void]$script:ReviewPanel.Children.Add($box)
    }

    $effects = @($all | ForEach-Object { Get-OptionalProperty $_ 'Effect' } | Where-Object { $_ })
    if ($effects.Count -gt 0) {
        $notes = @()
        if ($effects -contains 'Reboot') { $notes += 'paleisti Windows iš naujo' }
        if ($effects -contains 'SignOut') { $notes += 'atsijungti ir vėl prisijungti' }
        if ($effects -contains 'Explorer') { $notes += 'perkrauti Explorer' }
        $info = New-TextBlock -Text ('Kai kuriems pakeitimams įsigalioti reikės: {0}.' -f ($notes -join ', ')) -Size 12.5 -Color '#9EA7FF' -Wrap
        $info.Margin = '2,12,0,0'
        [void]$script:ReviewPanel.Children.Add($info)
    }

    foreach ($group in $groups) {
        if ($group.Items.Count -gt 0) { New-ReviewBlock -Title $group.Title -Items $group.Items }
    }
    Show-Section 'review'
}

function Start-SetupRun {
    $plan = Get-SelectedPlan
    $total = @($plan.Programs).Count + @($plan.Extensions).Count + @($plan.Apps).Count + @($plan.Settings).Count
    if ($total -eq 0) {
        [void][System.Windows.MessageBox]::Show($window, 'Niekas nepažymėta.', $AppName, 'OK', 'Information')
        return
    }
    $script:Sync.DryRun = [bool]$ui.DryRunToggle.IsChecked
    $script:RunBaseline = $script:LogStats.Clone()
    $started = Start-Worker -Kind 'Setup' -Script 'Invoke-SetupPlan -Plan $JobInput' -InputObject $plan -Total $total -OnComplete {
        param($Output, $Failure, $Context)
        $errors = $script:LogStats.ERROR - $script:RunBaseline.ERROR
        $warnings = $script:LogStats.WARN - $script:RunBaseline.WARN
        if ($script:Sync.DryRun) {
            $message = "Bandomasis vykdymas baigtas. Žurnale matote, kas būtų padaryta.`r`n`r`nĮspėjimai: $warnings"
        } elseif ($script:Sync.Cancel) {
            $message = "Vykdymas sustabdytas. Atlikti veiksmai lieka pritaikyti, likę praleisti.`r`n`r`nKlaidos: $errors   ·   Įspėjimai: $warnings"
        } else {
            $message = "Vykdymas baigtas.`r`n`r`nKlaidos: $errors   ·   Įspėjimai: $warnings`r`n`r`nPeržiūrėkite žurnalą ir paleiskite Windows iš naujo, kad visi pakeitimai įsigaliotų."
        }
        $icon = if ($errors -gt 0) { 'Warning' } else { 'Information' }
        [void][System.Windows.MessageBox]::Show($window, $message, $AppName, 'OK', $icon)
    }
    if ($started) { Show-Section 'log' }
}

function Export-SelectionConfig {
    param([Parameter(Mandatory)][string]$Path)
    $config = [ordered]@{ 'Versija' = 2; 'Programos' = @(); 'VivaldiPlėtiniai' = @(); 'IntegruotosProgramėlės' = @(); 'Nustatymai' = [ordered]@{} }
    foreach ($section in $script:Sections.Values) {
        if ($section.Kind -ne 'Catalog') { continue }
        foreach ($option in $section.Options) {
            if (-not $option.CheckBox.IsChecked) { continue }
            $key = Get-CatalogKey $option.Item
            switch ($option.Kind) {
                'Program' { $config.Programos += $key }
                'Extension' { $config.VivaldiPlėtiniai += $key }
                'App' { $config.IntegruotosProgramėlės += $key }
                'Setting' { $config.Nustatymai[$key] = $true }
            }
        }
    }
    [IO.File]::WriteAllText($Path, ($config | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
    Write-SetupLog "Konfigūracija išsaugota: $Path" 'OK'
}

function Import-SelectionConfig {
    param([Parameter(Mandatory)][string]$Path)
    $config = [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8) | ConvertFrom-Json
    $settings = Get-OptionalProperty $config 'Nustatymai'
    $wanted = @{
        Program = @(Get-OptionalProperty $config 'Programos')
        Extension = @(Get-OptionalProperty $config 'VivaldiPlėtiniai')
        App = @(Get-OptionalProperty $config 'IntegruotosProgramėlės')
        Setting = @(if ($settings) { $settings.PSObject.Properties | Where-Object { $_.Value -eq $true } | ForEach-Object Name })
    }
    $known = @{}
    $script:SuspendCounts = $true
    try {
        foreach ($section in $script:Sections.Values) {
            if ($section.Kind -ne 'Catalog') { continue }
            foreach ($option in $section.Options) {
                $key = Get-CatalogKey $option.Item
                $known["$($option.Kind)|$key"] = $true
                # The file describes the full selection: anything it does not list is cleared.
                $option.CheckBox.IsChecked = $wanted[$option.Kind] -contains $key
            }
        }
    } finally { $script:SuspendCounts = $false }
    Update-Counts
    foreach ($kind in $wanted.Keys) {
        foreach ($key in $wanted[$kind]) {
            if ($key -and -not $known.ContainsKey("$kind|$key")) { Write-SetupLog "Konfigūracijoje nežinomas įrašas ($kind): $key" 'WARN' }
        }
    }
    Write-SetupLog "Konfigūracija importuota iš: $Path" 'OK'
}

function Get-AccountWarning {
    # HKCU tweaks and per-user installs land in the elevated account, which may not be the signed-in one.
    try {
        $session = (Get-Process -Id $PID).SessionId
        $shell = Get-Process -Name 'explorer' -IncludeUserName -ErrorAction Stop | Where-Object { $_.SessionId -eq $session } | Select-Object -First 1
        $current = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        if ($shell -and $shell.UserName -and $shell.UserName -ne $current) {
            return "Programa paleista kaip $current, o prisijungęs naudotojas yra $($shell.UserName). Naudotojo nustatymai ir kai kurios programos bus pritaikyti $current paskyrai. Geriau prisijunkite administratoriaus paskyra."
        }
    } catch { }
    return $null
}

function Initialize-NativeMethods {
    if ('FreshWindowsSetup.NativeMethods' -as [type]) { return $true }
    try {
        Add-Type -Namespace FreshWindowsSetup -Name NativeMethods -MemberDefinition @'
[DllImport("dwmapi.dll")] public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attribute, ref int value, int size);
[DllImport("kernel32.dll")] public static extern IntPtr GetConsoleWindow();
[DllImport("kernel32.dll")] public static extern uint GetConsoleProcessList(uint[] processList, uint count);
[DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hwnd, int command);
'@
        return $true
    } catch { return $false }
}

function Set-WindowChrome {
    if (-not (Initialize-NativeMethods)) { return }
    try {
        # A compiled console build owns its console window; hide it (never a console the user opened).
        $console = [FreshWindowsSetup.NativeMethods]::GetConsoleWindow()
        if (-not $PSCommandPath -and $console -ne [IntPtr]::Zero -and [FreshWindowsSetup.NativeMethods]::GetConsoleProcessList([uint32[]]::new(4), 4) -le 1) {
            [void][FreshWindowsSetup.NativeMethods]::ShowWindow($console, 0)
        }
        $handle = [System.Windows.Interop.WindowInteropHelper]::new($window).EnsureHandle()
        $darkMode = 1
        [void][FreshWindowsSetup.NativeMethods]::DwmSetWindowAttribute($handle, 20, [ref]$darkMode, 4)
        $captionColor = 0x00211D1D  # COLORREF (0x00BBGGRR) of the sidebar colour #1D1D21
        [void][FreshWindowsSetup.NativeMethods]::DwmSetWindowAttribute($handle, 35, [ref]$captionColor, 4)
    } catch { }
}

try {
    $window = [System.Windows.Markup.XamlReader]::Parse($xaml)
    $ui = @{}
    foreach ($match in [regex]::Matches($xaml, 'x:Name="(\w+)"')) {
        $element = $window.FindName($match.Groups[1].Value)
        if ($null -ne $element) { $ui[$match.Groups[1].Value] = $element }
    }
    $script:Styles = @{}
    foreach ($name in @('OptionCheck', 'OptionCard', 'NavItem')) { $script:Styles[$name] = $window.FindResource($name) }
    $script:IconFont = $window.FindResource('IconFont')
    $script:MonoFont = [System.Windows.Media.FontFamily]::new('Cascadia Mono, Consolas')
    $script:Sections = [ordered]@{}
    $script:CurrentSection = $null
    $script:SuspendCounts = $false
    $script:FollowLog = $true
    $script:Job = $null
    $script:WorkerRunspace = $null
    $script:LogStats = @{ INFO = 0; OK = 0; WARN = 0; ERROR = 0 }
    $script:RunBaseline = $script:LogStats.Clone()
    $script:AccountWarning = $null
    $script:ReturnSection = 'programs'

    $ui.VersionText.Text = "v$AppVersion  ·  $AppAuthor"
    $window.Title = "$AppName v$AppVersion"
    $workArea = [System.Windows.SystemParameters]::WorkArea
    $window.Width = [Math]::Min($window.Width, $workArea.Width - 40)
    $window.Height = [Math]::Min($window.Height, $workArea.Height - 40)

    $programs = New-Section -Id 'programs' -Title 'Programos' -Glyph ([char]0xE896) -Kind 'Catalog' -OptionKind 'Program' -Description 'Pažymėtos programos įdiegiamos tyliai per WinGet arba iš oficialių šaltinių; jau įdiegtos praleidžiamos. „Rankinis diegimas“ tik atveria gamintojo puslapį – diegimą užbaigiate patys.'
    Add-CatalogSection $programs $ProgramCatalog
    $extensions = New-Section -Id 'extensions' -Title 'Vivaldi plėtiniai' -Glyph ([char]0xEA86) -Kind 'Catalog' -OptionKind 'Extension' -Description 'Plėtiniai užregistruojami per Vivaldi politiką ir įdiegiami kitą kartą paleidus Vivaldi. Taip įdiegtų plėtinių negalima pašalinti naršyklėje – tik ištrynus įrašą registre.'
    Add-CatalogSection $extensions $VivaldiExtensionCatalog
    $apps = New-Section -Id 'apps' -Title 'Integruotos programėlės' -Glyph ([char]0xE74D) -Kind 'Catalog' -OptionKind 'App' -Description 'Pašalinamos tik pažymėtos programėlės – visiems naudotojams ir naujoms paskyroms. WebView2, Microsoft Store, WinGet ir sisteminiai komponentai niekada nešalinami. Daugumą programėlių vėliau galima vėl įdiegti iš Microsoft Store.'
    Add-CatalogSection $apps $BundledAppCatalog
    $startup = New-Section -Id 'startup' -Title 'Paleisties programos' -Glyph ([char]0xE7E8) -Kind 'Startup' -OptionKind 'Startup' -Description 'Programos, paleidžiamos prisijungus (registro Run / RunOnce ir paleisties aplankai). Šalinamas tik automatinis paleidimas – pati programa lieka. Prieš šalinimą išsaugoma atsarginė kopija. Šis veiksmas atliekamas atskirai nuo pagrindinio vykdymo.'
    $tasks = New-Section -Id 'tasks' -Title 'Suplanuotos užduotys' -Glyph ([char]0xE787) -Kind 'Task' -OptionKind 'Task' -Description 'Užduočių planuoklio užduotys. Windows sisteminės užduotys (\Microsoft\) pagal nutylėjimą paslėptos. Šalinkite tik atpažįstamas užduotis; prieš šalinimą išsaugoma XML kopija, vykdomos užduotys nešalinamos.'
    foreach ($section in @($startup, $tasks)) {
        $hint = New-TextBlock -Text 'Sąrašas dar neįkeltas. Spauskite „Atnaujinti sąrašą“.' -Color '#7A7A85'
        $hint.Margin = '2,8,0,0'
        [void]$section.Panel.Children.Add($hint)
    }
    $settingSections = @()
    $index = 0
    foreach ($group in $WindowsSettingsSections) {
        $index++
        $section = New-Section -Id "settings$index" -Title $group.Title -Glyph $group.Glyph -Kind 'Catalog' -OptionKind 'Setting' -Description $group.Description
        Add-CatalogSection $section $group.Items
        $settingSections += $section
    }
    $logSection = New-Section -Id 'log' -Title 'Žurnalas' -Glyph ([char]0xE9D9) -Kind 'Log' -Description "Visi veiksmai ir jų patikros rezultatai. Klaidos pažymėtos raudonai, įspėjimai – geltonai. Žurnalo failas: $script:LogPath"
    $script:LogPanel = $logSection.Panel
    $review = New-Section -Id 'review' -Title 'Peržiūra prieš vykdymą' -Glyph ([char]0xE8FD) -Kind 'Review' -Description 'Patikrinkite, kas bus pakeista. Užveskite pelę ant elemento, kad pamatytumėte aprašymą. Pakeitimai pradedami tik paspaudus „Pradėti vykdymą“.'
    $script:ReviewPanel = $review.Panel

    Add-NavGroupLabel 'Diegimas'
    Add-NavItem $programs
    Add-NavItem $extensions
    Add-NavGroupLabel 'Valymas'
    Add-NavItem $apps
    Add-NavItem $startup
    Add-NavItem $tasks
    Add-NavGroupLabel 'Windows nustatymai'
    foreach ($section in $settingSections) { Add-NavItem $section }
    Add-NavGroupLabel 'Vykdymas'
    Add-NavItem $logSection

    $ui.SearchBox.Add_TextChanged({ Update-SearchFilter })
    $ui.SelectAllButton.Add_Click({ Set-SectionSelection 'All' })
    $ui.SelectNoneButton.Add_Click({ Set-SectionSelection 'None' })
    $ui.SelectDefaultsButton.Add_Click({ Set-SectionSelection 'Defaults' })
    $ui.RefreshButton.Add_Click({ Update-RemovalSection $script:Sections[$script:CurrentSection] })
    $ui.RemoveSelectedButton.Add_Click({ Invoke-SelectedRemoval })
    $ui.ShowSystemTasksToggle.Add_Click({ Update-SearchFilter })
    $ui.RestartExplorerButton.Add_Click({ [void](Start-Worker -Kind 'Explorer' -Script 'Restart-Explorer' -Status 'Perkraunamas Explorer…' -OnComplete { }) })
    $ui.OpenLogFileButton.Add_Click({ if (Test-Path -LiteralPath $script:LogPath) { Start-Process -FilePath 'notepad.exe' -ArgumentList @("`"$script:LogPath`"") } })
    $ui.BackButton.Add_Click({ Show-Section $script:ReturnSection })
    $ui.DryRunToggle.Add_Click({ Update-Banner; Update-PrimaryButton })
    $ui.ContentScroll.Add_ScrollChanged({
        param($sender, $eventArgs)
        if ($script:CurrentSection -eq 'log' -and $eventArgs.ExtentHeightChange -eq 0) { $script:FollowLog = $sender.VerticalOffset -ge ($sender.ScrollableHeight - 4) }
    })

    $ui.PrimaryButton.Add_Click({
        if ($null -ne $script:Job) {
            if ($script:Job.Kind -eq 'Setup' -and -not $script:Sync.Cancel) {
                $script:Sync.Cancel = $true
                Write-SetupLog 'Stabdoma: dabartinis veiksmas bus užbaigtas, likę praleisti.' 'WARN'
                Update-PrimaryButton
            }
            return
        }
        if ($script:CurrentSection -eq 'review') { Start-SetupRun } else { Show-Review }
    })

    $ui.ExportButton.Add_Click({
        $path = $ExportConfig
        if (-not $path) {
            $dialog = [Microsoft.Win32.SaveFileDialog]::new()
            $dialog.Filter = 'JSON (*.json)|*.json'
            $dialog.FileName = 'FreshWindowsSetup.json'
            if (-not $dialog.ShowDialog($window)) { return }
            $path = $dialog.FileName
        }
        try {
            Export-SelectionConfig -Path $path
            [void][System.Windows.MessageBox]::Show($window, "Konfigūracija išsaugota:`r`n$path", $AppName, 'OK', 'Information')
        } catch {
            Write-SetupLog "Nepavyko išsaugoti konfigūracijos: $($_.Exception.Message)" 'ERROR'
            [void][System.Windows.MessageBox]::Show($window, $_.Exception.Message, $AppName, 'OK', 'Error')
        }
        Receive-LogEntries -All
    })

    $ui.ImportButton.Add_Click({
        $dialog = [Microsoft.Win32.OpenFileDialog]::new()
        $dialog.Filter = 'JSON (*.json)|*.json'
        if (-not $dialog.ShowDialog($window)) { return }
        try {
            Import-SelectionConfig -Path $dialog.FileName
            [void][System.Windows.MessageBox]::Show($window, 'Konfigūracija įkelta. Peržiūrėkite pasirinkimus ir spauskite „Peržiūrėti ir vykdyti“.', $AppName, 'OK', 'Information')
        } catch {
            Write-SetupLog "Nepavyko importuoti konfigūracijos: $($_.Exception.Message)" 'ERROR'
            [void][System.Windows.MessageBox]::Show($window, $_.Exception.Message, $AppName, 'OK', 'Error')
        }
        Receive-LogEntries -All
    })

    $window.Add_PreviewKeyDown({
        param($sender, $eventArgs)
        $ctrl = ([System.Windows.Input.Keyboard]::Modifiers -band [System.Windows.Input.ModifierKeys]::Control) -ne 0
        if ($ctrl -and $eventArgs.Key -eq 'F' -and $ui.SearchHost.Visibility -eq 'Visible') {
            [void]$ui.SearchBox.Focus()
            $ui.SearchBox.SelectAll()
            $eventArgs.Handled = $true
        } elseif ($eventArgs.Key -eq 'Escape' -and $ui.SearchBox.IsKeyboardFocused) {
            $ui.SearchBox.Text = ''
            $eventArgs.Handled = $true
        }
    })

    $window.Add_Closing({
        param($sender, $eventArgs)
        if ($null -ne $script:Job -and $script:Job.Kind -ne 'Refresh') {
            $answer = [System.Windows.MessageBox]::Show($window, 'Vykdymas dar nebaigtas. Uždarius langą dabartinis veiksmas gali likti nebaigtas. Uždaryti vis tiek?', $AppName, 'YesNo', 'Warning')
            if ($answer -ne [System.Windows.MessageBoxResult]::Yes) { $eventArgs.Cancel = $true; return }
            $script:Sync.Cancel = $true
        }
    })
    $window.Add_Closed({
        $script:Timer.Stop()
        if ($null -ne $script:WorkerRunspace -and $null -eq $script:Job) { $script:WorkerRunspace.Dispose() }
    })

    $script:Timer = [System.Windows.Threading.DispatcherTimer]::new()
    $script:Timer.Interval = [TimeSpan]::FromMilliseconds(150)
    $script:Timer.Add_Tick({
        try { Update-WorkerState } catch { Write-SetupLog "Sąsajos atnaujinimo klaida: $($_.Exception.Message)" 'ERROR' }
    })

    $ui.DryRunToggle.IsChecked = [bool]$DryRun
    if (-not $ValidateOnly) { $script:AccountWarning = Get-AccountWarning }
    if ($ImportConfig) {
        try { Import-SelectionConfig -Path $ImportConfig }
        catch { Write-SetupLog "Nepavyko importuoti konfigūracijos: $($_.Exception.Message)" 'ERROR' }
    }
    if ($ExportConfig) { $ui.ExportButton.ToolTip = "Išsaugoti pasirinkimus į $ExportConfig" }
    Update-Banner
    Show-Section 'programs'
    Update-Counts
    if (-not $ValidateOnly) { Write-SetupLog 'Paruošta. Pakeitimų dar neatlikta.' }
    Receive-LogEntries -All
} catch {
    if ($ValidateOnly) { throw }
    Add-Type -AssemblyName PresentationFramework
    [void][System.Windows.MessageBox]::Show("Nepavyko paleisti sąsajos:`r`n$($_.Exception.Message)`r`n`r`n$($_.InvocationInfo.PositionMessage)", $AppName, 'OK', 'Error')
    exit 1
}

if ($ValidateOnly) {
    $optionCount = ($script:Sections.Values | ForEach-Object { $_.Options.Count } | Measure-Object -Sum).Sum
    Write-Output "$AppName v$AppVersion patikros įkėlimas baigtas ($optionCount parinktys, $($script:BackendFunctionNames.Count) fono funkcijos)."
    exit 0
}

Set-WindowChrome
$script:Timer.Start()
[void]$window.ShowDialog()
# The user chose to close during a run; do not wait for the background step to finish.
if ($null -ne $script:Job) { [Environment]::Exit(0) }
