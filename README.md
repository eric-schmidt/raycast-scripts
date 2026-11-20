# raycast-scripts

Personal [Raycast Script Commands](https://github.com/raycast/script-commands): small scripts that Raycast runs from its search bar or a hotkey.

## Scripts

| Script | What it does |
|---|---|
| [`crest-search-spaces.applescript`](crest-search-spaces.applescript) | Opens the [Crest](https://crestbrowser.com) browser's command palette already filtered to `@spaces`. |

## Installing

These steps apply to every script in this repo.

1. Clone the repo and make the scripts executable. Raycast ignores script files without the executable bit.

   ```sh
   git clone https://github.com/eric-schmidt/raycast-scripts.git ~/Projects/raycast-scripts
   chmod +x ~/Projects/raycast-scripts/*.applescript
   ```

2. In Raycast **Settings → Extensions → Script Commands**, add the cloned folder to **Script Folders**.
3. Run **Reload Script Directories** from the Raycast search bar. The scripts appear under their package name (for example, "Crest").
4. To give a script a hotkey, find it in **Settings → Extensions** and click its **Hotkey** cell.

When you add a new script, run `chmod +x` on it and reload the script directories.

---

## Search Crest Spaces

**Hotkey:** ⌃F (suggested) · **Package:** Crest · **Mode:** silent

### Why

Arc had a Raycast extension that searched across all Spaces from one hotkey. Crest has the same view, but you reach it through the command palette: press ⌘L (or ⌘T/⌘K), type `@spaces`, then press Space. This script does those steps for you, so one key takes you from any app to the Spaces list.

Crest has nothing simpler to hook into:

- No command in Crest's own shortcut settings opens the palette pre-filtered. The Spaces menu only has Previous/Next Space and Select Space 1–9.
- No menu item exists to bind with macOS App Shortcuts.
- Its AppleScript dictionary is the stock Chromium one, with no Spaces.
- There's no `crest://` URL scheme.

### How it works

1. **Bring Crest forward,** then wait until it's actually the frontmost app.
2. **Open a window if none is open** (⌘N). The window count comes from System Events, because Crest's own scripting dictionary fails on `count of windows` (error -1708).
3. **Open the command palette** with ⌘L, but only if it isn't already open. ⌘L toggles the palette, so pressing it again would close it.
4. **Wait for the palette's text field to have focus.** The field is the `AXTextField` whose accessibility description is "Command Palette". Keys typed before the palette is ready are lost, so the script polls for focus instead of using a fixed delay.
5. **Type `@spaces `.** The trailing space applies the filter.

If the palette never gets focus (about 2 seconds), the script stops without typing. That way `@spaces ` can't land in a form field on the page.

### Requirements

- Crest for macOS. Tested with 0.10.8.
- On first run, macOS asks to let Raycast control **System Events**. Allow it. Also make sure Raycast is on under System Settings → Privacy & Security → **Accessibility**. Without both, Crest comes forward but nothing is typed.

### Troubleshooting

- **Crest comes forward, but no palette opens:** check the two permissions above. Silent mode hides script errors, so run the script in a terminal to see them:

  ```sh
  osascript ~/Projects/raycast-scripts/crest-search-spaces.applescript; echo "exit: $?"
  ```

- **⌃F stops moving the cursor in text fields:** Raycast hotkeys apply in every app, so ⌃F no longer does "move forward one character" in text fields. If you rely on that, use ⌃⌥F or a Hyper key instead.
- **`@spaces` shows up as search text:** this happens when the palette was already open in the Spaces view. Press Escape to clear it.
- **Crest changes its palette:** the script depends on Crest's ⌘L shortcut and on the field's "Command Palette" description. If an update renames either one, the script stops quietly. Update `paletteFocused()` to match.
