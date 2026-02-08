"""
Google Image Scraping – Demonstration Utility

Purpose:
---------
This script demonstrates basic web scraping techniques
to programmatically download images using:
- HTTP requests
- HTML parsing (BeautifulSoup)
- Binary file handling

⚠️ Disclaimer:
---------------
This is a small-scale, educational utility.
Google Images HTML structure may change at any time.
Not intended for large-scale or commercial scraping.
"""

import os
import time
import requests
from bs4 import BeautifulSoup
from urllib.parse import quote_plus


HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/120.0 Safari/537.36"
    )
}


def download_google_images(
    query: str,
    save_dir: str = "images",
    max_images: int = 20,
    delay: float = 1.0,
):
    """
    Download images from Google Images search results.

    Parameters
    ----------
    query : str
        Search query term
    save_dir : str
        Directory to save downloaded images
    max_images : int
        Maximum number of images to download
    delay : float
        Delay between requests (seconds)
    """

    os.makedirs(save_dir, exist_ok=True)

    encoded_query = quote_plus(query)
    url = f"https://www.google.com/search?q={encoded_query}&tbm=isch"

    response = requests.get(url, headers=HEADERS, timeout=10)
    response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")
    img_tags = soup.find_all("img")

    # First image is usually Google logo → skip
    img_tags = img_tags[1:max_images + 1]

    print(f"Found {len(img_tags)} image tags for query: '{query}'")

    for idx, img in enumerate(img_tags, start=1):
        src = img.get("src")

        if not src or not src.startswith("http"):
            continue

        try:
            img_data = requests.get(src, headers=HEADERS, timeout=10).content
            file_path = os.path.join(save_dir, f"{query}_{idx}.jpg")

            with open(file_path, "wb") as f:
                f.write(img_data)

            print(f"Saved: {file_path}")
            time.sleep(delay)

        except Exception as e:
            print(f"Skipping image {idx}: {e}")


if __name__ == "__main__":
    download_google_images(
        query="Virat Kohli",
        save_dir="images",
        max_images=15,
        delay=1.0,
    )
