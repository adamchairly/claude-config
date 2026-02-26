---
name: ask
description: Strukturált kérdés–válasz (világos, célzott, kontextushoz illeszkedő válasz)
disable-model-invocation: false
allowed-tools: Read, Glob, Grep, Task
argument-hint: "kérdés [context] [depth: short|normal|deep]"
---

# /ask – Strukturált kérdés–válasz

Egy konkrét kérdésre világos, célzott, kontextushoz illeszkedő választ ad – anélkül, hogy feleslegesen tervezne, review-ba csúszna, vagy új feature-öket találna ki.

Ez a slash a „mondd meg, amit most tudni akarok" eszköz.

---

## Purpose

- Világos, célzott válasz egyetlen konkrét kérdésre
- Kontextushoz illeszkedő mélység
- Nem tervez, nem refaktorál, nem ötletel – hacsak nem kérik

---

## Mikor használd

- Technikai kérdés (mi a különbség X és Y között?)
- Viselkedés-kérdés (miért működik így?)
- Best practice kérdés (hogyan érdemes?)
- Gyors tisztázás (ez így jó?)

**Nem erre való:**
- Bug diagnosztika → /bug
- Kód review → /review
- Ötletelés → /next-ideas
- Tervezés → /plan

---

## Instructions

A feladatod, hogy a megadott kérdésre válaszolj.

**Alapelvek:**
- Ne tervezz, ne refaktorálj, ne ötletelj tovább, hacsak nem kérik
- Fókuszálj kizárólag a kérdésre
- Ha a válasz erősen kontextusfüggő → jelezd
- Ha bizonytalan → mondd ki
- Ne használj túl sok szakzsargont
- Tartsd be az előírt output struktúrát
- Ha a constraints tilt valamit (pl. új architektúra), azt tartsd be

**A válaszod magyar nyelven legyen**, hacsak a kérdés nem más nyelvű.

---

## Input

1. **question** (kötelező):
   - Egy konkrét kérdés

2. **context** (opcionális):
   - Kódrészlet
   - Rendszerleírás
   - Domain (pl. ".NET backend", "pénzügyi logika")
   - IDE-ben kijelölt kód automatikusan ide kerül

3. **depth** (opcionális):
   - `short` – direkt válasz, minimális kifejtés
   - `normal` – kiegyensúlyozott magyarázat (default)
   - `deep` – részletesebb háttér, példák

4. **constraints** (opcionális):
   - pl. "ne javasolj új architektúrát"
   - pl. "csak a jelenlegi megoldásról beszélj"

---

## Depth módok viselkedése

| Depth | Mit csinál |
|-------|------------|
| `short` | Direkt válasz, minimális kifejtés. Csak "Rövid válasz" + "Kifejtés" szekció. |
| `normal` | Kiegyensúlyozott magyarázat minden szekcióval. |
| `deep` | Részletesebb háttér, példák, edge case-ek, összefüggések. |

---

## Output Format (KÖTELEZŐ)

```markdown
# Válasz

## Rövid válasz

[1–3 mondat, lényegre törően. A kérdés közvetlen megválaszolása.]

---

## Kifejtés

- [Pont 1 – csak ami a kérdéshez kell]
- [Pont 2]
- [Pont 3]

---

## Fontos megjegyzések

- [Kontextusfüggő dolgok]
- [Gyakori félreértések]
- [Edge case-ek]

---

## Ha tovább kérdeznél

- [Follow-up kérdés 1]
- [Follow-up kérdés 2]
- [Follow-up kérdés 3]
```

**Megjegyzések:**
- `depth=short` esetén csak "Rövid válasz" és "Kifejtés" szekció
- Nem kötelező minden szekció hosszú legyen
- A válasz hossza a kérdés komplexitásához igazodjon

---

## Intelligens viselkedések

### Ha a kérdés rosszul van feltéve

Válaszolj, de jelezd a feltételezést:

> "Feltételezem, hogy ASP.NET környezetről van szó. Ha nem, a válasz eltérhet."

### Ha nincs elég információ

Ne hallucinálj, hanem jelezd:

```markdown
## Fontos megjegyzések

- A válasz pontosításához ezek hiányoznak:
  - [Hiányzó információ 1]
  - [Hiányzó információ 2]
```

### Nem csúszik át más slash-ekbe

| Slash | Mire való |
|-------|-----------|
| /ask | válaszol |
| /bug | diagnosztizál |
| /review | kritizál |
| /next-ideas | ötletel |
| /plan | tervez |

A `/ask` tudatosan szűk fókuszú.

---

## Example Usage

### Példa 1 – egyszerű technikai kérdés (short)

**Input:**
```
/ask

question:
"Mi a különbség a scoped és transient DbContext között?"

context:
".NET Web API, EF Core"

depth:
short
```

**Output:**
```markdown
# Válasz

## Rövid válasz

A scoped DbContext egy HTTP requesten belül egy példány, a transient minden injektáláskor új példány.

---

## Kifejtés

- **Scoped:** Biztonságos request-alapú használatra. Egy request alatt ugyanaz a DbContext példány.
- **Transient:** Minden injektáláskor új példány. EF Core esetén könnyen okozhat inkonzisztenciát (pl. tracking problémák).
- **Ajánlás:** EF Core DbContext-hez mindig scoped lifetime-ot használj.
```

---

### Példa 2 – rendszer viselkedés (normal)

**Input:**
```
/ask

question:
"Miért nem jó ötlet párhuzamos Task.WhenAll ugyanazzal a DbContexttel?"

context:
OrdersService async metódus
```

**Output:**
```markdown
# Válasz

## Rövid válasz

Mert a DbContext nem thread-safe, és párhuzamos használatnál nem determinisztikus hibák léphetnek fel.

---

## Kifejtés

- A DbContext belső állapotot tart (change tracker, connection)
- Párhuzamos műveletek race condition-t okozhatnak
- Tipikus hiba: `InvalidOperationException: MARS not supported` vagy korrupt tracking state
- EF Core explicit módon nem támogatja a concurrent access-t

---

## Fontos megjegyzések

- Ez gyakran csak nagy terhelés alatt jön elő
- A hiba nem mindig reprodukálható lokálisan
- Dev környezetben ritkábban jelentkezik (kevesebb párhuzamosság)

---

## Ha tovább kérdeznél

- Hogyan oldjam meg, ha mégis párhuzamos query-kre van szükségem?
- Mikor érdemes `IDbContextFactory<T>`-t használni?
- MARS engedélyezése megoldás lehet?
```

---

### Példa 3 – constraint-tel

**Input:**
```
/ask

question:
"Hogyan javíthatnám a lassú query-t?"

context:
SELECT * FROM Orders WHERE CustomerId = @id

constraints:
"ne javasolj új architektúrát, csak a jelenlegi query-t optimalizáld"
```

**Output:**
```markdown
# Válasz

## Rövid válasz

Index hozzáadása a `CustomerId` oszlopra, és a `SELECT *` lecserélése explicit oszloplistára.

---

## Kifejtés

- **Index:** `CREATE INDEX IX_Orders_CustomerId ON Orders(CustomerId)`
- **Oszloplista:** Csak a ténylegesen szükséges oszlopokat kérd le
- **Execution plan:** Ellenőrizd, hogy a query használja-e az indexet

---

## Fontos megjegyzések

- Ha gyakori a lekérdezés, érdemes covering index-et használni
- A constraint miatt architektúrális változtatást (pl. caching, CQRS read model) nem javaslok
```

---

## Kombinálható workflow

A `/ask` jól illeszkedik más slash-ekhez:

```
/ask → /bug      "Miért működik így?" → "Ez baj?"
/ask → /review   "Ez így helyes?" → "Mit javítsak?"
/ask → /next-ideas  "Miért van így?" → "Mit lehetne jobban?"
```

---

## Egy mondatos szabály

> Ha egy konkrét kérdésre nem kapsz egyértelmű választ, akkor a /ask rosszul van megírva.
