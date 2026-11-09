#!/usr/bin/env python3
"""Aggiorna i 117 canali M3U conservando l'ordine, il link e i nomi."""
from __future__ import annotations

import re
import urllib.request
from pathlib import Path

SOURCE = "https://raw.githubusercontent.com/Free-TV/IPTV/master/playlists/playlist_italy.m3u8"
TARGET = Path("italia-117.m3u")
EXPECTED_CHANNELS = 117


def parse_m3u(text: str) -> list[dict[str, str]]:
    lines = text.splitlines()
    result = []
    for i, line in enumerate(lines):
        if not line.startswith("#EXTINF:"):
            continue
        # I metadati possono contenere una virgola nei valori; l'ultima
        # virgola separa sempre il nome visibile del canale.
        attr, sep, label = line.rpartition(",")
        if not sep:
            continue
        url = ""
        for next_line in lines[i + 1 : i + 5]:
            if next_line.startswith("#EXTINF:"):
                break
            if next_line.strip().startswith(("https://", "http://")):
                url = next_line.strip()
                break
        if not url:
            continue

        def field(name: str) -> str:
            match = re.search(r'\b' + re.escape(name) + r'="([^"]*)"', attr)
            return match.group(1) if match else ""

        name = re.sub(r"\s+", " ", re.sub(r"[ⒼⓈ]", "", label)).strip()
        result.append({"name": name, "url": url, "logo": field("tvg-logo"), "id": field("tvg-id")})
    return result


def key(name: str) -> str:
    return "".join(c for c in name.casefold() if c.isalnum())


def render(channels: list[dict[str, str]]) -> str:
    def escape(value: str) -> str:
        return value.replace('"', "&quot;")

    out = ["#EXTM3U"]
    for idx, channel in enumerate(channels, 1):
        name = channel["name"]
        out.append(
            f'#EXTINF:-1 tvg-chno="{idx}" tvg-id="{escape(channel["id"])}" '
            f'tvg-name="{escape(name)}" tvg-logo="{escape(channel["logo"])}" '
            f'group-title="Italia",{name}'
        )
        out.append(channel["url"])
    return "\n".join(out) + "\n"


def main() -> None:
    current = parse_m3u(TARGET.read_text(encoding="utf-8"))
    if len(current) != EXPECTED_CHANNELS or len({key(x["name"]) for x in current}) != EXPECTED_CHANNELS:
        raise RuntimeError("Playlist esistente non valida: il file non sarà modificato.")

    request = urllib.request.Request(SOURCE, headers={"User-Agent": "Mozilla/5.0 (playlist-updater)"})
    with urllib.request.urlopen(request, timeout=35) as response:
        remote_text = response.read(2_000_000).decode("utf-8-sig")
    remote = parse_m3u(remote_text)
    if len(remote) < 100:
        raise RuntimeError("La sorgente contiene troppo pochi canali: nessuna modifica.")

    # Il primo stream per ogni emittente viene preferito, come nel file originale.
    candidates = {}
    for channel in remote:
        candidates.setdefault(key(channel["name"]), channel)

    updated = []
    changed = 0
    missing = []
    for previous in current:
        candidate = candidates.get(key(previous["name"]))
        if not candidate:
            missing.append(previous["name"])
            updated.append(previous)
            continue
        new = {
            "name": previous["name"],
            "url": candidate["url"],
            "logo": candidate["logo"] or previous["logo"],
            "id": candidate["id"] or previous["id"],
        }
        if new["url"] != previous["url"]:
            changed += 1
        updated.append(new)

    result = render(updated)
    if len(parse_m3u(result)) != EXPECTED_CHANNELS:
        raise RuntimeError("Controllo dei 117 canali fallito: nessuna modifica.")
    if result != TARGET.read_text(encoding="utf-8"):
        TARGET.write_text(result, encoding="utf-8")
    print(f"Canali mantenuti: {len(updated)} | URL modificati: {changed} | Non trovati nella sorgente: {len(missing)}")
    if missing:
        print("URL originali mantenuti per: " + ", ".join(missing))


if __name__ == "__main__":
    main()
