---
name: creative-production
description: Use when a product needs restrained visual assets or a launch video built from real product screens with optional licensed music and voiceover
version: 1.0.0
tags: [design, video, hyperframes, music, launch]
metadata:
  hermes:
    tags: [creative, video, hyperframes, music]
    requires_toolsets: [terminal, browser, vision]
---

## Overview

Produces minimal product launch assets. For video, it uses HyperFrames so the
story, timing, motion, and audio remain editable and deterministic.

## When to Use

- A launch, feature announcement, demo, or onboarding video is requested.
- Product screenshots need art direction or annotation.
- A campaign needs a coherent visual asset set.

## Prerequisites

- Approved product or campaign brief.
- Access to a working product, screenshots, or source material.
- Node.js, a supported browser, and FFmpeg for HyperFrames rendering.
- A licensed music source if music will be used.

## Procedure

1. Write a one-page creative brief: audience, message, proof, CTA, duration,
   aspect ratios, visual constraints, and required assets.
2. Gather real product screens and recordings. Do not fabricate product states.
3. Create a beat-by-beat storyboard. Every scene must advance the message.
4. For video, inspect and install the official HyperFrames skill only when this
   capability is requested:
   ```bash
   npx skills add heygen-com/hyperframes
   ```
   Then create an HTML composition with explicit dimensions and duration.
5. Lint and render a low-cost draft. Sample the opening, every scene boundary,
   and final frame for clipping, blank frames, timing, and legibility.
6. Iterate on one visual or timing problem at a time.
7. Export only the requested platform variants. Reframe deliberately rather than
   cropping one master blindly.
8. When the founder explicitly requests generated footage, use
   `generate-with-seedance` for approved shots, then compose and verify those
   shots through the same HyperFrames workflow.

### Music supervision

1. Define mood, tempo range, instrumentation, vocal preference, and energy arc.
2. Search an authorized commercial catalog or platform business-music library.
3. Shortlist at most three tracks with source links and license coverage.
4. Ask the founder to choose, or continue without music if they skip.
5. Save `music-license.json` beside the project with track, source, license,
   covered channels, account owner, and acquisition date.
6. Mix music under speech, use short fades, and verify the final rendered audio.

Never download music from an unofficial source or treat "royalty free" as proof
of commercial permission.

## Visual Standard

- Show the product in the first few seconds.
- Use one visual idea per scene and a restrained palette.
- Keep typography readable without sound and motion meaningful without spectacle.
- Avoid stock AI imagery, fake interfaces, excessive glow, rapid template cuts,
  decorative clutter, and unsupported claims.

## Pitfalls

- A successful render can still contain blank or clipped scenes. Inspect frames.
- Browser animation can drift when based on wall-clock time. Use frame timing.
- Social and commercial music licenses are not interchangeable.
- Platform UI can cover captions near edges; preserve safe zones.

## Verification

- HyperFrames lint and render complete successfully.
- Sampled frames show the intended product and contain no clipping or blanks.
- Voice, music, and SFX are synchronized and audible at appropriate levels.
- `music-license.json` exists when third-party music is included.
- Founder approved the final asset before publication.
