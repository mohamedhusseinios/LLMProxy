# LLMProxy

LLMProxy is a native macOS application that acts as a GUI wrapper for the [LiteLLM](https://github.com/BerriAI/litellm) Python library. It allows you to easily start a local server that proxies requests to non-OpenAI models (like Gemini, Anthropic, etc.) so they can be used in tools that expect an OpenAI-compatible API (like Xcode Intelligence, Cursor, etc.).

## Features

- **Native macOS UI**: Clean, modern interface built with SwiftUI.
- **Process Management**: Start and stop the `litellm` server with a single click.
- **Live Logs**: View real-time logs from the underlying process.
- **Configuration**: Easily set model names, ports, and API keys.
- **Secure**: API keys are injected directly into the process environment and not stored in plain text files by the app (relies on macOS Keychain via SwiftUI AppStorage/SecureField).

## Prerequisites

You must have `litellm` installed on your system.

### Install via Homebrew (Recommended)

```bash
brew install litellm
```

### Install via Pip

```bash
pip install litellm
```

## Usage

1.  **Open LLMProxy**: Launch the application.
2.  **Configure**:
    - **Model Name**: Enter the model ID you want to use (e.g., `gemini/gemini-1.5-pro`, `anthropic/claude-3-opus`).
    - **Port**: Set the port for the local server (default: `4000`).
    - **API Key**: Enter your API key for the chosen provider.
    - **Env Variable Name**: Specify the environment variable name the provider expects (e.g., `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`).
    - **Mode**: Toggle **Run via Shell (zsh -l)** if you encounter "file not found" errors or if `litellm` is installed in a custom environment (like pyenv or conda).
3.  **Start Server**: Click the **Start Server** button.
    - The status indicator will turn **Green**.
    - You will see startup logs in the "Logs" section.
4.  **Connect**: Point your tool (e.g., Xcode) to `http://localhost:4000/v1` (or just `http://localhost:4000` depending on the tool).

## Troubleshooting

- **"Failed to start process: The file “litellm” doesn’t exist."**:
  - **Solution 1**: Enable **Run via Shell (zsh -l)** in the configuration. This loads your user profile and PATH, which usually finds `litellm` if it works in your terminal.
  - **Solution 2**: Use the "Custom litellm Path" field to specify the full path (e.g., `/Users/yourname/.local/bin/litellm`).
  - **Solution 3**: Ensure `litellm` is installed (`pip install litellm` or `brew install litellm`).
- **"Address already in use"**:
  - Change the **Port** to a different number (e.g., `4001`).
- **Connection Refused**:
  - Ensure the server is running (Green status).
  - Check the logs for any crash messages.

## License

MIT
