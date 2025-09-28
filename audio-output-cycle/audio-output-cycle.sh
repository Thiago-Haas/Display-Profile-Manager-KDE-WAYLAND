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
