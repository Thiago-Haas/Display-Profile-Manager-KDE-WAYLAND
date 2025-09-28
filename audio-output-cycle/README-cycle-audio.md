# Audio Output Cycle Shortcut for KDE (PulseAudio/PipeWire)

This script allows you to **cycle between available audio outputs (sinks)** on Linux systems using **PulseAudio** or **PipeWire**.  
It sets the next sink as the default output and moves all active audio streams to it.

---

## Features
- Cycles through all available audio outputs (`pactl list short sinks`).
- Automatically wraps back to the first output after the last one.
- Moves all current streams to the new default sink.
- Sends a desktop notification (`notify-send`) with the selected sink.

---

## Requirements
- `pactl` (comes with PulseAudio or PipeWire).
- `notify-send` (usually from `libnotify-bin` package).

Install dependencies on Ubuntu/Kubuntu:
```bash
sudo apt install libnotify-bin
```

---

## Installation
1. Save the script as `~/bin/cycle-audio.sh` (or any path in your `$PATH`).
2. Make it executable:
   ```bash
   chmod +x ~/bin/cycle-audio.sh
   ```

---

## Usage
Run manually:
```bash
~/bin/cycle-audio.sh
```

Each run switches to the next available output device.

---

## KDE Global Shortcut
1. Open **System Settings → Shortcuts → Custom Shortcuts**.
2. Add **New → Global Shortcut → Command/URL**.
3. Choose a trigger (e.g., `Meta+F8`).
4. Set the action command:
   ```bash
   ~/bin/cycle-audio.sh
   ```
5. Apply and test.

---

## Example Script
```bash
#!/usr/bin/env bash
# cycle-audio.sh
# Cycles through available PulseAudio/PipeWire sinks

# List all sinks
sinks=($(pactl list short sinks | awk '{print $2}'))

# Get current default sink
current=$(pactl get-default-sink)

# Find index of current sink
index=-1
for i in "${!sinks[@]}"; do
  if [[ "${sinks[$i]}" == "$current" ]]; then
    index=$i
    break
  fi
done

# Compute next index (wrap around)
if [[ $index -ge 0 ]]; then
  next=$(( (index + 1) % ${#sinks[@]} ))
else
  next=0
fi

# Set new default sink
pactl set-default-sink "${sinks[$next]}"

# Move currently playing streams to new sink
pactl list short sink-inputs | while read -r input; do
  input_id=$(echo $input | awk '{print $1}')
  pactl move-sink-input "$input_id" "${sinks[$next]}"
done

notify-send "Audio Output Changed" "Now using: ${sinks[$next]}"
```

---

## License
MIT
