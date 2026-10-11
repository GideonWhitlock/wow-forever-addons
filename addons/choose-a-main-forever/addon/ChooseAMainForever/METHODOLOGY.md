# Recommendation methodology

## Separation of concerns

Question wording and answer interpretation live in `Data/Questions.lua`. Patch-sensitive class profiles live in `Data/Classes.lua`. The engine never embeds class points in an answer. Instead, it builds a player preference vector and compares that vector with every eligible talent-path vector.

## Scale

Every capability and preference uses the same ordinal `0..5` scale:

- `0`: deliberately absent, rejected or fundamentally opposed
- `1`: very low
- `2`: below average
- `3`: moderate or mixed
- `4`: strong
- `5`: defining

An answer supplies one or more observations with an explicit evidence weight. Multiple observations of the same dimension are averaged; they are not allowed to stack without limit.

## Compatibility

For every answered dimension supported by a result mode:

`similarity = 1 - abs(player preference - talent-path rating) / 5`

The engine computes a weighted mean of those similarities and converts it to a `0..100` model score. This number is useful for ranking within one assessment only. It is not a probability, percentile or scientifically validated enjoyment prediction.

Gameplay and long-term results use separate dimension-weight tables. Both tables are versioned with the engine.

## Restrictions

Before scoring, the engine removes candidates that violate any explicit class, primary-role, stationary-casting, faction or allowed-race restriction. The official Forever race/class matrix is used. Character sex is stored as a structured preference but does not remove a class because the verified build offers each race/class option to both character sexes.

If no candidate remains, the engine returns a restrictions conflict. It never silently relaxes an exclusion.

## Interactions

The following documented combinations can adjust a candidate by a small amount:

- control plus durability
- solo play plus short or irregular sessions
- utility plus low tolerance for upkeep
- companion interest plus direct melee interest
- mobility plus explicit dislike of stationary casting
- role flexibility plus broad activity flexibility

All interaction adjustments are derived from candidate ratings and capped to `-8..+8` total points. They cannot bypass restrictions.

## Previous experience

Played-before and maximum-level history provide weak evidence. Enjoyed, disliked and would-play-again provide stronger evidence, especially for the long-term result. The dependent choices remain unavailable until **Played before** is selected, and clearing **Played before** clears them. Dislike is a penalty, not an exclusion; **unwilling to play** is the separate hard control. Free-text notes are never interpreted.

## Ranking and confidence

The engine ranks every eligible talent path deterministically, then chooses the best three different classes for the headline. Other paths within the winning class remain visible as notable same-class alternatives.

Confidence labels use answer completeness and the score margin between the two leading eligible paths:

- Insufficient information
- Close decision
- Plausible alternative
- Good match
- Strong match

They are qualitative model labels, not accuracy claims.

## Explanations

The engine sorts the actual dimension contributions used for the winning score. Those contributions select the strengths and frustrations named in the result. The prose therefore reflects the calculation rather than a separate set of canned class claims.
