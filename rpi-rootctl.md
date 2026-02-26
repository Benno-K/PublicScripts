# rpi-rootctl

`rpi-rootctl` is a small, defensive command-line utility for Raspberry Pi systems with **multiple bootable root filesystems** (A/B setups).

It allows you to **safely switch the root filesystem for the next boot** by updating `/boot/cmdline.txt` to point to a different `root=PARTUUID=...`.

A short symlink alias `r2c` ("root to change") can be used for convenience.

---

## Features

- Detects all candidate root filesystem partitions
- Shows detailed information (device, filesystem, size, transport, model)
- Highlights the currently booted root filesystem
- Interactive selection
- Automatic backup of `/boot/cmdline.txt`
- Strict option handling
- `--dry-run` mode (no changes)

---

## Usage

```bash
rpi-rootctl [OPTION]
```

### Options

- `--dry-run`, `-dry`, `-3`
  - Show the modified `cmdline.txt` on stdout
  - Do **not** write any changes

- `--version`
  - Show version information and exit

- `-h`, `--help`
  - Show help and exit

---

## Installation

```bash
sudo install -m 0755 rpi-rootctl /usr/local/sbin/rpi-rootctl
sudo ln -s rpi-rootctl /usr/local/sbin/r2c
```

---

## Safety Notes

Changing the root filesystem affects system boot.
Always keep a known-good fallback.
