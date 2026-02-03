#!/bin/bash

# Current directory and project naAPP_DIR="$(pwd)"
PROJECT_NAME="$(basename "$APP_DIR")"
VOLUME_NAME="node_modules_cache_${PROJECT_NAME//[^a-zA-Z0-9]/_}"

# Node.js image to use
NODE_IMAGE="node:22-alpine"

# Show guide
show_help() {
  echo "Uso:"
  echo "  run-node <file.js> [args...]         # Run a Node.js script "
  echo "  run-node --repl                      # Start an interactive REPL"
  echo "  run-node --install                   # Run 'npm install'"
  echo "  run-node --run <script>              # Run 'npm run <script>'"
  echo "  run-node --npx <pkg> [args...]       # Run 'npx <pkg>'"
  echo "  run-node --clean                     # Delete the cache node_modules"
  echo "  run-node --help                      # Show this message"
  exit 1
}

[ $# -eq 0 ] && show_help

case "$1" in
  --repl)
    docker run -it --rm \
      -v "$APP_DIR":/app \
      -v "$VOLUME_NAME":/app/node_modules \
      -w /app \
      "$NODE_IMAGE" \
      node
    ;;
  --install)
    docker run -it --rm \
      -v "$APP_DIR":/app \
      -v "$VOLUME_NAME":/app/node_modules \
      -w /app \
      "$NODE_IMAGE" \
      npm install
    ;;
  --run)
    shift
    [ -z "$1" ] && echo "Error: need a npm script." && exit 1
    docker run -it --rm \
      -v "$APP_DIR":/app \
      -v "$VOLUME_NAME":/app/node_modules \
      -w /app \
      "$NODE_IMAGE" \
      npm run "$@"
    ;;
  --npx)
    shift
    [ -z "$1" ] && echo "Error: need a npx package." && exit 1
    docker run -it --rm \
      -v "$APP_DIR":/app \
      -v "$VOLUME_NAME":/app/node_modules \
      -w /app \
      "$NODE_IMAGE" \
      npx "$@"
    ;;
  --clean)
    echo "🧼 Cleaning cache for $PROJECT_NAME..."
    docker volume rm "$VOLUME_NAME"
    ;;
  --help)
    show_help
    ;;
  *)
    SCRIPT="$1"
    shift
    if [ ! -f "$SCRIPT" ]; then
      echo "Error: file '$SCRIPT' not found."
      exit 2
    fi
    docker run -it --rm \
      -v "$APP_DIR":/app \
      -v "$VOLUME_NAME":/app/node_modules \
      -w /app \
      "$NODE_IMAGE" \
      node "$SCRIPT" "$@"
    ;;
esac

