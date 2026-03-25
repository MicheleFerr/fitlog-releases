# Analytics Selector UX Audit

Date: 2026-03-12
Status: Research complete, ready to translate into UI implementation
Scope: Analytics feature only

## Goal

Define a premium, coherent selector system for analytics. The immediate trigger is the `Pro Insights` top selector, which currently feels unstable because selected tabs change perceived size and visual weight. The broader goal is to standardize analytics selectors so users can predict which controls navigate between sections and which controls simply switch views.

This document is grounded in the current Flutter implementation and cross-checked against external guidance:

- [Carbon Design System: Tabs](https://carbondesignsystem.com/components/tabs/usage/)
- [Carbon Design System: Content Switcher](https://carbondesignsystem.com/components/content-switcher/usage/)
- [WAI-ARIA APG: Tabs Pattern](https://www.w3.org/WAI/ARIA/apg/patterns/tabs/)
- [WCAG 2.2: Target Size Minimum](https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html)

## Selector Inventory

| Control | Current file | Current widget | Correct archetype | Verdict |
| --- | --- | --- | --- | --- |
| Pro Insights top selector | `lib/features/analytics/presentation/screens/pro_analytics_tabbed_screen.dart` | `TabBar` with custom icon+text tabs | Navigation tabs | Keep as tabs, redesign treatment |
| Inline analytics sub-selector | `lib/features/analytics/presentation/tabs/inline_analytics_tab.dart` | `TabBar` with text tabs | Navigation tabs | Align to same standard as Pro Insights |
| Exercise detail metric switch | `lib/features/analytics/presentation/screens/exercise_detail_screen.dart` | `SegmentedButton` | View switcher | Correct archetype, use as behavior baseline |
| Rep zone chart toggle | `lib/features/analytics/presentation/tabs/rep_zone_tab.dart` | `SegmentedButton` | View switcher | Correct archetype, standardize visual rules |

## Current-State Audit

### 1. The Pro Insights selector resizes because state affects intrinsic width

The current `TabBar` in `pro_analytics_tabbed_screen.dart` is `isScrollable`, uses intrinsic tab content, and applies different typography between selected and unselected states:

- `isScrollable: true` at line 172
- `labelStyle` uses `fontWeight.w600` at lines 192-194
- `unselectedLabelStyle` uses default `labelMedium` at line 195
- each tab is built with `mainAxisSize: MainAxisSize.min` at line 426

This combination makes the selected label occupy a different width than the unselected label. Because the tabs are measured intrinsically, the selected state feels like it grows and shrinks even when the layout technically remains valid.

### 2. The visual metaphor is mixed: tabs behave like navigation, but look like a switcher

The control is a `TabBar`, which is appropriate because each tab reveals a different analytics panel. However, the visual treatment uses a pill-style contained indicator and icon+label capsules, which makes it read more like a segmented control. This creates a category mismatch:

- behavior says "navigate between peer sections"
- styling says "toggle between alternate views"

That mismatch weakens perceived quality more than the jitter alone.

### 3. Top-level analytics tabs are over-decorated

The current Pro Insights tabs combine:

- icon
- text
- contained gradient indicator
- accent border
- tertiary accent color

for all 5 sections at once. In practice, this slows scanning and makes the selector compete with the content. Carbon tabs guidance is lighter-weight and explicitly recommends short labels. For a refined premium feel, the top selector should feel quieter, not louder.

### 4. Label length is not matched to the control density

Current labels include values like:

- `Rep Zones`
- `Volume`
- `Muscle Balance`
- `Training Stress`
- `Plateau`

The control is compact and scrollable, but two labels are significantly longer than the rest. This creates uneven rhythm and raises the chance of width instability in localization. The same problem exists in `inline_analytics_tab.dart`, where the duplicate pattern still uses the long forms.

### 5. The pattern is duplicated instead of standardized

`inline_analytics_tab.dart` repeats the same `TabBar` language as Pro Insights:

- `isScrollable: true` at line 78
- selected/unselected typography mismatch at lines 98-101
- contained pill indicator at lines 82-95

This means the inconsistency is not just a one-off component problem. It is an analytics pattern problem.

### 6. The view-switching selectors are conceptually healthier

The selectors in `exercise_detail_screen.dart` and `rep_zone_tab.dart` are already `SegmentedButton`s. This is the correct archetype because they switch between alternate representations of the same content:

- chart metric switch in `exercise_detail_screen.dart` at lines 501-528
- bar vs pie toggle in `rep_zone_tab.dart` at lines 430-459

These controls still need visual unification, but their information architecture is correct. They should remain switchers, not be converted into tabs.

## Best-Practice Matrix

| Decision area | Best practice | Current Pro Insights state | Gap |
| --- | --- | --- | --- |
| Control archetype | Use tabs for peer sections, switchers for alternate views | Correct behavior, mixed visual language | Medium |
| Label length | Keep labels short, noun-like, easy to scan | Two labels are too long for compact premium tabs | High |
| Width stability | Selected state must not change control geometry | Selected font weight changes intrinsic width | High |
| Icon policy | Top-level tabs should not rely on icons for comprehension | Every Pro tab uses icon + text | Medium |
| Selected state | Express selection through color, surface, and border, not text mass | Selection currently changes both pill and type weight | High |
| Accessibility | Minimum 44dp touch comfort, at least 24x24 target floor | Acceptable in practice, but not explicitly standardized | Medium |
| Reuse | Same UX language for same analytics role | Duplicate patterns diverge manually | High |

## Research Takeaways

### Carbon tabs

Relevant takeaways for this repo:

- tabs are the right pattern when content changes by section
- labels should stay short and scan quickly
- tabs should not carry unnecessary visual noise
- icon-heavy tab labels reduce clarity in dense navigation

### Carbon content switcher

Relevant takeaways for this repo:

- use a switcher when the same content changes representation
- labels should be short
- switcher segments should feel comparable and stable

This maps well to the existing analytics `SegmentedButton` controls.

### WAI-ARIA tabs pattern

Relevant takeaways for this repo:

- tabs imply a specific interaction model and focus order
- if we keep tabs, arrow-key and focus behavior should remain standard
- the component should not be visually restyled so aggressively that it stops reading like tabs

### WCAG 2.2 target size

Relevant takeaway:

- interactive targets should not fall below the 24x24 minimum requirement
- mobile comfort should still aim for 44dp-style touch sizing for the final design

## Design Directions

### Direction A: Stabilized Scroll Tabs

Keep the `TabBar` model for top-level analytics sections, but redesign the selector so it reads as premium navigation rather than a heavy switcher.

What changes:

- keep `isScrollable: true`
- remove icons from top-level analytics tabs
- use the same typography weight for selected and unselected states
- express selection via surface tint, border, and foreground color only
- keep fixed tab height and fixed internal horizontal padding
- keep labels single-line and shorter

Pros:

- lowest implementation risk
- matches the actual information architecture
- easiest to apply consistently to `Pro Insights` and inline analytics
- solves the jitter without changing behavior

Cons:

- less visually dramatic than a full capsule switcher
- still requires copy cleanup to feel truly premium

### Direction B: Premium Content Switcher

Replace the top-level selector with a contained segmented control style.

What changes:

- sections become pills within a shared container
- equal-height segments with stronger selected fill
- more product-like, less nav-like

Pros:

- stronger premium product feel
- highly stable geometry

Cons:

- wrong semantic signal for peer analytics sections
- risks making 5 sections feel crowded
- more likely to compress badly in Italian

Verdict:

Not recommended for the Pro Insights top selector. Keep this language for true view-switchers only.

### Direction C: Hybrid Hierarchy

Reduce density by splitting hierarchy before selection.

Possible pattern:

- a smaller top selector for 3 major areas
- secondary switcher or chips inside each area

Pros:

- cleaner cognitive load if analytics keeps growing
- stronger information hierarchy

Cons:

- requires content restructuring
- not justified by the current 5-tab set if copy is shortened

Verdict:

Use only if the analytics surface grows beyond the current five sections or if localization remains crowded after Direction A.

## Recommendation

Adopt `Direction A: Stabilized Scroll Tabs` for analytics navigation and standardize existing `SegmentedButton` controls as the canonical view-switcher pattern.

This gives the best tradeoff across:

- stability
- premium feel
- information clarity
- implementation risk
- localization resilience

It also fits the existing design system better than a heavier redesign because it can reuse:

- `tertiary` as the premium accent
- `AppSpacing` for fixed rhythm and padding
- `AppBorderRadius` for selector shape

## Recommended Selector Contract

### Navigation tabs contract

Use for:

- switching between peer analytics sections with distinct content panels

Rules:

- text-only labels for top-level analytics navigation
- scrollable is allowed
- selected and unselected labels use the same type size and same font weight
- selection is expressed by color, surface, and border only
- control height must remain constant in all states
- internal horizontal padding must remain constant in all states
- single-line labels only
- icons are not used in top-level analytics tabs
- motion is color-only or opacity-only, 150-200ms max, no layout animation

Visual defaults:

- height: 44
- radius: `AppBorderRadius.sm`
- horizontal padding per tab: 14-16, implemented with `AppSpacing`
- gap between tabs: 8, implemented with `AppSpacing.xs`
- selected surface: `tertiary` tinted surface, not full solid fill
- selected border: 1px accent border
- unselected surface: transparent
- typography: `labelMedium`

### View switcher contract

Use for:

- alternate views of the same chart or metric set

Rules:

- keep `SegmentedButton`
- equal-height segments
- same typography across states
- icons are optional and only kept if every segment uses them consistently
- prefer equal-width segments when there are 2-4 short options
- use a contained shared track to reinforce "same content, different view"

Visual defaults:

- height: 40-44
- radius: `AppBorderRadius.sm`
- selected state: filled surface
- unselected state: neutral surface
- compact spacing is allowed only if touch target remains comfortable

## Copy Recommendation

### Navigation tabs

Recommended English labels:

- `Rep Zones`
- `Volume`
- `Balance`
- `Stress`
- `Plateau`

Recommended Italian labels:

- `Zone Rep`
- `Volume`
- `Equilibrio`
- `Stress`
- `Plateau`

Notes:

- `Balance` is intentionally shorter than `Muscle Balance`
- `Stress` is intentionally shorter than `Training Stress`
- these labels are better aligned to a premium compact selector

### View switchers

Existing analytics switcher labels are already close to target quality:

- `Weight`
- `Volume`
- `Reps`
- `RPE`
- `Bar`
- `Pie`

These should be kept concise and noun-like.

## Implementation Translation

When this study is converted into UI work, the first implementation pass should do only the following:

1. restyle `Pro Insights` tabs to the navigation-tabs contract
2. apply the same contract to `inline_analytics_tab.dart`
3. shorten top-level labels in both EN and IT
4. leave `SegmentedButton` selectors in analytics as switchers, only aligning their visual rules if needed

This keeps the refactor contained while eliminating the current source of inconsistency.

## Validation Checklist

- selected and unselected top tabs do not change measured width
- no label wraps in EN or IT on common phone widths
- top-level analytics tabs scan cleanly without icons
- Pro Insights and inline analytics use the same navigation pattern
- exercise-detail and rep-zone toggles still read as switchers
- light, dark, and pink themes preserve contrast and hierarchy
- keyboard/focus behavior remains standard `TabBar` behavior where tabs are used
- all interactive segments remain at or above comfortable mobile tap sizing

## Final Decision

- `Pro Insights` top selector: navigation tabs, Direction A
- `Inline analytics` sub-selector: same navigation tabs standard
- `Exercise detail` metric switch: keep as segmented switcher
- `Rep zone` chart toggle: keep as segmented switcher

This is the recommended premium UX system for analytics going forward.
