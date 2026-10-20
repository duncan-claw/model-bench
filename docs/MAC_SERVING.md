# Serving models on the MacBook Pros: oMLX + Splash (the one standard)

**Agreed with Mark, 2026-10-20.** This is the only supported way to run, restart or upgrade model serving on the
MBP-14 and the MBP-16. Any agent changing oMLX or Splash follows this file, and updates it if something changes.
**Don't** open the oMLX desktop app, don't install oMLX another way (Homebrew, pip), and don't run
`oMLX.app/Contents/MacOS/oMLX --version`: that binary has no such option and opens a second copy of the app.

## The setup (both Macs)

| | MBP-14 | MBP-16 |
|---|---|---|
| SSH | `mark@` (Tailscale) | `mrich@mbp-16-m1-max-64gb` |
| oMLX | `/Applications/oMLX.app`, run **headless** by launchd | same |
| Service | `~/Library/LaunchAgents/com.omlx.server.plist`, label `com.omlx.server` | same |
| Command | `omlx-cli serve --host 0.0.0.0 --port 10240` (everything else from `~/.omlx/settings.json`). **Don't add `--headless`:** it removes the admin web page (`/admin`); launchd already means no menu-bar app | `omlx-cli serve --host 0.0.0.0 --port 10240 --memory-guard balanced --memory-guard-gb 52 --api-key …` |
| Service log | `~/Library/Logs/omlx-server.log` | same |
| oMLX log | `~/.omlx/logs/server.log` (rotated daily) | same |
| Settings | `~/.omlx/settings.json` (global), `~/.omlx/model_settings.json` (per model) | same |
| Models | `~/shared-models` | `~/shared-models` |
| Splash | engine for Qwen3.8 / Qwen3.6 / Ornith-family models, started by oMLX per model (`external_engine: splash`). Installed in `~/Library/Application Support/Splash-M1/`; `/opt/homebrew/bin/splash-m1` is its 3-line launcher, not a second oMLX | same |
| Power | lid open, desktop also in use | **headless, lid closed**: `pmset disablesleep 1, hibernatemode 0, standby 0`; High Power Mode (16-inch only) |

There is no menu-bar app running on either Mac. One `omlx-server` process listens on port 10240.

## Differences kept on purpose

- **MBP-16 allows inference without an API key** (`auth.allow_unauthenticated_inference: true`): Surface Oracle's
  "ollama" provider sends no key, and the earthcore and demo tenants use this Mac. Review reminder set for
  2026-10-24. Everything else (model-bench, pi, SMS triage) sends the key.
- **MBP-16 embedding batch size 1:** at 32, oMLX returned null vectors for Surface Oracle (its `script/README.md`).
- **Splash disk cache:** MBP-14 100 GB (211 GB free), MBP-16 372 GB.
- **Pinned models:** MBP-14 `mlx-community--Qwen3.8-27B-4bit` + MarkItDown; MBP-16 `mlx-community--Qwen3.6-35B-A3B-4bit`
  + `nomicai-modernbert-embed-base-8bit` + MarkItDown (SMS triage, Surface Oracle).

**Engine per builder (2026-10-20, `experiments/mbp-parity/`):** Qwen3.8-27B 4-bit on **Splash**; Qwen3.6-35B-A3B 8-bit on
oMLX's **plain engine** (on Splash it loops on multi-turn agentic work from a cold start: 0 of 16).

**Benchmarks and ladder attempts start from a known state:** models unloaded and the builder's Splash cache emptied
(`bin/ladder` does this), with macOS, oMLX version and engine recorded in each result. Splash's output at temperature 0
can depend on what it processed before, so warm-state results aren't comparable.

Builder models must have identical per-model settings on both Macs (`model_settings.json`); compare before any
benchmark that splits work across the Macs.

## Day-to-day

```sh
# status
launchctl print gui/$(id -u)/com.omlx.server | grep -E "state|pid"
curl -s localhost:10240/health
# restart (picks up settings.json changes; model_settings changes also apply via /admin/api/reload)
launchctl kickstart -k gui/$(id -u)/com.omlx.server
# stop / start
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.omlx.server.plist
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.omlx.server.plist
# version (never run the app binary for this)
defaults read /Applications/oMLX.app/Contents/Info CFBundleShortVersionString
```

Read the API key from `~/.omlx/settings.json` (`auth.api_key`) on the Mac itself; never print it or copy it elsewhere.

## Changing settings

1. Back up first: `cp -p ~/.omlx/settings.json ~/.omlx/settings.json.bak-$(date +%Y%m%d-%H%M)` (same for
   `model_settings.json`).
2. Edit the JSON (or the oMLX admin page). Per-model changes apply on `POST /admin/api/reload` and the next model load;
   **global settings (cache sizes, memory guard) need a service restart.**
3. Check: load the model and read its `Splash: starting …` line in `~/.omlx/logs/server.log` for the flags it got.
4. Record the change and why in `DECISIONS.md` (model-bench) if it affects benchmarks or builders.

## Upgrading oMLX or Splash

1. Ask Mark first. Upgrade one Mac, check it, then the other, so both end on the same version.
2. Stop the service, replace `/Applications/oMLX.app` (or run Splash's installer), start the service.
3. Check: `curl localhost:10240/health`, load each builder model, compare its Splash launch flags with the other Mac,
   and run a 12-minute model-bench check (`bin/bench --screens coding` for Qwen3.8-27B 4-bit).
4. Update this file's table and the version line below.

**Versions (2026-10-20, 22:30):** oMLX 0.7.1rc1, Splash M1 1.3.2-m1.1 and **macOS 27.0.1 on both Macs**. The MBP-14 was upgraded from 26.6.2 that evening; after the upgrade Qwen3.8-27B 4-bit passed and failed exactly the same 161 problems as before (136/161, 4.3 s per answer; `results/2026-10-20-mbp14-macos27/`). Earlier: MBP-14 26.6.2,
MBP-16 27.0.1 (upgraded for Darkbloom, now disabled: both its launch agents are disabled and nothing runs). Decide
whether to bring the MBP-14 to 27 (check the media studio first).

## History

- 2026-10-18: MBP-16 made a single headless service (oMLX had been running twice, about 30 GB wasted), upgraded to
  0.7.1rc1, Qwen3.8-27B 4-bit moved to Splash (about 2.5× faster generation).
- 2026-10-20: MBP-14 found running the desktop app (started by hand 2026-10-17, not headless) plus a stray second
  copy an agent opened with `oMLX --version`. Stray closed; MBP-14 moved to the same headless service. Qwen3.6-35B-A3B
  8-bit moved to Splash on the MBP-16, matching the MBP-14. This runbook written.
- 2026-10-20 (late): MBP-14 upgraded to macOS 27.0.1. The service came back by itself. Removed `--headless` from its
  service (it had hidden the admin page). Default model set to Qwen3.8-27B 4-bit (none was set; oMLX fell back to
  Gemma-4-19B). Post-upgrade check: 161/161 problems identical to before.
