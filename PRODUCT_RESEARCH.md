# POUYANLY — product research notes

## Product patterns to adopt

| Product | Pattern to learn from | POUYANLY decision |
|---|---|---|
| Duolingo | short lessons, visible path, XP, streaks and leagues | use short lessons and restrained rewards; don't optimize for streaks over learning |
| Busuu | structured CEFR course and placement test | use CEFR levels and a diagnostic before the course |
| Babbel | practical dialogues and explicit grammar explanations | explain why an answer is right/wrong in Persian |
| Memrise | phrases and native-speaker context | add contextual phrase/audio packs in a later content release |
| ELSA Speak | focused pronunciation feedback | keep speaking as a separate skill; do not fake scoring without speech recognition |
| Speak | guided spoken production and role-play | add offline scripted speaking prompts first, then optional speech service |
| Anki | spaced repetition and user-controlled recall | use recall-first vocabulary cards and mastery-based intervals |
| Rosetta Stone | visual/contextual immersion | use image/context prompts as an optional exercise type |
| Mondly | short interactive scenario practice | add practical scenario units (travel, shopping, work) |
| LingQ | learning through longer authentic input | later add graded reading/listening library with saved vocabulary |

## Community signals

Reddit discussion threads point to recurring dissatisfaction with gamification crowding out learning, weak grammar explanations, limited retention/review, and the friction of setting up powerful flashcard tools. These are anecdotal community signals, not representative user research. POUYANLY should measure learning outcomes (retention and skill checks), not only time-on-app or XP.

## Product principles
1. Learning outcome before engagement metric.
2. Explain errors in Persian; never show only right/wrong.
3. Teach words in phrases and situations, not isolated lists only.
4. Make each skill's assessment status transparent.
5. Local-first persistence; cloud sync remains optional future work.

## Technical decision
Flutter is suitable for a shared Android UI and supports local persistence choices. Structured user progress can use on-device SQLite (or a simpler key-value store for a small prototype). This MVP uses `shared_preferences` with JSON-encoded state to keep setup minimal; a production release should migrate structured lesson/attempt/review data to SQLite/Drift.

## Evidence and source links (checked 30 Oct 2026)

- [Duolingo: how its lessons, XP, streaks and leaderboards work](https://blog.duolingo.com/duolingo-101-how-to-learn-a-language-on-duolingo/)
- [Busuu: English placement test and adaptive difficulty](https://www.busuu.com/en/english/placement-test) and [placement-test support page](https://help.busuu.com/hc/en-us/articles/16526383831569-What-is-a-Placement-Test)
- [Babbel: speech recognition in speaking exercises](https://support.babbel.com/hc/en-us/articles/19211305815570-Speech-recognition)
- [Memrise: native-speaker videos and phrase practice](https://www.memrise.com/)
- [Speak: phrase learning, guided practice, AI conversation and feedback](https://www.speak.com/)
- [Anki: SM-2 and FSRS spaced-repetition algorithms](https://faqs.ankiweb.net/what-spaced-repetition-algorithm.html)
- [Rosetta Stone: speech recognition and immersion settings](https://support.rosettastone.com/All-About-Language-Training/)
- [Flutter: choosing local persistence (SQLite/key-value)](https://docs.flutter.dev/data-and-backend/persistence/choose-a-database)
- [Flutter: offline-first architecture](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)
- [Reddit r/EnglishLearning: frustration with streaks, paywalls and weak review](https://www.reddit.com/r/EnglishLearning/comments/1rtmyw9/whats_your_biggest_frustration_with_language/)
- [Reddit r/languagelearning: criticism of shallow gamification and grammar coverage](https://www.reddit.com/r/languagelearning/comments/1nlxu24/there_is_something_terribly_wrong_with_duolingo/)

The table above is a synthesis of representative official feature descriptions and user discussion, not a hands-on usability audit of every app version or a statistically representative survey. For Mondly and LingQ, this initial report records the product patterns to evaluate further; a deeper comparative audit should be a separate research pass before a commercial release.
