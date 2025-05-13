## friedl
([english version is here](friedl.md))

friedl steht für
```
F
R
I tzbox
E ventlog
D own
L oader
```

Es handelt sich um ein bash-Skript das eine lokale
Kopie aller FRITZ!Box Ereignisse bereitstellt und aktualisiert.
Es wird pro Jahr eine Datei angelegt.

### Was macht das Skript
Es verbindet sich mit Deiner FRITZ!Box und holt sich die Ereignismeldungen. Dann speichert es sie in einer Datei. Beim nächsten Aufruf prüft es welche Ereignisse bereits in der Datei enthalten sind und hängt neue Ereignisse am Ende der Datei an.
Dies kann man per cron auch regelmäßig automatisch erledigen lassen.

### Los geht's
mit
- einem Benutzerkonto auf der FRITZ!Box mit der Berechtigung die Konfiguration zu lesen (welche leider auch die Schreibberechtigung beinhaltet). Empfohlen sei ein eigenes Konto für diesen Zweck das zudem mit einem guten[^1]  Kennwort gesichert sein sollte.
[^1]: Ich schlage einen Mix aus Nummern, Groß- und Kleinbuchstaben und den Zeichen `+-=?~.:` vor, bei einer Länge von mindestens 20 Zeichen.

- einem Verzeichnis in welchem die Ereignis-Dateien gespeichert werden sollen. Die Voreinstellung ist "`fblogs`" im Heimatverzeichnis des Nutzers (das ist mit `mkdir ~/fblogs` gleich getan to). Wer einen anderen Speicherort bevorzugt, kann die Option `-d` verwenden.

### Ignorierte Ereignisse
Das Holen der Ereignisse erzeugt seinerseits ein
Login-Ereignis, das Skript ignoriert daher alle Login-Ereignisse des zum Download benutzten Kontos. Deswegen empfiehlt sich ein eigenes Konto für das Skript. Wer jedoch **alle** Ereignisse speichern möchte (auch die o. g. Logins), kann die Option -D oder --do-not-filter verwenden.
 
 ### Kommando Optionen
 Diese lassen sich mit `-h` bzw. `--help` anzeigen:
 ```
 Usage:
  updfblog [option[,option...]]
  -b --box <hostname or IP of FRITZ!Box>
  -c --creds <storefile> containg the credentials
          by default ~/.updfblog.data is checked
          overrides -u
  -C --save-credentials [<storefile>]
          store credentials in file
          can be used together with -c
          default storefile is ~/.updfblog.data
          storing passwords in a file is potentially
          unsafe!
  -d --dir <directory-to-hold-logfiles>
  -D --do-not-filter
          do not filter logins of the user used
          to log in this script
  -h --help (shows this text)
  -n --name <file-basename> (of logfile, default:fblog)
  -p --pass <name> can be
          a) environment variable
          b) a named pipe
          c) an executable file
          that holds or delivers the password
          of the FRITZ!Box user
  -u --user <username> (of FRITZ!Box-user)
  -v --version  report own version number
  ```

## Wo gibt es das Skript?
Es steht zum Download  [hier](https://raw.githubusercontent.com/Benno-K/PublicScripts/refs/heads/main/friedl) bereit.

## Verwendete Umgebung
### Zur Entwicklung
|Computer||
|--------|------|
|Device |Raspberry Pi Model B Rev. 1.1| 
|OS        |Raspbian GNU/Linux 12 (bookworm)|
|Box      |FRITZ!Box 7590|
|Box OS|FRITZ!OS 8.02|

### Getestet unter

|Computer||
|--------|------|
|Device |Raspberry Pi Model B Rev. 1.1| 
|OS        |Raspbian GNU/Linux 12 (bookworm)|
|Box      |FRITZ!Box 7590|
|Box OS|FRITZ!OS 8.02|

<br/>

|Smartphone||
|---------|----|
|Device   |Samsung Galaxy S24 Ultra|
|Model No.|SM-S928B/DS|
|OS          | Android 14 (Samsung UI 6.1)
|kernel    | 6.1.75-android14-11-29543898-abS928BXXS4AXKA|
|App         |Termux 0.118.2[^2]|
|Box      |FRITZ!Box 7590|
|Box OS|FRITZ!OS 8.02|

Ich überlege, das Skript auch unter Windows 11 per WSL (Windows subsystem for Linux) mit Debian Linux (12, bookworm) zu testen.

[^2]: Termux erschließt die Möglichkeiten des Android Betriebsystems für die Kommandozeile, beispielsweise das Nutzen von Skripten wie diesem. Termux läuft auf allen modernen Android-Systemen, es benötigt **keinerlei** root-Rechte. Siehe unter [https://termux.dev/](https://termux.dev/)

#### Kontact 
Am liebsten per github (Benno-K). Wer dort kein Konto hat, kann auch Mail an `benno (at-sign) xyz .de` senden.
