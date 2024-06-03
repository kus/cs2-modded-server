"""Add a map to the given game mode map group. Use the --custom flag to use custom file
paths instead of global ones.

Requirements:
* Python 3.6 or higher

Usage:
* python scripts/add-map.py <group_name> <map_name> [workshop_id] [--custom]

Example:
* python scripts/add-map.py mg_aim aim_ak-colt_CS2 123456789 --custom

When you find a map in the workshop like, e.g.
https://steamcommunity.com/sharedfiles/filedetails/?id=3070284539
the workshop ID is the number at the end of the URL, in this case 3070284539.

The map name is the displayed name of the map in the workshop, e.g. de_train.
"""

import pathlib
import sys
import argparse

gamemodes_server_path = pathlib.Path("game/csgo/gamemodes_server.txt")
subscribed_file_ids_path = pathlib.Path("game/csgo/subscribed_file_ids.txt")

custom_gamemodes_server_path = pathlib.Path("custom_files/gamemodes_server.txt")
custom_subscribed_file_ids_path = pathlib.Path("custom_files/subscribed_file_ids.txt")


def add_map_to_group(
    gamemodes_server_path, group_name: str, map_name: str, workshop_id: str = None
):
    """Add a map to the given game mode map group.

    Args:
        gamemodes_server_path (pathlib.Path): Path to the gamemodes_server.txt file.
        group_name (str): The name of the game mode group. E.g. mg_aim.
        map_name (str): The name of the map. E.g. aim_ak-colt_CS2.
        workshop_id (str, optional): The workshop ID of the map. Defaults to None. E.g.
            3078701726
    """
    if workshop_id:
        map_name = f"workshop/{workshop_id}/{map_name}"

    with open(gamemodes_server_path, "r") as file:
        lines = file.readlines()

    # Flags to track the position in the file
    in_mapgroups = False
    in_group = False
    maps_section = False

    for i, line in enumerate(lines):
        stripped_line = line.strip()

        if stripped_line.startswith('"mapgroups"'):
            in_mapgroups = True

        if in_mapgroups and stripped_line.startswith(f'"{group_name}"'):
            in_group = True

        if in_group and stripped_line.startswith('"maps"'):
            maps_section = True

        if maps_section and stripped_line == "}":
            # Insert the new map entry just before the closing brace of the maps section
            lines.insert(i, f'                "{map_name}"    ""\n')
            break

    # Write the modified lines back to the file
    with open(gamemodes_server_path, "w") as file:
        file.writelines(lines)
    print(f"Added map {map_name} to group {group_name}.")

    if workshop_id:
        add_workshop_id(subscribed_file_ids_path, workshop_id)


def add_workshop_id(subscribed_file_ids_path, workshop_id: str):
    """Add a workshop ID to the subscribed_file_ids.txt.

    Args:
        subscribed_file_ids_path (pathlib.Path): Path to the subscribed_file_ids.txt
            file.
        workshop_id (str): The workshop ID to add. E.g. 3078701726
    """
    with open(subscribed_file_ids_path, "a") as file:
        file.write(f"{workshop_id}\n")
    print(f"Added workshop ID {workshop_id} to subscribed_file_ids.txt.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Add a map to the given game mode.")
    parser.add_argument(
        "group_name", type=str, help="The name of the game mode group. E.g. mg_aim."
    )
    parser.add_argument(
        "map_name", type=str, help="The name of the map. E.g. aim_ak-colt_CS2."
    )
    parser.add_argument(
        "workshop_id",
        type=str,
        nargs="?",
        default=None,
        help="The workshop ID of the map. E.g. 3078701726",
    )
    parser.add_argument(
        "--custom",
        action="store_true",
        help="Use custom file paths" "instead of global ones.",
    )

    args = parser.parse_args()

    if args.custom:
        gamemodes_server_path = custom_gamemodes_server_path
        subscribed_file_ids_path = custom_subscribed_file_ids_path

        # Check if custom files exist
        if not gamemodes_server_path.exists() or not subscribed_file_ids_path.exists():
            print(
                "Error: Custom files do not exist. Please create the custom files "
                "before using this tool."
            )
            sys.exit(1)
    else:
        gamemodes_server_path = gamemodes_server_path
        subscribed_file_ids_path = subscribed_file_ids_path

    add_map_to_group(
        gamemodes_server_path, args.group_name, args.map_name, args.workshop_id
    )
