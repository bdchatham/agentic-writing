# Anchor recognition tests

An anchor works only if the model resolves the term. This is the one property that no
amount of prompt engineering can add, and it can change with a model version. Test it.

## Method

For each anchor in `anchors/registry.yaml`, send the `recognition.probe` string to the
model in a clean context, with no other instruction. Ask nothing else.

```
What concepts do you associate with '<anchor name>'?
```

Score the answer on four axes:

| Axis | Question |
|---|---|
| Recognition | Does the model know the term at all? |
| Accuracy | Are the associated concepts correct? |
| Depth | Does it go past a one-line definition? |
| Specificity | Does it separate the term from a near neighbour? |

## Verdict

| Verdict | Meaning | Action |
|---|---|---|
| `strong` | All four axes pass. | Use the bare anchor name. |
| `partial` | Recognition passes, depth or specificity fails. | Use the anchor plus a one-line normative summary. |
| `absent` | The model does not resolve the term. | Do not use it as an anchor. Inline the full instruction. |

Record the verdict in `registry.yaml` under `recognition.verified`:

```yaml
    recognition:
      verified:
        - model: claude-opus-5
          date: 2026-08-19
          verdict: strong
```

## Why this matters more than it looks

This test is the difference between an explainable system and a folk remedy. When someone
asks why the output improved, the answer is: the model resolves this term to this
published body of work, and here is the probe that shows it, on this model version, on
this date.

Re-run the whole matrix on every model upgrade. Treat a `strong` to `partial` regression
as a breaking change to the writing contract.
