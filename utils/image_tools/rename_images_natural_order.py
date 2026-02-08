import os
import re
from collections import Counter


def natural_sort_key(s):
    """Helper function for natural sorting (Pod1, Pod2, ..., Pod10)."""
    return [
        int(text) if text.isdigit() else text.lower()
        for text in re.split(r"(\d+)", s)
    ]


def rename_images_in_folder(folder_path):
    """
    Rename images in a folder using user-provided names,
    preserving natural file order and handling duplicates safely.
    """

    valid_ext = ('.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tif', '.tiff')

    images = sorted(
        [f for f in os.listdir(folder_path) if f.lower().endswith(valid_ext)],
        key=natural_sort_key
    )

    if not images:
        print("❌ No images found in this folder.")
        return

    print(f"📂 Found {len(images)} image files in: {folder_path}\n")

    print("📋 Paste your list of new names (space or newline separated).")
    print("➡️ Press ENTER twice when done.\n")

    names_input = []
    while True:
        line = input()
        if line.strip() == "":
            break
        names_input.append(line)

    all_text = " ".join(names_input)
    names = [n.strip() for n in all_text.split() if n.strip()]

    if not names:
        print("❌ No names entered. Exiting.")
        return

    if len(names) > len(images):
        print(f"⚠️ {len(names)} names provided for {len(images)} images. Extra names ignored.")
    elif len(names) < len(images):
        print(f"⚠️ {len(images)} images but only {len(names)} names. Extra images unchanged.")

    name_counts = Counter()
    unique_names = []

    for name in names:
        safe_name = "".join(
            c for c in name if c.isalnum() or c in ('-', '_', ' ')
        ).strip()
        name_counts[safe_name] += 1
        if name_counts[safe_name] > 1:
            safe_name = f"{safe_name}_{name_counts[safe_name]}"
        unique_names.append(safe_name)

    rename_pairs = []
    for i, name in enumerate(unique_names):
        if i >= len(images):
            break
        ext = os.path.splitext(images[i])[1]
        rename_pairs.append((images[i], f"{name}{ext}"))

    print("\n🔍 Preview of changes:")
    for old, new in rename_pairs[:20]:
        print(f"{old}  →  {new}")
    if len(rename_pairs) > 20:
        print(f"... ({len(rename_pairs) - 20} more files)")

    confirm = input("\nProceed with renaming? (y/n): ").strip().lower()
    if confirm not in ("y", "yes"):
        print("❌ Operation cancelled.")
        return

    for old, new in rename_pairs:
        os.rename(
            os.path.join(folder_path, old),
            os.path.join(folder_path, new)
        )

    print(f"\n✅ Successfully renamed {len(rename_pairs)} images.")
    print("💾 Duplicate names were automatically numbered.")


if __name__ == "__main__":
    folder = input("Enter path to image folder: ").strip()
    rename_images_in_folder(folder)
