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

[^chat]: Nachdem ich tagelang gerungen und sehr viele Kombinationen probiert habe  war am Ende sogar mein - durchaus nicht um Lösungen verlegener - Sparring-Partner (ChatGPT) davon überzeugt, dass es keine Standard-Lösung für dieses Problem gibt. Denn auch keiner der dort empfohlenen Wege erwies sich als gangbar. Aber immerhin lehrreich waren diese Irrwege.

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

> Entscheidend hier:
Den ursprünglichen Dovecot-Delivery-Agent
**```/usr/lib/dovecot/dovecot-lda```**
mit
**```/usr/local/bin/dovecot-lda-wrapper```**
ersetzen!

---

### Wrapper-Skript

Die aktuelle Version befindet sich unter [Github -> Benno-K-> PublicScripts](https://github.com/Benno-K/PublicScripts/) als [dovecot-lda-wrapper](https://github.com/Benno-K/PublicScripts/blob/main/dovecot-lda-wrapper). Das Script befindet sich dort im 
[aktuellen Release](https://github.com/Benno-K/PublicScripts/releases/latest).

Zum Download empfehle ich:
```sh
curl -s https://api.github.com/repos/Benno-K/PublicScripts/releases/latest | jq -r '.zipball_url' | xargs -r curl -L 2>/dev/null | unzip -p - '*/dovecot-lda-wrapper' > dovecot-lda-wrapper
```

Beispielcode[^basename], unterscheidet sich geringfügig vom aktuellen Release.
[^basename]: ```me=${0##*/}``` ??? Nun, dieses POSIX-Konstrukt ```${0##*/}```  erfüllt dieselbe Aufgabe wie ```$(basename $0)```, nur durch Variablen-Substitution und ohne Kommando-Ausführung in einer Subshell. Übrigens: Statt ```dirname $0```  geht auch ```${0%/*}```. Neugierig, was da noch alles geht:
unter
[https://tldp.org/LDP/abs/html/parameter-substitution.html](https://tldp.org/LDP/abs/html/parameter-substitution.html) gibt's noch viel mehr.
```bash
#!/bin/bash
# Wrapper around Dovecot LDA
# decides Inbox or Junk based on mail content

set -eou pipefail
# -e : exit immediately on error
# -u : treat unset variables as an error
# -o pipefail : fail if any command in a pipeline fails

lda=/usr/lib/dovecot/dovecot-lda
reFil=/etc/dovecot/mboxrules
me=${0##*/}

tmp="$(mktemp /tmp/${me}.XXXXXX)" || exit 75
cleanup() {
  [ -e "$tmp" ] && rm -f "$tmp"
}
trap cleanup EXIT HUP INT TERM

# Preserve full message
cat > "$tmp"

while IFS= read -r reLine; do
  regexp=${reLine%% *}
  suffix=${reLine#* }
  if grep -Eq "$regexp" "$tmp"; then
    opts+="$suffix "
  fi
done < "$reFil"

if [ -n "$opts" ]; then
  logger -p mail.info "$(date +%Y-%m-%dT%H:%M:%S.%6N%:z) $me: added \"${opts% }\" to lda-command"
fi

$lda $opts "$@" <"$tmp"
exit $?
```

---

### Regeldatei

Pfad: `/etc/dovecot/mboxrules`

Beispiel:

```config
^X-Spam-Status:[[:space:]]*Y[eE][sS] -m Junk
```

**Format:**
```
<REGEX><space><lda-option>
```
- Regex **ohne** Leerzeichen (oder mit `[[:space:]]`) 
- LDA-Option wird direkt ergänzt (z. B. `-m Junk`)
- Mehrere Regeln möglich, letzte passende Option gewinnt

Wer diesen Einzeiler nicht selbst anlegen will,  könnte ihn aus dem Release herunterladen:
```sh
curl -s https://api.github.com/repos/Benno-K/PublicScripts/releases/latest | jq -r '.zipball_url' | xargs -r curl -L 2>/dev/null | unzip -p - '*/mboxrules' > mboxrules
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

> Empfehlung: Für dieses Setup Dovecot **2.3** verwenden oder Wrapper-Lösung strikt beibehalten.

---

### Fazit

- Spam-Sortierung mit Dovecot 2.4 ist möglich **nur mit externem Wrapper**.
- Wrapper übernimmt Policy, Dovecot übernimmt reine Zustellung.
- Keine Reinjektion, keine Sieve-Regeln notwendig.
- Vollständig transparent, reproduzierbar, wartbar.

> **Delivery-Policy vor Dovecot, Zustellung durch Dovecot.**

