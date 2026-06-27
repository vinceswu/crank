<div align="center">

<img width="1452" height="352" alt="crank" src="https://github.com/user-attachments/assets/bda075e8-8cb2-42c8-9e8b-6c7faa205774" />

</div>

<p align="center">
  <a href="https://github.com/vinceswu/crank/stargazers">
    <img src="https://img.shields.io/github/stars/vinceswu/crank?style=flat-square">
  </a>
  <a href="https://github.com/vinceswu/crank/issues">
    <img src="https://img.shields.io/github/issues/vinceswu/crank?style=flat-square">
  </a>
  <a href="https://github.com/vinceswu/crank/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/vinceswu/crank?style=flat-square">
  </a>
  <a href="https://github.com/ecnivslabs/olive">
    <img src="https://img.shields.io/badge/language-Olive-informational?style=flat-square">
  </a>
</p>

## Overview

**Crank** takes a topic and generates a complete YouTube Short (video and metadata) ready for upload. It's written in [Olive](https://github.com/ecnivslabs/olive), a fast compiled language that keeps the pipeline lean and the output predictable.

## Prerequisites

- **Olive >= 0.4.3** (see installation below)
- **Python 3.x** with dependencies from `requirements.txt`
- `ffmpeg` and `ffprobe` in your system PATH

#### Environment Variables

Create a `.env` file in the project root:

```ini
GEMINI_API_KEY=your_api_key_here
```

#### Credential Files

- `secrets.json`: OAuth 2.0 client credentials for YouTube API upload

## Customization

#### `config/preset.yml`

| Key | Description |
|-----|-------------|
| `NAME` | Channel name |
| `PROMPT` | Topic or idea to base the generated video on |
| `UPLOAD` | `true` or `false` to enable/disable uploads |
| `DELAY` | Hours between uploads (`0` for instant, positive number to schedule) |
| `GEMINI_API_KEY` | Channel-specific API key (overrides `.env` if set) |
| `WHISPER_MODEL` | Whisper model size (`tiny`, `base`, `small`, `medium`, `large-v1/v2/v3`) |
| `OAUTH_PATH` | Path to OAuth credentials (defaults to `secrets.json`) |
| `FONT` | Caption font (defaults to `Comic Sans MS`) |

#### `config/prompt.yml`

| Key | Description |
|-----|-------------|
| `GET_CONTENT` | Guidelines for generating the transcript |
| `GET_TITLE` | Guidelines for generating the title |
| `GET_SEARCH_TERM` | YouTube search term for background video scraping |
| `GET_DESCRIPTION` | Guidelines for generating the description |
| `GET_CATEGORY_ID` | Guidelines for generating the category ID |

## Installation

### Olive

**Linux / macOS:**
```bash
curl -sSL https://raw.githubusercontent.com/ecnivslabs/olive/master/install.sh | sh
```

**Windows:** download from the [releases page](https://github.com/ecnivslabs/olive/releases/latest)

### Crank

**Linux / macOS (one-liner):**
```bash
curl -sSL https://raw.githubusercontent.com/vinceswu/crank/master/install.sh | sh
```

**Or clone and build from source:**
```bash
git clone https://github.com/vinceswu/crank.git
cd crank
pip install -r requirements.txt
```

**Install ffmpeg:**
```bash
# Debian / Ubuntu
sudo apt install ffmpeg

# Arch Linux
sudo pacman -S ffmpeg

# macOS
brew install ffmpeg

# Windows (Chocolatey)
choco install ffmpeg
```

**Download spaCy model:**
```bash
python -m spacy download en_core_web_md
```

## Running Crank

```bash
# Default config
pit run

# Custom config path
pit run --path path/to/your_config.yml
```

## Example Output

<div align="center">

https://github.com/user-attachments/assets/69b1dc3d-79f2-4a6f-bde1-da6c07e32185

</div>

## Support the project

<div align="center">
  <a href="https://www.buymeacoffee.com/ecnivs" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>
</div>

## Plugin Development

For information about creating custom background video plugins, see [PLUGIN_GUIDE.md](docs/PLUGIN_GUIDE.md).

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes (`git commit -m 'add my feature'`)
4. Push to the branch (`git push origin feature/my-feature`)
5. Submit a pull request

#### *I'd appreciate any feedback or code reviews you might have!*
