# Plugin Development Guide

## Overview

The Crank plugin system lets you swap out the background video generator with any custom strategy. Each plugin is a self-contained Olive module that implements `BackgroundVideoPlugin` and registers a factory function with the registry at startup.

## Architecture

```
User Input → Core → PluginRegistry → Plugin Instance → Background Video
```

1. **Core** reads `BACKGROUND_PLUGIN` from `preset.yml` (defaults to `"default"`)
2. **PluginRegistry** looks up the factory registered under that name
3. The factory creates a **Plugin Instance** with a workspace directory
4. The instance's `get_media` is called with the full pipeline data dictionary

## Plugin Structure

```
plugins/
└── your_plugin/
    ├── plugin.liv      # Required
    └── config.yml      # Optional
```

The directory name is the plugin identifier and must match the value set in `preset.yml`.

## Creating a Plugin

### Step 1: Implement the plugin

Create `plugins/your_plugin/plugin.liv`:

```olive
from plugins.base import BackgroundVideoPlugin
import io
import yaml
import logging

const PLUGIN_CONFIG = "plugins/your_plugin/config.yml"

struct YourPlugin:
    workspace: str

impl BackgroundVideoPlugin for YourPlugin:
    fn get_media(self, data: {str: Any}) -> str:
        let search_term = str(data.get("search_term", ""))
        // generate or download your background video
        let video_path = self.workspace + "/background.mp4"
        // ... your logic here ...
        video_path

    fn get_prompt_context(self, _topic: str) -> str:
        // optional: inject instructions into the Gemini prompt
        ""

impl YourPlugin:
    fn __init__(self, workspace: str):
        self.workspace = workspace
        io.mkdir(workspace)

fn make_your_plugin(workspace: str) -> BackgroundVideoPlugin:
    YourPlugin(workspace)
```

### Step 2: Register the factory

In `src/core/app.liv`, import your factory and register it:

```olive
from plugins.your_plugin.plugin import make_your_plugin

// inside Core.__init__, after the existing registry.register call:
registry.register("your_plugin", make_your_plugin)
```

### Step 3: Enable it

In `config/preset.yml`:

```yaml
BACKGROUND_PLUGIN: your_plugin
```

### Step 4: Optional config

Create `plugins/your_plugin/config.yml`:

```yaml
api_key: your_api_key_here
style: cinematic
```

Load it inside `__init__`:

```olive
fn _load_config(self):
    if not io.exists(PLUGIN_CONFIG):
        return
    let raw = yaml.parse(io.read_file(PLUGIN_CONFIG))
    if raw == None:
        return
    let parsed: {str: Any} = raw
    // read your keys from parsed
```

## Interface Reference

### `get_media(self, data: {str: Any}) -> str`

Core method. Receives the full pipeline data and returns the path to a background video file. Return `""` to signal failure.

#### `data` keys

| Key | Type | Description |
|-----|------|-------------|
| `transcript` | `str` | Generated voiceover script |
| `title` | `str` | Generated video title |
| `description` | `str` | Generated video description |
| `search_term` | `str` | YouTube search term derived from the topic |
| `categoryId` | `str` | YouTube category ID |
| `audio_path` | `str` | Absolute path to the voiceover `.wav` file |
| `captions_path` | `str` | Absolute path to the `.ass` subtitle file |
| `caption_data` | `{str: Any}` | Word-level transcription data (see below) |

#### `caption_data` structure

```
{
    "text": "Full transcript...",
    "segments": [
        {
            "start": 0.0,
            "end": 2.5,
            "text": "Welcome to...",
            "words": [
                {"word": "Welcome", "start": 0.0, "end": 0.5},
                ...
            ]
        }
    ]
}
```

### `get_prompt_context(self, topic: str) -> str`

Optional. Return a string to append extra instructions to the Gemini prompt before the script is generated. Return `""` to add nothing.

```olive
fn get_prompt_context(self, _topic: str) -> str:
    "Write the script in short, punchy sentences."
```

## Example Plugins

### Minimal scraper

```olive
struct SimplePlugin:
    workspace: str

impl BackgroundVideoPlugin for SimplePlugin:
    fn get_media(self, data: {str: Any}) -> str:
        let term = str(data.get("search_term", ""))
        // download a video matching term into workspace
        self.workspace + "/video.mp4"

    fn get_prompt_context(self, _topic: str) -> str:
        ""

impl SimplePlugin:
    fn __init__(self, workspace: str):
        self.workspace = workspace
        io.mkdir(workspace)

fn make_simple(workspace: str) -> BackgroundVideoPlugin:
    SimplePlugin(workspace)
```

### Persona injection

```olive
fn get_prompt_context(self, _topic: str) -> str:
    "Write the script as a roast. Be sarcastic and funny."
```

## Troubleshooting

- **Plugin not found at startup**: verify the name passed to `registry.register` matches `BACKGROUND_PLUGIN` in `preset.yml` exactly.
- **`get_media` never called**: check that `Core.__init__` registers your factory before `registry.get_plugin` is called.
- **Empty video path**: returning `""` from `get_media` causes the pipeline to abort with an error — make sure your video generation succeeds before returning.
