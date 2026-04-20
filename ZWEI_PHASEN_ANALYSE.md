# Analyse-Stand: ZWEI_PHASEN-Branch im E-Projekt

**Angelegt:** 2026-04-19
**Kontext:** Während der Arbeit am Branch `ZWEI_PHASEN` in
`E:/Projekte/CTE/ITSQ.Testfaelle/` ist der Konsistenztest
`cte.testfaelle.consistency.RefExportsConsistencyTest.testCheckTestCrefoConsistency`
rot gelaufen. Diese Notiz hält den Erkenntnisstand fest, damit die Analyse
später in Ruhe fortgesetzt werden kann.

**Wichtiger Hinweis:** Diese Datei liegt bewusst im **D-Projekt**
(`D:/ClaudeCode/ITSQ-Testfaelle/`) und nicht im E-Projekt. Das E-Projekt ist
auf den Originalzustand zurückgesetzt (siehe §6).

---

## 1. Ausgangspunkt

- E-Projekt: `E:/Projekte/CTE/ITSQ.Testfaelle/` (Branch `ZWEI_PHASEN`).
- Die **Konsistenz-Prüflogik** wurde vom D-Projekt (hier) ins E-Projekt portiert.
- Beim ersten Test-Lauf im E-Projekt schlägt genau ein Test mit
  **89 Assertion-Meldungen** fehl; alle anderen Tests sind grün.

Beispiel-Meldungen:
```
Zu Phase-1-P-Testfall 4112008242 fehlt ein X-Testfall in Phase-2 für Kunde BDR!
Zu Phase-1-P-Testfall 9110189333 fehlt ein X-Testfall in Phase-2 für Kunde BDR!
...
```

## 2. Logik-Vergleich D- vs. E-Projekt

Diff mit `diff -w` (ignoriert Whitespace):

| Datei | Diff |
|---|---|
| `itsq/src/test/java/cte/testfaelle/consistency/TestSetData.java` | **identisch** |
| `itsq/src/test/java/cte/testfaelle/consistency/RefExportsConsistencyTest.java` | **identisch** |
| `itsq/src/main/java/cte/testfaelle/domain/TestScenario.java` | **identisch** |
| `itsq/src/main/java/cte/testfaelle/domain/TestCustomer.java` | **identisch** |
| `itsq/src/main/java/cte/testfaelle/domain/TestCrefo.java` | **identisch** |

**⇒ Die Prüf-Logik ist zwischen beiden Projekten zu 100 % identisch.**
Nur Whitespace/Indentation weicht ab.

## 3. Daten-Unterschied D- vs. E-Projekt

- D-Projekt hat **3 Test-Kunden** (`c01`, `c02`, `c05`) mit minimalen Testdaten.
- E-Projekt hat **16 Phase-1-Kunden und 30 Phase-2-Kunden** mit produktiven,
  historisch gewachsenen Daten (BDR, BVD, CEF, CRM, CTC, DFO, EH, FOO, FSU,
  FW, IKA, INSO_TEST-TOOL, PNI, SDF_DAILY, TRDI, ZEW in Phase-1; zusätzlich
  BIC, DNP, DRD, GDL, INSO_KUNDENPLZ, ISM, MIC, MIP, NIM, PPA, RTN, VSD, VSH,
  VSO nur in Phase-2).

**Beispiel D-Projekt (`c01/Relevanz_Positiv/Positive.properties`):**

Phase-1:
```
p001=1234567890
p002=1234567891
```

Phase-2:
```
p001=1234567892   # andere Crefo-Nr als in P1
x002=1234567891   # Löschsatz zu p002 aus P1
```

Hier passt die Logik perfekt: die in P1 als `p002` aktive Crefo `1234567891`
wird in P2 zum Löschsatz `x002`.

**Beispiel E-Projekt (`bdr/BDR_Beteiligte_Adr/BDR_Beteiligte_Adr.properties`):**

Phase-1 enthält u.a. `p024_07=4102008242` mit Kommentar
*"… p024_07 ist relevant in Phase 1 und Phase 2 …"*.

Phase-2 enthält **ebenfalls** `p024_07=4102008242` mit demselben Kommentar —
also **nicht** als Löschsatz, sondern weiter aktiv.

**⇒ Die Daten-Konvention im E-Projekt lässt zu, dass eine Crefo in beiden
Phasen als aktiver P-Fall existiert. Die aus dem D-Projekt portierte Logik
macht diese Annahme nicht.**

## 4. Die strittige Regel

`TestSetData.checkTestCrefoConsistency`, Zeile 131–135:

```java
// Zu jedem Phase-1-P-Fall muss ein Phase-2-X-Fall desselben Kunden existieren
if (testCrefoPhase2 == null || !testCrefoPhase2.getTestFallName().startsWith("x")) {
    String errMsg = "Zu Phase-1-P-Testfall " + testCrefoPhase1.getItsqTestCrefoNr()
            + " fehlt ein X-Testfall in Phase-2 für Kunde "
            + testCustomerPhase1.getCustomerKey() + "!";
    consistencyCheckResult.addAssertion(errMsg);
}
```

Die Regel sagt wörtlich: **"Jede Phase-1-P-Crefo muss in Phase-2 als
X-Löschsatz erscheinen."**

Das passt zur D-Projekt-Konvention, aber nicht zur E-Projekt-Datenrealität.

## 5. Zwischenlauf (verworfen)

Als Versuch wurde im E-Projekt ein Rename-Skript gebaut, das alle 89
betroffenen Einträge von `p…` auf `x…` umbenannt hat (Properties-Keys +
XML-Dateinamen). Die 8 Tests wurden danach grün.

**ABER:** Das Rename hat die fachliche Semantik verfälscht. Crefos, die in
beiden Phasen bewusst als aktive P-Fälle modelliert sind (z.B. *"… ist
relevant in Phase 1 und Phase 2 …"*), wurden zu Löschsätzen umdeklariert.
Das ist inhaltlich falsch.

Dieser Zwischenstand wurde **verworfen** (siehe §6).

## 6. Rollback

```
git checkout -- test_set/REF-EXPORTS/PHASE-2/
git clean -f   test_set/REF-EXPORTS/PHASE-2/
```

Das E-Projekt ist damit im Originalzustand (keine Working-Copy-Änderungen,
keine neuen Dateien). Bestätigt über `git status --short` → leer.

## 7. Noch im E-Projekt verbliebene Hilfsartefakte

Unter `E:/Projekte/CTE/ITSQ.Testfaelle/target/` (target ist nicht unter
Versionskontrolle — darf bedenkenlos gelöscht werden):

- `gap_analysis.py` — Lückenübersicht
- `gap_details.py` / `gap_details_report.txt` — detaillierter Review-Report
- `apply_renames.py` / `dryrun.log` / `apply.log` — Rename-Skript und Logs
- `zwei_phasen_rename_review.md` — Review-Dokumentation (auf Basis der
  verworfenen Interpretation)

Keines dieser Artefakte berührt versionierte Dateien.

## 8. Aktuell implementierte Regeln (vollständig)

Aus `TestSetData.checkTestCrefoConsistency` (Zeilen 106–177).

### Präfixe / Testfall-Typen
- `p` = Positiv-Testfall (aktiver Export)
- `n` = Negativ-Testfall (Export ausdrücklich nicht)
- `x` = Löschsatz-Companion

### Phase-1-Regeln (Zeilen 110–138)

| ID | Regel | Code-Zeile |
|---|---|---|
| **P1-R1** | Phase-1 darf nur P-Fälle enthalten (keine n, keine x). | 118 |
| **P1-R2** | Jeder Phase-1-P-Fall muss eine REF-XML haben. | 123 |
| **P1-R3** | Jeder Phase-1-P-Fall muss eine AB30-XML haben. | 127 |
| **P1-R4** | Zu jedem Phase-1-P-Fall muss in Phase-2 ein **X-Fall** (gleiche Crefo-Nr, gleicher Kunde) existieren. | 132 |

### Phase-2-Regeln (Zeilen 140–175)

| ID | Regel | Code-Zeile |
|---|---|---|
| **P2-R1** | Jeder Phase-2-Fall (p/n/x) muss in ARCHIV-BESTAND/PHASE-2 eine AB30-XML haben. | 147 |
| **P2-R2** | Phase-2-P-Fall muss eine REF-XML haben. | 151 |
| **P2-R3** | Phase-2-N-Fall darf **keine** REF-XML haben. | 157 |
| **P2-R4** | Zu jedem Phase-2-X-Fall muss in Phase-1 ein P-Fall (gleiche Crefo-Nr, gleicher Kunde) existieren. | 163 |

### NICHT geprüft (Lücke)

- Pro Kunde: Crefo-Nr-Zweck-Eindeutigkeit über alle Scenarios / beide Phasen hinweg.
- Eine Crefo darf theoretisch aktuell in Scenario A als `p…`, in Scenario B
  desselben Kunden als `n…` oder `x…` auftreten.

## 9. Offene Punkte / noch zu klären

Der User hat in der Diskussion zwei Regeländerungen vorgeschlagen:

### Vorschlag P1-R4 (überarbeitet)

> "Zu jedem Phase-1-P-Fall muss in Phase-2 ein **X-Fall ODER ein N-Fall**
> (gleiche Crefo-Nr, gleicher Kunde) existieren."

Begründung des Users: *"Ich könnte einen Testfall generieren, der in P1
exportiert, in P2 aber nicht mehr."*

### Vorschlag P2-R5 (neu)

> "Innerhalb eines Kunden darf eine Crefo niemals unterschiedlichen Zweck
> haben — ein Zweck pro Crefo pro Kunde in beiden Phasen."

### Konflikt

Beide Vorschläge kollidieren in folgendem Szenario:

| Fall | Phase-1 | Phase-2 | P1-R4 (neu) | P2-R5 (neu, strikt) |
|---|---|---|---|---|
| 1 | `p024_01=C` | nichts | ❌ Fehler | ✅ ok |
| 2 | `p024_01=C` | `p024_01=C` | ❓ Fehler (P ist weder X noch N)? | ✅ ok |
| 3 | `p024_01=C` | `x024_01=C` | ✅ ok | ❌ Fehler (P in P1, X in P2 = 2 Zwecke) |
| 4 | `p024_01=C` | `n024_01=C` | ✅ ok | ❌ Fehler (P in P1, N in P2 = 2 Zwecke) |

Zwei mögliche Interpretationen:

- **(A)** "Ein Zweck pro Crefo" gilt nur **innerhalb einer Phase**, darf aber
  zwischen Phase-1 und Phase-2 wechseln (P→P, P→X, P→N alle erlaubt). Diese
  Interpretation ist mit der User-Aussage "P1 exportiert, P2 nicht mehr"
  kompatibel und lässt die E-Projekt-Daten legal erscheinen.
- **(B)** "Ein Zweck pro Crefo" gilt **strikt über beide Phasen hinweg**.
  Dann wäre P1-P → P2-X oder P2-N regelwidrig, was dem User-Zitat
  widerspricht.

**Empfehlung:** Interpretation (A). Bestätigung durch User noch ausstehend.

## 10. Was als nächstes zu tun wäre

Sobald Interpretation (A) oder (B) bestätigt ist:

1. `TestSetData.checkTestCrefoConsistency` entsprechend anpassen — sowohl
   D- als auch E-Projekt halten dieselbe Logik, daher Pflege an zentraler
   Stelle erwünscht.
2. Neue Regel P2-R5 (Zweck-Eindeutigkeit pro Crefo pro Kunde) ergänzen,
   entweder als zusätzliche Methode in `TestSetData` oder als separater
   `@Test` in `RefExportsConsistencyTest`.
3. Im E-Projekt: Tests laufen lassen, ohne Daten anzufassen. Die 89
   bisherigen Fehler sollten dann automatisch verschwinden (weil P-in-P2
   als legaler Fall anerkannt wird).
4. Ins D-Projekt die angepasste Logik übernehmen und bestehende
   Testdaten-Konvention (P→X-Löschsatz in den kleinen c01/c02-Beispielen)
   prüfen, ob sie weiterhin konsistent ist.

## 11. Referenzen

- E-Projekt-Zweig: `ZWEI_PHASEN`
- D-Projekt-Version der Logik: `itsq/src/test/java/cte/testfaelle/consistency/TestSetData.java`
- Beispiel für D-Daten: `test_set/REF-EXPORTS/PHASE-1/c01/Relevanz_Positiv/Positive.properties`
  und Phase-2-Pendant.

---

## 12. Zwei weitere Failures sichtbar (Test-Lauf 2026-04-20)

### Kontext

Beim ersten Test-Lauf (2026-04-19) war der Surefire-Fork durch eine
Boot-Manifest-JAR-Inkompatibilität teilweise abgebrochen (`java.lang.UnsupportedClassVersionError`
— das Projekt war für JDK 11 kompiliert, aber der Fork wurde mit Java 8
gestartet). Deshalb zeigte der ursprüngliche Report nur **1 Failure**
(`testCheckTestCrefoConsistency`).

Nach Umstellung des IntelliJ-Project-SDK von JDK 26 auf JDK 11 laufen die
Tests mit JDK 11 durch. Jetzt sind **3 Failures** sichtbar:

| # | Testmethode | Meldungen | Art |
|---|---|---:|---|
| 1 | `testCheckTestCrefoConsistency` | 89 | bekannte P1-R4-Diskussion |
| 2 | `testCheckTestCrefosPropertiesVsRefExportsPhase1` | 61 | **neu sichtbar** |
| 3 | `testCheckTestCrefosPropertiesVsRefExportsPhase2` | 108 | **neu sichtbar** |

Die 5 verbleibenden Checks (`testRefExportXmlToTestFaelleConsistency`,
`testCheckClzAndExportTypConsistency`, `testCheckEignerClzConsistencyPhase1/2`,
`testCheckArchivBestandPhase1SubsetOfPhase2`) sind grün.

### 12.1 Logik hinter den neuen Failures

Quelle: `TestSetData.checkTestCrefosPropertiesVsRefExports`
(Datei `itsq/src/test/java/cte/testfaelle/consistency/TestSetData.java`,
Zeilen 259–325).

Die Methode wird pro Phase aufgerufen und prüft **bidirektional** den
Abgleich zwischen
`ARCHIV-BESTAND/PHASE-<n>/TestCrefos.properties` (Quelle) und den Testfällen
unter `REF-EXPORTS/PHASE-<n>/<kunde>/<scenario>/<scenario>.properties`.

#### Vorbereitung (Zeilen 270–277)

```java
Set<Long> btlgOnlyCrefos = new HashSet<>();
for (AB30XMLProperties props : propsMap.values()) {
    btlgOnlyCrefos.addAll(props.getBtlgCrefosList());
}
propsMap.values().stream()
        .filter(p -> !p.getUsedByCustomersList().isEmpty())
        .forEach(p -> btlgOnlyCrefos.remove(p.getCrefoNr()));
```

Eine Crefo gilt als "Beteiligten-only", wenn sie ausschließlich als Beteiligter
eines anderen Eintrags auftritt und selbst keinen eigenen Kunden-Eintrag in
`TestCrefos.properties` hat. Für diese Crefos wird kein eigener Testfall
erwartet → sie werden aus den Prüfungen ausgenommen.

#### Richtung 1: `[ARCHIV→REF]` (Zeilen 282–303)

Pro Crefo-Eintrag in `TestCrefos.properties` und pro dort gelistetem Kunden:

- **Fehler A (Kunde unbekannt):** Der Kunde existiert in der `customerMap` der
  jeweiligen Phase gar nicht.
  ```
  [ARCHIV→REF] Crefo <nr>: Kunde '<key>' in TestCrefos.properties nicht in
  REF-EXPORTS/<phase> definiert!
  ```
- **Fehler B (Kunde existiert, aber keinen Testfall für diese Crefo):** Der
  Kunde hat zwar Scenarios, aber in keinem taucht die Crefo-Nr auf.
  ```
  [ARCHIV→REF] Crefo <nr> ist in TestCrefos.properties/<phase> als Kunde '<key>'
  eingetragen, aber in REF-EXPORTS hat <key> keinen Testfall für diese Crefo!
  ```
- Alle drei Testfall-Typen (p, n, x) werden als gültiger Treffer gewertet.

#### Richtung 2: `[REF→ARCHIV]` (Zeilen 307–323)

Pro Testfall in REF-EXPORTS/<phase>/<kunde>/<scenario>:

- **Fehler C (Crefo nicht in TestCrefos.properties):**
  ```
  [REF→ARCHIV] Crefo <nr> (Testfall '<name>', Kunde <key>) fehlt komplett in
  TestCrefos.properties/<phase>!
  ```
- **Fehler D (Kunde nicht in UsedByCustomers-Liste):**
  ```
  [REF→ARCHIV] Crefo <nr> hat in REF-EXPORTS/<phase> Testfall '<name>' für
  Kunde '<key>', aber in TestCrefos.properties fehlt dieser Kunde!
  ```

### 12.2 Zahlen

| Metrik | Phase-1 | Phase-2 | Gesamt |
|---|---:|---:|---:|
| `[ARCHIV→REF]` Meldungen | 33 | 72 | **105** |
| `[REF→ARCHIV]` Meldungen | 28 | 36 | **64** |
| **Summe Meldungen** | **61** | **108** | **169** |

Betroffene Kunden (aus den Meldungen extrahiert, 24 insgesamt):
`ATF, BDR, BIC, BVD, CEF, CRM, CTC, DFO, EH, FOO, FSU, FW, GDL,
INSO_KUNDENPLZ, INSO_TEST-TOOL, LEN, MIC, PNI, SDF_DAILY, TRDI, VSD, VSH,
VSO, ZEW`.

Zwei Kunden sind **unbekannt** auf REF-EXPORTS-Seite in der jeweiligen Phase:
- `INSO_KUNDENPLZ` (Phase-1) — taucht in `TestCrefos.properties/PHASE-1` auf,
  hat aber keinen Ordner unter `REF-EXPORTS/PHASE-1/`.
- `LEN` (Phase-2) — analog in Phase-2.

### 12.3 Vollständige Meldungslisten

Die kompletten Failure-Listen (Crefo-Nr, Testfall, Kunde) stehen im Surefire-Report:
```
E:/Projekte/CTE/ITSQ.Testfaelle/itsq/target/surefire-reports/
    cte.testfaelle.consistency.RefExportsConsistencyTest.txt
```

Pfadbezug:
- `testCheckTestCrefosPropertiesVsRefExportsPhase1`: Zeilen 5–97 im Report
  (Aufruf-Quelle: `RefExportsConsistencyTest.java:72`).
- `testCheckTestCrefosPropertiesVsRefExportsPhase2`: Zeilen 99–238 im Report
  (Aufruf-Quelle: `RefExportsConsistencyTest.java:82`).

### 12.4 Beispiel-Cluster (zur Einordnung, keine Wertung)

Nur zur groben Orientierung, **ohne inhaltliche Analyse**:

- Viele `[ARCHIV→REF]`-Meldungen in Phase-1 beziehen sich auf Crefos, die in
  `TestCrefos.properties` unter **mehreren** Kunden eingetragen sind (z.B.
  `4110057093` unter `CRM`, `BVD`, `BDR`). Die Prüfung verlangt, dass jeder
  dort gelistete Kunde einen eigenen Testfall für die Crefo hat.
- Viele `[REF→ARCHIV]`-Meldungen betreffen Kunden, die in `TestCrefos.properties`
  überhaupt nicht erwähnt sind (z.B. `ATF`, `TRDI` mit vielen `n…`-Testfällen,
  `BIC` mit `n1`, `FSU` mit `n007_20`).
- In Phase-2 fällt **`4102001324`** (TRDI) auf, das in 12 Kunden eingetragen
  ist, aber nirgendwo einen Testfall hat — das könnte ein systematischer
  Befund sein (bewusst noch nicht weiter interpretiert).

### 12.5 Bestandsaufnahme-Status

- Die Logik von `checkTestCrefosPropertiesVsRefExports` ist zwischen D- und
  E-Projekt **ebenfalls identisch** (aus §2 bereits belegt — die gesamte Datei
  `TestSetData.java` unterscheidet sich nur in Whitespace).
- Die neuen Failures wurden **nicht** durch die vorherigen Experimente im
  E-Projekt verursacht. Alle Renames sind zurückgerollt, Working Copy ist
  sauber (`git status --short` leer).
- Diese Sektion ist **reine Bestandsaufnahme**. Keine Handlungsempfehlung,
  keine Daten-Änderungen, keine Logik-Änderungen. Offen für die spätere
  Analyse durch den User.
