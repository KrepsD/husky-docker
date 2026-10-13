#!/usr/bin/env python3
"""Populate the Gazebo Fuel cache before launching a world with remote models."""

import os
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote, urlsplit
from xml.etree import ElementTree


def main() -> None:
    world = sys.argv[1]
    if not re.fullmatch(r"[a-z0-9_]+", world):
        raise SystemExit(f"Invalid Gazebo world name: {world!r}")

    sdf = Path("/opt/ros/jazzy/share/clearpath_gz/worlds") / f"{world}.sdf"
    if not sdf.is_file():
        raise SystemExit(f"Gazebo world not found: {sdf}")

    root = ElementTree.parse(sdf).getroot()
    urls = dict.fromkeys(
        uri.text.strip()
        for uri in root.findall(".//include/uri")
        if uri.text and uri.text.strip().startswith("https://fuel.gazebosim.org/")
    )
    if urls:
        print(f"Preparing {len(urls)} Gazebo Fuel models for {world}...", flush=True)
    cache = Path(os.environ.get("GZ_FUEL_CACHE_PATH", Path.home() / ".gz/fuel"))
    for url in urls:
        parsed = urlsplit(url)
        parts = [unquote(part).lower() for part in parsed.path.strip("/").split("/")]
        if len(parts) == 4 and parts[0] == "1.0" and parts[2] == "models":
            model_dir = cache / parsed.hostname.lower() / parts[1] / "models" / parts[3]
            if model_dir.is_dir() and any(
                (version / "model.sdf").is_file()
                and (version / "model.config").is_file()
                for version in model_dir.iterdir()
                if version.is_dir()
            ):
                print(f"  cached: {url}", flush=True)
                continue
        print(f"  {url}", flush=True)
        subprocess.run(["gz", "fuel", "download", "--url", url], check=True)


if __name__ == "__main__":
    main()
