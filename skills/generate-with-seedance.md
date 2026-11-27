---
name: generate-with-seedance
description: Use when an approved storyboard needs paid Seedance video generation through the official Volcengine Ark API
version: 1.0.0
tags: [design, video, seedance, volcengine, generation]
---

## When to Use

- A storyboard needs a generated shot that cannot be made from product footage.
- The founder explicitly chooses Seedance for a launch asset.

## Prerequisites

- Volcengine Ark access with Seedance enabled.
- `ARK_API_KEY` in `~/.hermes/.env`.
- `SEEDANCE_MODEL`, defaulting to `doubao-seedance-2-0-260128`.
- Approved prompt, references, duration, aspect ratio, watermark policy, and
  generation budget.

## Procedure

1. Prefer real product recordings and HyperFrames composition. Use Seedance only
   for an approved generated shot.
2. If credentials are missing, stop and direct the user to
   `bash ~/.hermes/scripts/setup-integrations.sh --seedance`. Never request a key in chat.
3. Confirm the current model ID, access, pricing, regional base URL, and content
   policy in the official Ark console before each campaign.
4. Write the request to `seedance-request.json` using the official asynchronous
   task contract. Exclude unlicensed references and unauthorized likenesses.
5. Show the complete payload and estimated spend. Require founder approval
   before the paid request.
6. Submit the task:
   ```bash
   curl --fail-with-body --silent --show-error \
     "${SEEDANCE_BASE_URL:-https://ark.cn-beijing.volces.com/api/v3}/contents/generations/tasks" \
     -H "Authorization: Bearer $ARK_API_KEY" \
     -H "Content-Type: application/json" \
     --data-binary @seedance-request.json
   ```
7. Store only the returned task ID. Poll no faster than every 30 seconds:
   ```bash
   curl --fail-with-body --silent --show-error \
     "${SEEDANCE_BASE_URL:-https://ark.cn-beijing.volces.com/api/v3}/contents/generations/tasks/$TASK_ID" \
     -H "Authorization: Bearer $ARK_API_KEY"
   ```
8. Stop on `failed`, `cancelled`, or `expired`. On `succeeded`, download the
   result, record provenance, and inspect sampled frames before composition.

## Pitfalls

- Generation is paid and asynchronous; retries can create duplicate charges.
- Do not present unofficial Seedance wrappers as ByteDance services.
- Model IDs, regional endpoints, pricing, and policies can change.
- Never place `ARK_API_KEY` in payloads, task logs, Git, or memory.

## Verification

- The request used an official Ark endpoint and enabled model.
- Founder approval and budget were recorded before submission.
- The task reached `succeeded`, and the output was downloaded and inspected.
- Provenance identifies generated footage before publication.
