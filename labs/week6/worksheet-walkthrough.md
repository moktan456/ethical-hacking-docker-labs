# Week 6 Worksheet Walkthrough — INSTRUCTOR ONLY

> Verified against live containers. Do not distribute to students before the
> end of the session.

---

## Note on Part 2's `john` commands

**`worksheet.md` now includes `--format=Raw-MD5` on every `john` invocation
in Exercises 2.1–2.3** — this was a required fix, not a style choice. A
bare 32-character hex hash is ambiguous (John's auto-detection guesses
"LM," a legacy Windows format, ahead of raw MD5), so without the explicit
`--format` flag John never actually attempts MD5 and reports "0 password
hashes cracked" instead of finding "hello"/"password". Live-verified below
with the corrected commands. If you're ever running this lab from an older
copy of `worksheet.md` without the flag, see the boxed note under Exercise
2.1 for the full explanation.

---

## Part 1: Understanding Passwords

### Exercise 1.1: What is a Hash?

```bash
echo -n "hello" | md5sum
```

**Verified result:** `5d41402abc4b2a76b9719d911017c592` — matches the
hardcoded hash used in Exercise 2.1, confirming the two exercises are
meant to connect.

**Can you reverse a hash?** **No — one-way only.**

### Exercise 1.2: Different Hash Types

```bash
echo -n "password" | md5sum
echo -n "password" | sha1sum
echo -n "password" | sha256sum
```

**Verified result:**

| Hash Type | Length | First 6 characters |
|-----------|--------|---------------------|
| MD5 | 32 | `5f4dcc` |
| SHA-1 | 40 | `5baa61` |
| SHA-256 | 64 | `5e8848` |

### Exercise 1.3: Why Do We Hash Passwords?

**Answer: B** — so even if someone steals them, they can't read them.

---

## Part 2: Your First Password Crack

### Exercise 2.1: Cracking with John the Ripper

```bash
echo "5d41402abc4b2a76b9719d911017c592" > myfirst.txt
john --format=Raw-MD5 myfirst.txt
john --format=Raw-MD5 --show myfirst.txt
```

> **Why `--format=Raw-MD5` is required, not optional:** a bare
> 32-character hex string is ambiguous — it's also valid as an LM hash (a
> legacy Windows format, coincidentally also 32 hex characters), and
> John's auto-detection guesses LM first. Without the explicit flag, John
> spends its whole run trying LM-style candidates (uppercased, split into
> two 7-character halves) and never actually attempts MD5, so `--show`
> reports **0 password hashes cracked** instead of "hello." This is a
> real, current behaviour of this John the Ripper build — confirmed live
> by running the bare `john myfirst.txt` (no `--format`) and getting
> exactly that silent failure.

**Verified result with `--format=Raw-MD5`:** cracks instantly via wordlist
mode — `hello (?)`, confirmed by `--show` reporting `?:hello` / "1 password
hash cracked."

**What password did John find?** `hello`.

**How long did it take?** Effectively instant (<1 second) — it's the first
word tried in wordlist mode.

### Exercise 2.2: Using a Wordlist

```bash
head /wordlists/basic.txt
echo "5f4dcc3b5aa765d61d8327deb882cf99" > test2.txt
john --format=Raw-MD5 --wordlist=/wordlists/basic.txt test2.txt
john --format=Raw-MD5 --show test2.txt
```

**Verified `/wordlists/basic.txt` contents (10 words):** `password`,
`123456`, `password123`, `12345678`, `qwerty`, `admin`, `letmein`,
`welcome`, `monkey`, `dragon`.

**`--format=Raw-MD5` matters here too** — even with `--wordlist` specified,
John still auto-detects the hash type first (see the Exercise 2.1 note),
so leaving the flag off finds nothing (confirmed live: `0g` cracked with
the bare command). With the flag included, as in the worksheet:

**Verified result:** cracks instantly — `password`.

**What password was it?** `password`.

**Was it in the wordlist?** **Yes** — it's the very first line.

### Exercise 2.3: Making Your Own Hash

```bash
echo -n "dog" | md5sum
echo "06d80eb0c50b49a509b49f2424e8c805" > myhash.txt
john --format=Raw-MD5 --wordlist=/wordlists/basic.txt myhash.txt
```

**Verified result (using "dog" as the test word):** John reports `0g`
cracked — `dog` is genuinely not one of the 10 words in `basic.txt`.

**Did John crack your password?** **No** (for a word outside the
wordlist, like "dog").

**If no, why not?** The wordlist only contains 10 specific common
passwords — John (in wordlist mode) can only find a password if it's
literally present in the list it's given. A word like "dog," while short
and guessable, simply isn't one of those 10 entries.

---

## Part 3: Network Password Attacks

### Exercise 3.1: Finding Our Target

```bash
getent hosts ssh-target
```

**Verified result:** `10.10.6.10  ssh-target` — Docker Compose's built-in
DNS resolves the service name directly.

### Exercise 3.2: Using Hydra (Simplified)

```bash
echo "password" > minilist.txt
echo "123456" >> minilist.txt
echo "letmein" >> minilist.txt
hydra -l admin -P minilist.txt ssh://ssh-target
```

**Verified result:**
```
[22][ssh] host: ssh-target   misc: (null)   login: admin   password: letmein
1 of 1 target successfully completed, 1 valid password found
```
Completed in about 3 seconds.

**Did Hydra find the password?** **Yes.**

**If yes, what was it?** `letmein`.

### Exercise 3.3: Understanding the Danger — answers

1. **Math:** 100 × 60 × 60 × 24 = **8,640,000** password attempts per day.
2. **How to stop Hydra attacks (one idea):** Account lockout / rate
   limiting after a small number of failed attempts (e.g. 5), combined with
   an increasing delay between attempts — this turns an attack that could
   try millions of passwords a day into one that can realistically only try
   a handful.

---

## Part 4: Creating Strong Passwords

### Exercise 4.1: Testing Password Strength

```bash
python3 -c "
passwords = ['123456', 'password', 'MyDog123', 'MyDogIsMax2024!']
for p in passwords:
    print(f'{p:20} Strength: ', end='')
    if len(p) < 8:
        print('WEAK - Too short')
    elif p.lower() in ['password', '123456', 'qwerty']:
        print('WEAK - Too common')
    elif not any(c.isdigit() for c in p):
        print('MEDIUM - Add numbers')
    else:
        print('STRONG - Good job!')
"
```

**Verified result:**
```
123456               Strength: WEAK - Too short
password             Strength: WEAK - Too common
MyDog123             Strength: STRONG - Good job!
MyDogIsMax2024!      Strength: STRONG - Good job!
```

### Exercise 4.2: Make a Strong Password

No fixed answer — any password matching "3 random words + number + symbol"
and 12+ characters qualifies, e.g. `Coffee@Plant7Desk!` (the worksheet's
own example) or `Purple$Kettle9Moon!`.

### Exercise 4.3: Password Rules — answer key

**Check these (good rules):**
- ✅ At least 12 characters long
- ✅ Different for every website
- ✅ Uses a password manager
- ✅ Has numbers and symbols

**Do not check these (bad advice):**
- ❌ Changed every month (forced frequent rotation encourages weak,
  predictable patterns — modern guidance, e.g. NIST SP 800-63B, recommends
  against mandatory periodic rotation for this reason)
- ❌ Includes your birthday (easily guessable/publicly discoverable)
- ❌ Written on a sticky note (physical exposure risk)
- ❌ Is your pet's name (easily guessable/publicly discoverable, e.g. from
  social media)

---

## Part 5: Professional Ethics

### Exercise 5.1: Legal or Illegal? — answers

| Scenario | Legal? |
|----------|--------|
| Testing passwords on your own computer | **Legal** |
| Trying to crack your friend's Facebook | **Illegal** |
| Testing a company's security with written permission | **Legal** |
| Cracking passwords for a class assignment | **Legal** (within the authorised lab environment) |
| Selling cracked passwords online | **Illegal** |
| Testing your school's WiFi without permission | **Illegal** |

### Exercise 5.2: What Would You Do?

**Answer: C** — privately tell the teacher they should change it.

**Why?** Responsible disclosure: the goal is fixing the vulnerability, not
exploiting or publicising it. Telling only the affected person, privately,
protects them and demonstrates the same professional judgement expected in
a real engagement — the same principle covered in Week 2's responsible
disclosure material.

---

## Quick Quiz — Answers

1. **B) A one-way transformation of a password**
2. **D) Tr0ub4dor&3** (longest, most character variety, least guessable)
3. **B) John the Ripper**
4. **True**
5. **D) 12+ characters**

---

## Notes for the Instructor

- `worksheet.md`'s `john` commands (Exercises 2.1–2.3) already include
  `--format=Raw-MD5` — this is required, not optional (see the note under
  Exercise 2.1). If you ever see a copy of the worksheet without it,
  students copy-pasting the bare command will get "0 password hashes
  cracked" and likely assume they made a mistake.
- If a student's `john` run seems to hang or a later run reports "Crash
  recovery file is locked," it's a stale `~/.john/john.rec` from a
  previous interrupted run — `rm -f ~/.john/john.rec` clears it.
- Hydra's 3-password/3-second demo in 3.2 is intentionally tiny for
  classroom pacing; Exercise 3.3's math question is what connects this toy
  example to real-world attack scale.
