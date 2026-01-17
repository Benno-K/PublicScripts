# dovecot-lda-wrapper

## Postfix + SpamAssassin + Dovecot 2.4 – Zustellung mit Wrapper

### Ziel
Spam-Mails zuverlässig anhand von SpamAssassin-Headern in **Junk** zustellen, legitime Mails in **INBOX** – **ohne** Reinjektion, **ohne** Sieve, **ohne** LMTP-Probleme.

Dieses Dokument beschreibt einen **produktiven Ansatz**, der auch mit **Dovecot 2.4** funktioniert, obwohl die offiziellen Bordmittel dafür nicht mehr ausreichen.

---

### Hintergrund / Problemstellung

Mit **Dovecot 2.4** gilt:

- `dovecot-lda` ist deprecated
- empfohlener Zustellweg ist LMTP
- Spam-Entscheidungen sollen laut Doku via Sieve erfolgen

In der Praxis scheitert das klassische Setup jedoch:

- `spamc -e` ist **nicht LMTP-fähig**
- LMTP + Sieve wären möglich, liefen jedoch leider **vor** der Spamerkennung, daher ..
- Sieve kann SpamAssassin-Header auswerten
- Postfix FILTER wären eine elegante Lösung nur leider laufen die Filter **vor** spamassassin
- lokale aliases (/etc/aliases) auf virtuelle dovecot-Nutzer sind zur Filterlaufzeit noch nicht substituiert

➡ Ergebnis: **Mit Bordmitteln ist „Spam → Junk“ nicht stabil lösbar.**[^chat]

[^chat]: Nachdem ich mehrere Tage gerungen und sehr viele Kombinationen probiert habe, war am Ende sogar mein - durchaus nicht um Lösungen verlegener - Sparring-Partner ChatGPT davon überzeugt, dass es keine Standard-Lösung für dieses Problem gibt. Keine der vielen, im Laufe der tagelangen Sitzung vorgeschlagenen, Lösungen erwies sich letztlich als brauchbar. Aber es war lehrreich.

--

### Lösungskonzept

Die Entscheidung *wohin* eine Mail zugestellt wird, erfolgt **vor** Dovecot, aber **nach** SpamAssassin – durch einen **Wrapper**.

#### Architektur

```
  → spamassassin_virtual (pipe)
     → spamc
        → dovecot-lda-wrapper
           → dovecot-lda -m Junk | INBOX
```

#### Eigenschaften

- ✔ keine Reinjektion
- ✔ kein Postfix-Filter
- ✔ kein Sieve
- ✔ keine LMTP-Abhängigkeit
- ✔ volle Kontrolle & Logging

---

### Postfix-Konfiguration (relevanter Teil)

#### master.cf

```text
spamassassin_virtual unix - n n - - pipe
  flags=Rq
  user=vmail
  argv=/usr/bin/spamc -e /usr/local/bin/dovecot-lda-wrapper -f ${sender} -d ${user}
```

>**Entscheidend hier**:<br/>
Den ursprünglichen Dovecot-Delivery-Agent<br/>
**```/usr/lib/dovecot/dovecot-lda```**
mit
**```/usr/local/bin/dovecot-lda-wrapper```** ersetzen!

---

### Wrapper-Skript
Die aktuelle Version befindet sich unter 
- [Github -> Benno-K-> PublicScripts](https://github.com/Benno-K/PublicScripts/) als
- [dovecot-lda-wrapper](https://github.com/Benno-K/PublicScripts/blob/main/dovecot-lda-wrapper).
 <br/>Das Script befindet sich dort im 
- [aktuellen Release](https://github.com/Benno-K/PublicScripts/releases/latest).

Zum Download empfehle ich:
```sh
curl -s https://api.github.com/repos/Benno-K/PublicScripts/releases/latest | jq -r '.zipball_url' | xargs -r curl -L 2>/dev/null | unzip -p - '*/dovecot-lda-wrapper' > dovecot-lda-wrapper
```
(so kompliziert ist das Kommando, weil gezielt ein Script aus der ganzen Sammlung extrahiert wird)

#### Beispielcode
(unterscheidet sich vom aktuellen Release)[^basename].
[^basename]: Fragen zu "```me=${0##*/}```" ???<br/> Nun, das POSIX-Konstrukt ```${0##*/}```  erfüllt dieselbe Aufgabe wie ```$(basename $0)```, nur durch Variablen-Substitution und ohne Kommando-Ausführung in einer Subshell. Übrigens: Statt ```dirname $0```  geht auch ```${0%/*}```. Neugierig, was da noch alles geht:
unter
[https://tldp.org/LDP/abs/html/parameter-substitution.html](https://tldp.org/LDP/abs/html/parameter-substitution.html) gibt's noch viel mehr.
```bash
#!/bin/bash
#
# Wrapper für Dovecot LDA
#  entscheidet Inbox oder Junk (bei Spam)
#  Steuerung über Regeldatei
#  Format: Regex + Space + LDA-Option
#  Regex darf keine Leerzeichen enthalten
#  (außer explizit als [[:space:]])
#  Beispiel:
#   ^X-Spam-Status:[[:space:]]*Y[eE][sS] -m Junk
#  fügt "-m Junk" zum lda-Befehl hinzu
#
# Vorteile:
#  Keine Reinjektion
#  Keine Postfix-Filter
#  Kein Sieve
# Nachteil:
#  Mail wird temporär kopiert

set -uo pipefail
# -u: Fehler bei ungesetzten Variablen
# -o pipefail: Fehler bei Pipeline-Fehlern

# Dovecot LDA
lda=/usr/lib/dovecot/dovecot-lda

# Regeldatei (Regex → LDA-Option)
reFil=/etc/dovecot/mboxrules

# Skriptname (POSIX-kompatibel)
me=${0##*/}

# Fehlende Regeldatei melden und Skript beenden
if [ ! -e "$reFil" ]; then
    msg="missing rule file $reFil"
    logger -p mail.info "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: $msg"
    echo >&2 "$msg"
    exit 1
fi

# Temporäre Datei für Mailinhalt
tmp="$(mktemp /tmp/${me}.XXXXXX)" || exit 75

cleanup() {
    [ -e "$tmp" ] && rm -f "$tmp"
}
trap cleanup EXIT HUP INT TERM

# Mail vollständig sichern
cat > "$tmp"

# Regeln auswerten
opts=
lc=0
while IFS= read -r reLine; do
    regexp=${reLine%% *}
    suffix=${reLine#* }
    lc=$((lc+1))

    if grep -Eq "$regexp" "$tmp"; then
        opts+="$suffix "
    else
        [ $? = 2 ] && logger -p mail.info \
            "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: error in regexp \"$regexp\" in line $lc of $reFil"
    fi
done < "$reFil"

[ -n "$opts" ] && logger -p mail.info \
    "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: added \"${opts%* }\" to lda-command"

# Nicht per exec aufrufen, sonst wird tmp vorzeitig gelöscht
# $lda $opts "$@" <"$tmp"

exit

# Autor: Benno K.
# GPL V3
##
set -uo pipefail
# -u: Fehler bei ungesetzten Variablen
# -o pipefail: Fehler bei Pipeline-Fehlern

# Dovecot LDA
lda=/usr/lib/dovecot/dovecot-lda

# Regeldatei (Regex → LDA-Option)
reFil=/etc/dovecot/mboxrules

# Skriptname (POSIX-kompatibel)
me=${0##*/}

# Die Datei mit den Regeln muss existieren
if [ ! -e "$reFil" ]; then
    msg="missing rule file $reFil"
    logger -p mail.info "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: $msg"
    echo >&2 "$msg"
    exit 1
fi

# Temporäre Datei für Mailinhalt
tmp="$(mktemp /tmp/${me}.XXXXXX)" || exit 75

# Aufräumfunktion - definieren und etablieren
cleanup() {
    [ -e "$tmp" ] && rm -f "$tmp"
}
trap cleanup EXIT HUP INT TERM

# Mail vollständig sichern (stdin)
cat > "$tmp"

# Regeln auswerten
opts=
lc=0
while IFS= read -r reLine; do
    regexp=${reLine%% *}
    suffix=${reLine#* }
    lc=$((lc+1))
    # Auf Übereinstimmung prüfen
    if grep -Eq "$regexp" "$tmp"; then
        opts+="$suffix "
    else
        # Bei Fehler in der Regel: Logmeldung
        [ $? = 2 ] && logger -p mail.info \
            "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: error in regexp \"$regexp\" in line $lc of $reFil"
    fi
done < "$reFil"

# Logmrldung wenn lda-Optionen gefunden
[ -n "$opts" ] && logger -p mail.info \
    "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: added \"${opts%* }\" to lda-command"

# original lda starten
# (Nicht per exec aufrufen, sonst wird tmp vorzeitig gelöscht)
$lda $opts "$@" <"$tmp"
# exit führt cleanup durch
exit
```
> Das ist dann aber leider mehr zu tippen ;-)

---

### Logging / Debugging

- Wrapper loggt über `logger -p mail.info`
- Zeitstempel ISO-8601 mit Mikrosekunden
- Testbar z. B. mit GTUBE-Mails

Beispiel:
```text
dovecot-lda-wrapper: added "-m Junk" to lda-command
```

---

### Unterschiede Dovecot 2.3 vs 2.4

| Feature | Dovecot 2.3 | Dovecot 2.4 |
|---------|------------|-------------|
| LDA | voll funktionsfähig | deprecated, nur noch Legacy |
| LMTP | optional | bevorzugt, stabil |
| Spam-Sortierung ohne Sieve | möglich | nur über Wrapper / externe Lösung |
| Sieve-Abhängigkeit | optional | offiziell empfohlen |

---

### Fazit

- Spam-Sortierung mit Dovecot 2.4 ist möglich **nur mit externem Wrapper**.
- Wrapper übernimmt Policy, Dovecot übernimmt reine Zustellung.
- Keine Reinjektion, keine Sieve-Regeln notwendig.
- Vollständig transparent, reproduzierbar, wartbar.

> **Delivery-Policy vor Dovecot, Zustellung durch Dovecot.**

