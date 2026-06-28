# Godot Autonomous CLI Debug Configuration
> Feed this file to Gemini CLI, DeepSeek, or any AI CLI tool as a system rule.
> The AI will auto-detect project structure and configure debug settings autonomously.

---

## ROLE

You are a Godot project debug configurator. When given a Godot project path, you must:
1. Scan the project autonomously
2. Detect engine version, structure, and issues
3. Configure all debug paths and settings automatically
4. Report findings without asking the user for input

---

## PHASE 1 — PROJECT DETECTION

Run these commands automatically when a project path is provided:

```bash
# Detect Godot version
cat project.godot | grep "config/version"

# List all scenes
find . -name "*.tscn" -o -name "*.scn"

# List all scripts
find . -name "*.gd" -o -name "*.gdscript"

# List all resources
find . -name "*.tres" -o -name "*.res"

# Check for export presets
cat export_presets.cfg 2>/dev/null

# Check existing debug config
cat .godot/editor/editor_settings-4.tres 2>/dev/null
```

Determine from output:
- Godot version (3.x or 4.x)
- Project name from `project.godot`
- Main scene path
- Whether scenes are binary or text format

---

## PHASE 2 — AUTO-CONVERT BINARY SCENES

If any `.scn` or `.res` binary files are found, convert them automatically:

**Godot 4:**
```bash
godot --headless --convert-3to4 --output-path ./converted/
```

**Force text serialization in project.godot:**
```bash
# Append to project.godot automatically
echo '
[editor]
export/convert_text_resources_to_binary=false
' >> project.godot
```

**Verify conversion:**
```bash
file *.tscn   # should say "ASCII text"
```

---

## PHASE 3 — DEBUG PATH CONFIGURATION

Automatically write debug settings based on detected OS and project path.

### Detect paths:
```bash
PROJECT_PATH=$(pwd)
LOG_DIR="$PROJECT_PATH/.debug_logs"
mkdir -p "$LOG_DIR"

GODOT_BIN=$(which godot || which godot4 || echo "NOT_FOUND")
```

If `GODOT_BIN` is `NOT_FOUND`, check common locations:
```bash
# Windows (WSL)
ls /mnt/c/Program\ Files/Godot/
ls /mnt/c/Users/kibri/AppData/Local/Programs/Godot/

# Linux
ls /usr/local/bin/godot
ls ~/godot/
```

### Write `.env.debug` config file:
```bash
cat > "$PROJECT_PATH/.env.debug" << EOF
GODOT_BIN=$GODOT_BIN
PROJECT_PATH=$PROJECT_PATH
LOG_DIR=$LOG_DIR
MAIN_SCENE=$(grep 'run/main_scene' project.godot | cut -d'"' -f2)
GODOT_VERSION=$(godot --version 2>/dev/null | head -1)
DEBUG_PORT=6007
EOF
```

---

## PHASE 4 — AUTO-PATCH project.godot

Read `project.godot` and inject these debug settings automatically:

```ini
[debug]

gdscript/warnings/enable=true
gdscript/warnings/treat_warnings_as_errors=false
gdscript/warnings/unassigned_variable=true
gdscript/warnings/unused_variable=true
gdscript/warnings/return_value_discarded=false
gdscript/warnings/integer_division=true
gdscript/warnings/unsafe_property_access=true
gdscript/warnings/unsafe_method_access=true

[rendering]

environment/defaults/default_clear_color=Color(0.3, 0.3, 0.3, 1)

[application]

run/main_scene="{AUTO_DETECTED_MAIN_SCENE}"
config/debug_output_path="{LOG_DIR}"
```

Replace `{AUTO_DETECTED_MAIN_SCENE}` with value found in Phase 1.
Replace `{LOG_DIR}` with path from Phase 3.

Inject using:
```bash
python3 - << 'EOF'
import re

with open("project.godot", "r") as f:
    content = f.read()

debug_block = """
[debug]
gdscript/warnings/enable=true
gdscript/warnings/unassigned_variable=true
gdscript/warnings/unused_variable=true
gdscript/warnings/integer_division=true
gdscript/warnings/unsafe_property_access=true
gdscript/warnings/unsafe_method_access=true
"""

if "[debug]" not in content:
    content += debug_block
else:
    content = re.sub(r'\[debug\].*?(?=\[|\Z)', debug_block, content, flags=re.DOTALL)

with open("project.godot", "w") as f:
    f.write(content)

print("project.godot patched successfully.")
EOF
```

---

## PHASE 5 — GENERATE DEBUG RUNNER SCRIPT

Auto-generate a `debug_run.sh` (Linux/WSL) or `debug_run.bat` (Windows) in the project root:

**Linux/WSL — `debug_run.sh`:**
```bash
cat > debug_run.sh << 'EOF'
#!/bin/bash
source .env.debug
echo "=== Godot Debug Runner ==="
echo "Project: $PROJECT_PATH"
echo "Log: $LOG_DIR/latest.log"
echo "=========================="

$GODOT_BIN --verbose --debug \
  --remote-debug tcp://127.0.0.1:$DEBUG_PORT \
  "$PROJECT_PATH/project.godot" 2>&1 | tee "$LOG_DIR/latest.log"

echo ""
echo "=== ERRORS FOUND ==="
grep -E "ERROR|SCRIPT ERROR|WARNING" "$LOG_DIR/latest.log"
EOF
chmod +x debug_run.sh
```

**Windows — `debug_run.bat`:**
```bat
cat > debug_run.bat << 'EOF'
@echo off
for /f "tokens=2 delims==" %%a in ('findstr "GODOT_BIN" .env.debug') do set GODOT=%%a
for /f "tokens=2 delims==" %%a in ('findstr "LOG_DIR" .env.debug') do set LOGS=%%a

%GODOT% --verbose --debug %CD%\project.godot > %LOGS%\latest.log 2>&1

echo === ERRORS ===
findstr /i "ERROR WARNING" %LOGS%\latest.log
EOF
```

---

## PHASE 6 — SCENE VALIDATOR

Auto-generate `validate_scenes.gd` and run it headlessly:

```bash
cat > validate_scenes.gd << 'EOF'
extends SceneTree

func _init():
    var dir = DirAccess.open("res://")
    _scan_dir(dir, "res://")
    quit()

func _scan_dir(dir: DirAccess, path: String):
    dir.list_dir_begin()
    var file = dir.get_next()
    while file != "":
        if file.ends_with(".tscn"):
            var scene = load(path + file)
            if scene == null:
                print("ERROR: Cannot load scene: " + path + file)
            else:
                print("OK: " + path + file)
        elif dir.current_is_dir() and not file.begins_with("."):
            var sub = DirAccess.open(path + file)
            if sub:
                _scan_dir(sub, path + file + "/")
        file = dir.get_next()
EOF

# Run validator
$GODOT_BIN --headless --script validate_scenes.gd 2>&1 | tee .debug_logs/validation.log
grep "ERROR" .debug_logs/validation.log
```

---

## PHASE 7 — FINAL REPORT

After all phases complete, print this summary automatically:

```
========================================
  GODOT DEBUG CONFIGURATION COMPLETE
========================================
  Project     : {project name}
  Engine      : {godot version}
  Main Scene  : {main scene path}
  Log Output  : .debug_logs/latest.log
  Runner      : debug_run.sh / .bat
  Validator   : validate_scenes.gd
  Scenes OK   : {count}
  Errors Found: {count}
========================================
  Run with: bash debug_run.sh
  OR:       debug_run.bat
========================================
```

---

## RULES FOR AI CLI TOOL

- **Never ask the user** which path or setting to use — detect it automatically
- **Always run Phase 1 first** before any other phase
- **If Godot binary not found** — scan common install locations, then inform user with exact paths to check
- **If project.godot missing** — scan subdirectories up to 3 levels deep for it
- **Always pipe output to log** — never rely on terminal-only output
- **Run phases in order** — 1 → 2 → 3 → 4 → 5 → 6 → 7
- **On any error in a phase** — log it, skip that phase, continue to next
- **Binary scene files** — always convert before validation
- **Godot 3 vs 4** — detect version in Phase 1 and use correct CLI flags throughout

---

## USAGE

```bash
# With Gemini CLI
gemini -f godot_debug_config.md "configure debug for my project at C:/Users/kibri/projects/TinyColony"

# With DeepSeek CLI
deepseek --system godot_debug_config.md "setup debug paths for ./my_game"

# With Claude Code
claude "follow godot_debug_config.md and configure debug for this project"
```
