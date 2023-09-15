#!/bin/bash
# conda uses hard links to reuse packages, which saves disk space
# This script shows how much disk space is saved and how many packages are reused
# Optionally shows detailed info for all packages

if [ -z "$1" ]; then
    conda_path=~/.conda
else
    conda_path=$1
fi

pkgs_dir="$conda_path"/pkgs
envs_dir="$conda_path"/envs

echo "total conda disk usage:"
du -sh "$conda_path"

echo "disk space saved by hard links:"
# find all files with more than 2 hard links, print disk space saved by hard links
# saved count = total - pkg(1) - one env(1)
(
    echo 0 # incase find output nothing
    find "$pkgs_dir" -type f -links +2 -printf "(%n-2)*%s\n"
) |
    # concat all expressoins and format to human readable
    paste -sd+ | bc | numfmt --to=iec
echo ""

echo "size of each reuse level:"
echo "#disk usage #env using"
max_link=$(find "$pkgs_dir" -type f -links +1 -printf "%n\n" | sort -n | tail -1)
for link in $(seq 1 "$max_link"); do
    disk_usage=$(find "$pkgs_dir" -type f -links "$link" -printf "%s\n" | paste -sd+ | bc | numfmt --to=iec --padding 11)
    if [ -z "$disk_usage" ]; then
        continue
    fi
    # subtract 1 for pkgs/ itself
    echo "$disk_usage $((link - 1))"
done
echo ""

reuse_count() {
    for pkg in "$pkgs_dir"/*; do
        # https://unix.stackexchange.com/q/280805
        # get the number of hard links of each file, subtract 1 (for pkgs/ itself) and then print the max # of hard links
        # for folders with no files, output is empty string, and no influence on the final combined result
        find "$pkg" -type f -printf "%n-1\n" | bc | sort -nu | tail -n 1
        # why check all files: hard links count should be consistent in $pkg, but some times it's not
    done
}
echo "how many pkgs are used by multiple envs:"
echo "#pkg    #env using"
# combine hard links count for all pkgs
reuse_count | sort -n | uniq -c
echo ""

# prompt user for yes/no
read -r -p "Detailed info for all pkgs? [Y/n] "
if [[ $REPLY =~ ^[Nn]$ ]]; then
    exit
fi

get_detail() {
    echo "#reuse,disk usage,envs,pkg"
    temp_dir=$(mktemp -d)
    for pkg in "$pkgs_dir"/*; do
        count=$(find "$pkg" -type f -printf "%n\n" | sort -nu | tail -n 1)
        if [ -z "$count" ]; then
            continue # no files in this pkg
        fi
        # count = pkgs + envs
        envs_count=$(echo "$count-1" | bc)
        # du in background
        du -sh "$pkg" >"$temp_dir/du.output" &

        if [ "$count" -eq 1 ]; then # no env using this pkg
            wait                    # for du
            disk_usage=$(cut -f1 <"$temp_dir/du.output")
            echo "$envs_count,$disk_usage,,$pkg"
            continue
        fi

        # target file is any file in the pkg with the max # of hard links
        target_file=$(find "$pkg" -type f -links "$count" -print -quit)
        for env in "$envs_dir"/*; do
            # https://unix.stackexchange.com/a/201922
            # find for target in each env concurrently
            # quit because at most one target in each env
            env_name="$(basename "$env")"
            find "$env" -samefile "$target_file" -printf "$env_name\n" -quit >"$temp_dir/$env_name.find.output" &
        done
        wait # for du & find
        disk_usage=$(cut -f1 <"$temp_dir/du.output")
        envs=$(cat "$temp_dir"/*.find.output | sort | paste -sd " ")

        echo "$envs_count,$disk_usage,$envs,$pkg"
    done
    rm -rf "$temp_dir"
}

# https://stackoverflow.com/a/6075520
# print progress during sort (by count and du)
get_detail | tee /dev/tty | sort -t',' -k1,1 -k2,2 -h | less
